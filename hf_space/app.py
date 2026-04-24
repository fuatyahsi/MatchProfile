import json
import os
import re
from typing import Any, Dict, Optional

import torch
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel
from transformers import AutoModelForCausalLM, AutoTokenizer


MODEL_ID = os.getenv("MODEL_ID", "Qwen/Qwen2.5-0.5B-Instruct")
SPACE_TOKEN = os.getenv("MATCHPROFILE_SPACE_TOKEN", "").strip()
DEFAULT_MAX_NEW_TOKENS = int(os.getenv("MAX_NEW_TOKENS", "220"))
DEFAULT_TEMPERATURE = float(os.getenv("TEMPERATURE", "0.25"))

app = FastAPI(title="MatchProfile Self-hosted LLM")

tokenizer = AutoTokenizer.from_pretrained(MODEL_ID, trust_remote_code=True)

if torch.cuda.is_available():
    model = AutoModelForCausalLM.from_pretrained(
        MODEL_ID,
        torch_dtype=torch.float16,
        device_map="auto",
        trust_remote_code=True,
    )
else:
    model = AutoModelForCausalLM.from_pretrained(
        MODEL_ID,
        torch_dtype=torch.float32,
        trust_remote_code=True,
    )

model.eval()


class LlmRequest(BaseModel):
    systemPrompt: str = ""
    userMessage: str = ""
    task: str = "chat"
    maxNewTokens: Optional[int] = None
    temperature: Optional[float] = None


def _check_auth(authorization: Optional[str]) -> None:
    if not SPACE_TOKEN:
        return
    expected = f"Bearer {SPACE_TOKEN}"
    if authorization != expected:
        raise HTTPException(status_code=401, detail="Unauthorized")


def _build_prompt(system_prompt: str, user_message: str) -> str:
    system_text = system_prompt.strip()
    user_text = user_message.strip()
    messages = [
        {"role": "system", "content": system_text},
        {"role": "user", "content": user_text},
    ]

    if getattr(tokenizer, "chat_template", None):
        try:
            return tokenizer.apply_chat_template(
                messages,
                tokenize=False,
                add_generation_prompt=True,
            )
        except Exception:
            pass

    return f"System:\n{system_text}\n\nUser:\n{user_text}\n\nAssistant:\n"


def _generate(system_prompt: str, user_message: str, request: LlmRequest) -> str:
    prompt = _build_prompt(system_prompt, user_message)
    inputs = tokenizer(prompt, return_tensors="pt")
    device = next(model.parameters()).device
    inputs = {key: value.to(device) for key, value in inputs.items()}

    temperature = request.temperature
    if temperature is None:
        temperature = DEFAULT_TEMPERATURE
    max_new_tokens = request.maxNewTokens or DEFAULT_MAX_NEW_TOKENS

    with torch.no_grad():
        output = model.generate(
            **inputs,
            max_new_tokens=max_new_tokens,
            do_sample=temperature > 0,
            temperature=max(temperature, 0.01),
            top_p=0.9,
            repetition_penalty=1.06,
            pad_token_id=tokenizer.eos_token_id,
        )

    generated = output[0][inputs["input_ids"].shape[-1] :]
    return tokenizer.decode(generated, skip_special_tokens=True).strip()


def _extract_json_object(text: str) -> Dict[str, Any]:
    cleaned = text.strip()
    cleaned = re.sub(r"^```(?:json)?", "", cleaned, flags=re.IGNORECASE).strip()
    cleaned = re.sub(r"```$", "", cleaned).strip()

    try:
        value = json.loads(cleaned)
        if isinstance(value, dict):
            return value
    except json.JSONDecodeError:
        pass

    start = cleaned.find("{")
    end = cleaned.rfind("}")
    if start >= 0 and end > start:
        value = json.loads(cleaned[start : end + 1])
        if isinstance(value, dict):
            return value

    raise ValueError("Model did not return valid JSON")


def _compact_text(text: str) -> str:
    cleaned = re.sub(r"```(?:json)?", "", text, flags=re.IGNORECASE)
    cleaned = cleaned.replace("```", " ")
    cleaned = re.sub(r"\s+", " ", cleaned).strip()
    return cleaned[:700]


def _fallback_json(task: str, raw_text: str) -> Dict[str, Any]:
    reply = _compact_text(raw_text)

    if task == "chat_onboarding_turn":
        return {
            "assistant_reply": reply,
            "extracted_fields": {},
            "acknowledged_sensitive_context": False,
        }

    if task == "belief_extraction":
        return {
            "beliefRightPersonFindsWay": 4,
            "beliefChemistryFeltFast": 4,
            "beliefStrongAttractionIsSign": 4,
            "beliefFeelsRightOrNot": 4,
            "beliefFirstFeelingsAreTruth": 4,
            "beliefPotentialEqualsValue": 4,
            "beliefAmbiguityIsNormal": 4,
            "beliefLoveOvercomesIssues": 4,
        }

    if task == "psyche_anchor":
        return {
            "one_line_mirror": reply,
            "core_tension": "",
            "private_context_summary": "",
            "blind_spot": "",
            "strength": "",
            "first_action": "",
            "confidence": 0.35,
        }

    if task == "reflection_report":
        return {
            "summary": reply,
            "signals": [],
            "next_step": "",
            "risk_flags": [],
            "confidence": 0.35,
        }

    return {
        "raw_response": reply,
        "profil_icgoru": reply,
        "kor_nokta_uyarisi": "",
        "dongu_tespiti": "",
        "kisisel_tavsiye": "",
        "onyargi_bayraklari": [],
        "deger_cikarimi": [],
        "duygusal_ton": "",
        "guven_skoru": 0.35,
    }


@app.get("/")
def root() -> Dict[str, Any]:
    return {
        "ok": True,
        "service": "MatchProfile self-hosted LLM",
        "health": "/health",
        "chat": "/v1/chat",
        "json": "/v1/json",
    }


@app.get("/health")
def health() -> Dict[str, Any]:
    return {
        "ok": True,
        "model": MODEL_ID,
        "cuda": torch.cuda.is_available(),
    }


@app.post("/v1/chat")
def chat(
    request: LlmRequest,
    authorization: Optional[str] = Header(default=None),
) -> Dict[str, Any]:
    _check_auth(authorization)
    reply = _generate(request.systemPrompt, request.userMessage, request)
    return {
        "reply": reply,
        "model": MODEL_ID,
        "task": request.task,
    }


@app.post("/v1/json")
def json_completion(
    request: LlmRequest,
    authorization: Optional[str] = Header(default=None),
) -> Dict[str, Any]:
    _check_auth(authorization)
    strict_system = (
        f"{request.systemPrompt.strip()}\n\n"
        "Return ONLY one valid JSON object. Do not use markdown. "
        "Do not add explanations outside JSON."
    )
    text = _generate(strict_system, request.userMessage, request)

    try:
        result = _extract_json_object(text)
        repaired = False
    except ValueError:
        result = _fallback_json(request.task, text)
        repaired = True

    return {
        "result": result,
        "model": MODEL_ID,
        "task": request.task,
        "repaired": repaired,
    }
