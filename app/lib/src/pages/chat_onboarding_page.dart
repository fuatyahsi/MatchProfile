// ══════════════════════════════════════════════════════════════
//  Sohbet Tabanlı Onboarding — Koyu Editöryal Tasarım
//  ──────────────────────────────────────────────────
//  Minimal, derin siyah zemin üzerinde sıcak altın vurgular.
//  Mesaj balonları yerine açık tipografi, ince çizgiler.
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../ai/ai_config.dart';
import '../ai/ai_contracts.dart';
import '../ai/chat_onboarding_service.dart';
import '../controller.dart';
import '../models.dart';
import '../theme.dart' as t;
import '../widgets/app_widgets.dart';

class ChatOnboardingPage extends StatefulWidget {
  const ChatOnboardingPage({
    super.key,
    required this.controller,
    required this.onComplete,
  });

  final MatchProfileController controller;
  final VoidCallback onComplete;

  @override
  State<ChatOnboardingPage> createState() => _ChatOnboardingPageState();
}

class _ChatOnboardingPageState extends State<ChatOnboardingPage>
    with TickerProviderStateMixin {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final ChatOnboardingService _service = ChatOnboardingService.instance;
  final List<ChatMessage> _messages = <ChatMessage>[];
  bool _isLoading = false;
  bool _llmUnavailable = false;
  RelationshipGoal? _quickGoal;
  PacingPreference? _quickPacing;
  CommunicationPreference? _quickCommunication;
  AssuranceNeed? _quickAssurance;
  bool _quickStartApplied = false;

  @override
  void initState() {
    super.initState();
    _service.reset();

    if (!_service.isLlmAvailable) {
      _llmUnavailable = true;
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  bool get _hasUserMessages => _messages.any((ChatMessage m) => m.role == 'user');

  Future<void> _applyQuickStart() async {
    if (_quickGoal == null &&
        _quickPacing == null &&
        _quickCommunication == null &&
        _quickAssurance == null) {
      return;
    }

    _service.applyQuickStartSeed(
      goal: _quickGoal,
      pacingPreference: _quickPacing,
      communicationPreference: _quickCommunication,
      assuranceNeed: _quickAssurance,
    );

    final bool shouldKickoff = !_hasUserMessages;

    setState(() {
      _quickStartApplied = true;
      _isLoading = shouldKickoff;
    });

    if (!shouldKickoff) return;

    try {
      final ChatMessage? response = await _service.createQuickStartKickoff();
      if (!mounted) return;
      setState(() {
        if (response != null && response.content.trim().isNotEmpty) {
          _messages.add(response);
        }
        _isLoading = false;
      });
      _scrollToBottom();
      _focusNode.requestFocus();
    } on LlmUnavailableException {
      if (!mounted) return;
      setState(() {
        _llmUnavailable = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Hizli baslangic hatasi: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestWrapUp() async {
    if (_isLoading || _llmUnavailable) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final ChatMessage? response = await _service.requestWrapUp();
      if (!mounted) return;
      setState(() {
        if (response != null && response.content.trim().isNotEmpty) {
          _messages.add(response);
        }
        _isLoading = false;
      });
      _scrollToBottom();

      if (_service.isComplete) {
        await _completeOnboarding();
      }
    } on LlmUnavailableException catch (e) {
      debugPrint('Wrap-up LLM hatasi: $e');
      if (!mounted) return;
      setState(() {
        _llmUnavailable = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Wrap-up hatasi: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final String text = _inputCtrl.text.trim();
    if (text.isEmpty || _isLoading || _llmUnavailable) return;

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _isLoading = true;
      _inputCtrl.clear();
    });
    _scrollToBottom();

    try {
      final ChatMessage? response = await _service.processUserMessage(text);

      if (!mounted) return;
      setState(() {
        if (response != null && response.content.trim().isNotEmpty) {
          _messages.add(response);
        }
        _isLoading = false;
      });
      _scrollToBottom();

      if (_service.isComplete) {
        await _completeOnboarding();
      }
    } on LlmUnavailableException catch (e) {
      debugPrint('LLM erişilemez: $e');
      if (!mounted) return;
      setState(() {
        _llmUnavailable = true;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      // Geçici hata — servis zaten retry yapıp kullanıcıya mesaj ekledi
      debugPrint('Sohbet hatası: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _completeOnboarding() async {
    final OnboardingProfile profile = _service.extracted.toProfile();

    final bool accepted = await _showProfileReview(profile);
    if (!accepted || !mounted) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: t.cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.borderLight.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: t.primaryYellow.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Analiz ediliyor',
                style: TextStyle(
                  color: t.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Profilin oluşturuluyor',
                style: TextStyle(
                  color: t.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final AiEnvelope<UserPsycheAnchor> anchorRun =
        await widget.controller.generatePsycheAnchorEnvelope(profile);
    profile.psycheAnchor = anchorRun.payload;

    if (!mounted) return;
    Navigator.pop(context);

    final AiEnvelope<UserPsycheAnchor> finalRun =
        await _showMirrorReport(profile, anchorRun);
    profile.psycheAnchor = finalRun.payload;

    widget.controller.completeOnboarding(profile);
    widget.onComplete();
  }

  Future<bool> _showProfileReview(OnboardingProfile profile) async {
    bool ageConfirmed = false;
    bool policyAccepted = false;

    final bool? accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            final bool canContinue = ageConfirmed && policyAccepted;
            final List<String> highlights = profile.profileHighlights;

            return Dialog(
              backgroundColor: t.cardWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 620),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Profilini onayla',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sohbetten cikardigim temel profil bu. Sonraki yorumlar bu zemine gore calisacak.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: t.textSecondary,
                              height: 1.45,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBF4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: t.primaryYellow.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              profile.displayName.trim().isEmpty
                                  ? 'Isimsiz profil'
                                  : profile.displayName.trim(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: t.primaryDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              profile.generateProfileSummary(),
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: t.textPrimary,
                                        height: 1.5,
                                      ),
                            ),
                            if (highlights.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: highlights.take(5).map((String tag) {
                                  return TagPill(text: tag);
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        value: ageConfirmed,
                        onChanged: (bool? value) => setDialogState(
                          () => ageConfirmed = value ?? false,
                        ),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('18 yasindan buyugum.'),
                      ),
                      CheckboxListTile(
                        value: policyAccepted,
                        onChanged: (bool? value) => setDialogState(
                          () => policyAccepted = value ?? false,
                        ),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          'MatchProfile karar vermez; bana dusunme destegi sunar. Kosullari ve gizlilik yaklasimini kabul ediyorum.',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: const Text('Sohbete don'),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: canContinue
                                ? () => Navigator.pop(dialogContext, true)
                                : null,
                            child: const Text('Onayla ve devam et'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    return accepted ?? false;
  }

  Future<AiEnvelope<UserPsycheAnchor>> _showMirrorReport(
    OnboardingProfile profile,
    AiEnvelope<UserPsycheAnchor> initialRun,
  ) async {
    AiEnvelope<UserPsycheAnchor> mirrorRun = initialRun;

    while (mounted) {
      final UserPsycheAnchor anchor = mirrorRun.payload;
      final bool aiActive = mirrorRun.mode == AiRunMode.llm;
      final bool canRetryLlm =
          AIConfig.instance.isChatLlmAvailable &&
          mirrorRun.mode != AiRunMode.llm;
      final String statusText = switch (mirrorRun.mode) {
        AiRunMode.llm => 'Derin okuma aktif',
        AiRunMode.hybrid => 'Hibrit analiz',
        AiRunMode.local => 'Kural tabanlı',
        AiRunMode.vector => 'Vektör analiz',
      };

      final _MirrorAction? action = await showDialog<_MirrorAction>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: t.cardWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header
                Row(
                  children: <Widget>[
                    Text(
                      'PROFİLİN HAZIR 🎉',
                      style: TextStyle(
                        color: t.primaryDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: aiActive
                            ? t.softGreen.withValues(alpha: 0.08)
                            : t.amber.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: aiActive ? t.softGreen : t.amber,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Mirror text
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          anchor.mirrorReport,
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.6,
                            color: t.textPrimary.withValues(alpha: 0.85),
                          ),
                        ),
                        if (anchor.sensitiveMemories.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 16),
                          SensitiveContextDeck(
                            memories: anchor.sensitiveMemories,
                            maxItems: 2,
                            title: 'Bunu da tutuyorum',
                            subtitle:
                                'Paylastigin ozel baglam sonraki yorumlarin tonunu ve risk okumasini degistirecek.',
                          ),
                        ],
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: t.primarySoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.lightbulb_outline_rounded, color: t.primaryDark, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Günlük kayıt ve yansıtmalarla profilin her gün daha net olacak.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: t.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (anchor.coreRealities.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 16),
                          Container(
                            height: 0.5,
                            color: t.borderLight.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Seni tanıdım — işte gördüklerim',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: t.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...anchor.coreRealities.map(
                            (String r) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('→ ', style: TextStyle(color: t.primaryDark, fontSize: 14)),
                                  Expanded(
                                    child: Text(
                                      r,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        height: 1.5,
                                        color: t.textPrimary.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    if (canRetryLlm)
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, _MirrorAction.retryLlm),
                        style: TextButton.styleFrom(
                          foregroundColor: t.textSecondary,
                        ),
                        child: const Text('Tekrar dene'),
                      ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () =>
                          Navigator.pop(context, _MirrorAction.continueToApp),
                      child: const Text('Uygulamaya Geç →'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (action == _MirrorAction.retryLlm) {
        if (!mounted) break;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: t.primaryYellow.withValues(alpha: 0.6),
            ),
          ),
        );
        mirrorRun =
            await widget.controller.generatePsycheAnchorEnvelope(profile);
        if (!mounted) break;
        Navigator.pop(context);
        continue;
      }
      return mirrorRun;
    }
    return initialRun;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool showQuickStart = !_quickStartApplied && !_hasUserMessages;
    final bool showLiveSummary = _quickStartApplied || _hasUserMessages;

    return Scaffold(
      backgroundColor: t.warmBg,
      body: AppBackdrop(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              // ── Top Bar — vibrant with gradient ──
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      t.primaryYellow.withValues(alpha: 0.28),
                      const Color(0xFFFFE5B8),
                      t.accentOrange.withValues(alpha: 0.18),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: t.primaryYellow.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border(
                    bottom: BorderSide(
                      color: t.primaryYellow.withValues(alpha: 0.32),
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Sırdaş',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: t.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _phaseLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: t.roseGold.withValues(alpha: 0.8),
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildProgressIndicator(),
                  ],
                ),
              ),

              // ── Mesajlar ──
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  itemCount:
                      (showQuickStart ? 1 : 0) +
                      (showLiveSummary ? 1 : 0) +
                      _messages.length +
                      (_isLoading ? 1 : 0),
                  itemBuilder: (BuildContext context, int index) {
                    int cursor = 0;
                    if (showQuickStart) {
                      if (index == cursor) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildQuickStartDeck(theme, inline: true),
                        );
                      }
                      cursor += 1;
                    }
                    if (showLiveSummary) {
                      if (index == cursor) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildLiveSummaryDeck(theme, inline: true),
                        );
                      }
                      cursor += 1;
                    }
                    final int messageIndex = index - cursor;
                    if (messageIndex == _messages.length && _isLoading) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessageBubble(_messages[messageIndex]);
                  },
                ),
              ),

              // ── Giriş Alanı ──
              _buildInputArea(theme),
            ],
          ),
        ),
      ),
    );
  }

  String get _phaseLabel {
    return switch (_service.phase) {
      ChatPhase.greeting => 'Tanışma',
      ChatPhase.deepDive => 'Muhabbet',
      ChatPhase.beliefs => 'İnançlar',
      ChatPhase.complete => 'Tamam!',
    };
  }

  Widget _buildQuickStartDeck(ThemeData theme, {bool inline = false}) {
    final bool hasQuickSelection = _quickGoal != null ||
        _quickPacing != null ||
        _quickCommunication != null ||
        _quickAssurance != null;

    return Container(
      margin: inline ? EdgeInsets.zero : const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            const Color(0xFF17243A),
            const Color(0xFF27476C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: t.primaryDark.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD66B).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFFFD66B).withValues(alpha: 0.28),
                  ),
                ),
                child: const Text(
                  'Hizli baslangic',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: Color(0xFFFFF4D2),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Az yaz, daha hizli acil',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFE8EEF8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Once birkac secim yap. Sohbet daha dogru yerden baslasin.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFF7FAFE),
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          _buildChoiceGroup<RelationshipGoal>(
            title: 'Ne ariyorsun?',
            value: _quickGoal,
            options: const <RelationshipGoal>[
              RelationshipGoal.serious,
              RelationshipGoal.openExplore,
              RelationshipGoal.slowBond,
              RelationshipGoal.unsure,
            ],
            labelBuilder: (RelationshipGoal goal) => goal.label,
            onSelected: (RelationshipGoal? value) {
              setState(() {
                _quickGoal = value;
              });
            },
            dark: true,
          ),
          const SizedBox(height: 14),
          _buildChoiceGroup<PacingPreference>(
            title: 'Nasil ilerlesin?',
            value: _quickPacing,
            options: const <PacingPreference>[
              PacingPreference.slow,
              PacingPreference.balanced,
              PacingPreference.fastButClear,
            ],
            labelBuilder: (PacingPreference pacing) => pacing.label,
            onSelected: (PacingPreference? value) {
              setState(() {
                _quickPacing = value;
              });
            },
            dark: true,
          ),
          const SizedBox(height: 14),
          _buildChoiceGroup<CommunicationPreference>(
            title: 'Iletisim nasil iyi gelir?',
            value: _quickCommunication,
            options: const <CommunicationPreference>[
              CommunicationPreference.balancedRegular,
              CommunicationPreference.deepConversation,
              CommunicationPreference.frequentContact,
              CommunicationPreference.spaceGiving,
            ],
            labelBuilder: (CommunicationPreference preference) {
              return switch (preference) {
                CommunicationPreference.balancedRegular => 'Duzenli',
                CommunicationPreference.deepConversation => 'Derin',
                CommunicationPreference.frequentContact => 'Sik',
                CommunicationPreference.spaceGiving => 'Alanli',
                CommunicationPreference.lightFun => 'Hafif',
              };
            },
            onSelected: (CommunicationPreference? value) {
              setState(() {
                _quickCommunication = value;
              });
            },
            dark: true,
          ),
          const SizedBox(height: 14),
          _buildChoiceGroup<AssuranceNeed>(
            title: 'Netlik ihtiyacin',
            value: _quickAssurance,
            options: const <AssuranceNeed>[
              AssuranceNeed.low,
              AssuranceNeed.medium,
              AssuranceNeed.high,
            ],
            labelBuilder: (AssuranceNeed need) => need.label,
            onSelected: (AssuranceNeed? value) {
              setState(() {
                _quickAssurance = value;
              });
            },
            dark: true,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  _isLoading || !hasQuickSelection ? null : _applyQuickStart,
              style: FilledButton.styleFrom(
                backgroundColor: t.primaryYellow,
                foregroundColor: t.primaryDark,
                disabledBackgroundColor: const Color(0xFF5E6E8B),
                disabledForegroundColor: const Color(0xFFE8EEF8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                hasQuickSelection
                    ? (_quickStartApplied ? 'Secimleri guncelle' : 'Buna gore baslat')
                    : 'Once secim yap',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ),
          ],
        ),
      );
  }

  Widget _buildLiveSummaryDeck(ThemeData theme, {bool inline = false}) {
    final ExtractedProfile extracted = _service.extracted;
    final List<String> insightTags = <String>[
      if (_quickGoal != null) _quickGoal!.label,
      if (_quickPacing != null) _quickPacing!.label,
      if (_quickCommunication != null)
        switch (_quickCommunication!) {
          CommunicationPreference.balancedRegular => 'Duzenli iletisim',
          CommunicationPreference.deepConversation => 'Derin iletisim',
          CommunicationPreference.frequentContact => 'Sik temas',
          CommunicationPreference.spaceGiving => 'Alan ihtiyaci',
          CommunicationPreference.lightFun => 'Hafif iletisim',
        },
      if (_quickAssurance != null) 'Netlik: ${_quickAssurance!.label}',
      ...extracted.coreTraits.take(2),
    ];

    final String snapshot = extracted.currentLifeTheme.isNotEmpty
        ? extracted.currentLifeTheme
        : extracted.datingChallenge.isNotEmpty
            ? extracted.datingChallenge
            : extracted.selfDescription.isNotEmpty
                ? extracted.selfDescription
                : 'Kisa cevaplar geldikce profil netlesiyor.';

    final int remainingHint = _service.canFinishNow
        ? 0
        : (_service.capturedFieldCount < 8 ? 3 : 2);

    return Container(
      margin: inline ? EdgeInsets.zero : const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: t.primaryYellow.withValues(alpha: 0.22)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: t.primaryYellow.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Canli profil izi',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: t.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _service.canFinishNow
                          ? 'Yeterli sinyal aldim. Istersen artik ozete gecebiliriz.'
                          : '$remainingHint kisa cevap daha, sonra ozet cikarabilirim.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: t.textSecondary.withValues(alpha: 0.85),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      t.primaryYellow.withValues(alpha: 0.24),
                      const Color(0xFFFFE5B8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      '${_service.capturedFieldCount}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: t.primaryDark,
                      ),
                    ),
                    Text(
                      'sinyal',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: t.primaryDark.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (insightTags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: insightTags.take(6).map((String tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5E8),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: t.primaryYellow.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: t.primaryDark,
                    ),
                  ),
                );
              }).toList(),
            ),
          if (insightTags.isNotEmpty) const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              snapshot,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: t.textPrimary.withValues(alpha: 0.78),
                height: 1.45,
              ),
            ),
          ),
          if (_service.canFinishNow) ...<Widget>[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _requestWrapUp,
                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                label: const Text('Simdi kisa ozetimi cikar'),
                style: FilledButton.styleFrom(
                  backgroundColor: t.accentOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChoiceGroup<T>({
    required String title,
    required T? value,
    required List<T> options,
    required String Function(T option) labelBuilder,
    required ValueChanged<T?> onSelected,
    bool dark = false,
  }) {
    final Color titleColor = dark
        ? const Color(0xFFFFF4D2)
        : t.textPrimary.withValues(alpha: 0.82);
    final Color chipColor =
        dark ? const Color(0xFFEEF3FB) : const Color(0xFFFFF7EC);
    final Color borderColor =
        dark ? const Color(0xFFD5E0EF) : t.primaryYellow.withValues(alpha: 0.20);
    final Color textColor =
        dark ? const Color(0xFF24344D) : t.textPrimary.withValues(alpha: 0.78);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: titleColor,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((T option) {
            final bool selected = value == option;
            return InkWell(
              onTap: () => onSelected(selected ? null : option),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? t.primaryYellow : chipColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? Colors.transparent : borderColor,
                  ),
                  boxShadow: selected
                      ? <BoxShadow>[
                          BoxShadow(
                            color: t.primaryYellow.withValues(alpha: 0.28),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labelBuilder(option),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? t.primaryDark : textColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    double progress = switch (_service.phase) {
      ChatPhase.greeting => 0.05,
      ChatPhase.deepDive => 0.1 + (_service.history.where(
              (ChatMessage m) => m.role == 'user').length * 0.1).clamp(0.0, 0.6),
      ChatPhase.beliefs => 0.8,
      ChatPhase.complete => 1.0,
    };

    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 2.5,
            backgroundColor: t.primaryYellow.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(t.accentOrange),
          ),
          Text(
            '${(progress * 100).round()}',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: t.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final bool isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          // Rol etiketi with icon
          Padding(
            padding: EdgeInsets.only(
              left: isUser ? 0 : 0,
              right: isUser ? 0 : 0,
              bottom: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (!isUser) ...<Widget>[
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: t.primaryYellow,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 8,
                      color: t.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  isUser ? 'Sen' : 'Sırdaş',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: isUser
                        ? t.textSecondary
                        : t.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          // Mesaj
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.82,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? const Color(0xFFFFEFE5)
                  : t.cardWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isUser
                    ? const Color(0xFFFFC9A8).withValues(alpha: 0.65)
                    : t.primaryYellow.withValues(alpha: 0.28),
                width: 1,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: (isUser ? t.accentOrange : t.primaryYellow)
                      .withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              message.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.55,
                color: isUser
                    ? t.textPrimary.withValues(alpha: 0.85)
                    : t.textPrimary.withValues(alpha: 0.87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: t.primaryYellow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 8,
                  color: t.primaryDark,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Sırdaş',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: t.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: t.cardWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: t.primaryYellow.withValues(alpha: 0.28),
                width: 1,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: t.primaryYellow.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _TypingDot(delay: 0),
                const SizedBox(width: 5),
                _TypingDot(delay: 150),
                const SizedBox(width: 5),
                _TypingDot(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// LLM bağlantısını tekrar kontrol edip sohbeti yeniden başlatır
  void _retryLlmConnection() {
    if (_service.isLlmAvailable) {
      setState(() {
        _llmUnavailable = false;
        _service.reset();
        _messages.clear();
        _quickStartApplied = false;
        _isLoading = false;
      });
    } else {
      setState(() {
        _llmUnavailable = true;
      });
    }
  }

  Widget _buildInputArea(ThemeData theme) {
    // LLM erişilemezse: input yerine "Tekrar Dene" butonu göster
    if (_llmUnavailable) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: t.warmBg,
          border: Border(
            top: BorderSide(color: t.borderLight.withValues(alpha: 0.15)),
          ),
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.cloud_off_rounded,
                    color: t.roseCaution.withValues(alpha: 0.6), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sohbet motoru bağlantısı yok',
                    style: TextStyle(
                      color: t.roseCaution.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _retryLlmConnection,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Bağlantıyı kontrol et'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: t.primaryYellow,
                  side: BorderSide(color: t.primaryYellow.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bool canSend =
        !_isLoading && !_service.isComplete && _quickStartApplied;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 12, 20),
      decoration: BoxDecoration(
        color: t.warmBg,
        border: Border(
          top: BorderSide(
            color: t.primaryYellow.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (_service.canFinishNow) ...<Widget>[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _requestWrapUp,
                icon: const Icon(Icons.flash_on_rounded, size: 16),
                label: const Text('Yeterli oldu, ozete gec'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: t.accentOrange,
                  side: BorderSide(color: t.accentOrange.withValues(alpha: 0.24)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: t.cardWhite,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: t.primaryYellow.withValues(alpha: 0.24),
                  width: 1,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: t.primaryYellow.withValues(alpha: 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TextField(
                controller: _inputCtrl,
                focusNode: _focusNode,
                enabled: canSend,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                maxLines: 4,
                minLines: 1,
                style: TextStyle(
                  fontSize: 14.5,
                  color: t.textPrimary.withValues(alpha: 0.85),
                  height: 1.4,
                ),
                cursorColor: t.primaryDark,
                decoration: InputDecoration(
                  hintText: _service.isComplete
                      ? 'Tamamlandı'
                      : _quickStartApplied
                          ? 'Cevabını yaz...'
                          : 'Önce yukarıdan birkaç seçim yap...',
                  hintStyle: TextStyle(
                    color: t.textMuted.withValues(alpha: 0.55),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: GestureDetector(
              onTap: canSend ? _sendMessage : null,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: canSend ? t.primaryYellow : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: canSend
                      ? <BoxShadow>[
                          BoxShadow(
                            color: t.primaryYellow.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: canSend
                      ? t.darkBg
                      : t.textMuted.withValues(alpha: 0.3),
                  size: 18,
                ),
              ),
            ),
          ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Typing Animation
// ══════════════════════════════════════════════

class _TypingDot extends StatefulWidget {
  const _TypingDot({required this.delay});

  final int delay;

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = Tween<double>(begin: 0.2, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? _) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: t.primaryDark,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

enum _MirrorAction {
  continueToApp,
  retryLlm,
}
