import 'package:flutter/material.dart';
import 'package:flutter_proto/src/generated/assistant.pb.dart' as assistant_pb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import 'package:flutter_l10n/flutter_l10n.dart';

/// The agronomy assistant.
///
/// Three things this screen must not do, because each of them turns a grounded
/// answer back into an unverifiable one:
///
///  * Render a generated answer and an extractive quotation identically. The
///    service distinguishes them and so does this screen — a quotation from a
///    crop guide is not advice written for this farm.
///
///  * Drop the citation markers. The [2] in an answer is the only thread back
///    to the passage or the service reading it came from.
///
///  * Hide the evaluation. When the service could not tie an answer to a
///    source, that is the most important thing on the screen — especially on a
///    phone, where the citation list is below the fold.
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key, this.fieldId = '', this.farmId = ''});

  /// The field the question is about. With it the assistant reads that field's
  /// own weather, alerts, crop stage and diagnoses before answering; without
  /// it the answer is about farming rather than about this farm.
  final String fieldId;
  final String farmId;

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final _exchanges = <assistant_pb.Exchange>[];
  String _conversationId = '';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Maps the app's locale onto the advisory enum.
  ///
  /// The farmer's own language, not a default: the service writes the answer
  /// in whatever is asked for here, so getting this wrong means a Marathi
  /// speaker is answered in English by a screen labelled in Marathi.
  assistant_pb.Locale _localeFor(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'hi':
        return assistant_pb.Locale.LOCALE_HI;
      case 'mr':
        return assistant_pb.Locale.LOCALE_MR;
      case 'te':
        return assistant_pb.Locale.LOCALE_TE;
      case 'ta':
        return assistant_pb.Locale.LOCALE_TA;
      case 'kn':
        return assistant_pb.Locale.LOCALE_KN;
      case 'pa':
        return assistant_pb.Locale.LOCALE_PA;
      case 'bn':
        return assistant_pb.Locale.LOCALE_BN;
      default:
        return assistant_pb.Locale.LOCALE_EN;
    }
  }

  Future<void> _ask() async {
    final question = _controller.text.trim();
    if (question.isEmpty || _loading) return;

    final l10n = AppLocalizations.of(context)!;
    final locale = _localeFor(context);

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await ref.read(assistantRemoteDataSourceProvider).ask(
            question: question,
            locale: locale,
            conversationId: _conversationId,
            fieldId: widget.fieldId,
            farmId: widget.farmId,
          );

      if (!mounted) return;
      setState(() {
        _conversationId = response.conversationId;
        if (response.hasExchange()) _exchanges.add(response.exchange);
        _controller.clear();
      });
      _scrollToEnd();
    } catch (_) {
      if (!mounted) return;
      // The question stays in the box. Clearing it would make a dropped
      // connection cost the farmer the sentence they just typed, which on a
      // phone in a field is a real cost.
      setState(() => _error = l10n.advisoryFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.advisoryTitle),
        actions: [
          if (_exchanges.isNotEmpty)
            TextButton(
              onPressed: () => setState(() {
                _exchanges.clear();
                _conversationId = '';
                _error = null;
              }),
              child: Text(l10n.advisoryNewConversation),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l10n.advisorySubtitle,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: _exchanges.isEmpty && !_loading
                ? _EmptyState(l10n: l10n)
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _exchanges.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) =>
                        _ExchangeCard(exchange: _exchanges[index], l10n: l10n),
                  ),
          ),
          if (_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.advisoryThinking, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          if (_error != null)
            Container(
              width: double.infinity,
              color: theme.colorScheme.errorContainer,
              padding: const EdgeInsets.all(12),
              child: Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: l10n.advisoryAskHint,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _loading ? null : _ask,
                    child: Text(l10n.advisorySend),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.advisoryEmptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              l10n.advisoryEmptyBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExchangeCard extends StatelessWidget {
  const _ExchangeCard({required this.exchange, required this.l10n});

  final assistant_pb.Exchange exchange;
  final AppLocalizations l10n;

  String _answerKindLabel() {
    switch (exchange.answerKind) {
      case assistant_pb.AnswerKind.ANSWER_KIND_GENERATED:
        return l10n.advisoryKindGenerated;
      case assistant_pb.AnswerKind.ANSWER_KIND_EXTRACTIVE:
        return l10n.advisoryKindExtractive;
      case assistant_pb.AnswerKind.ANSWER_KIND_REFUSED:
        return l10n.advisoryKindRefused;
      default:
        return '';
    }
  }

  String _verdictLabel() {
    switch (exchange.evaluation.verdict) {
      case assistant_pb.GroundednessVerdict.GROUNDEDNESS_VERDICT_GROUNDED:
        return l10n.advisoryVerdictGrounded;
      case assistant_pb.GroundednessVerdict.GROUNDEDNESS_VERDICT_PARTIAL:
        return l10n.advisoryVerdictPartial;
      case assistant_pb.GroundednessVerdict.GROUNDEDNESS_VERDICT_UNGROUNDED:
        return l10n.advisoryVerdictUngrounded;
      default:
        return '';
    }
  }

  // Colour carries the same information as the text, for the reader who scans
  // rather than reads. It never carries it alone.
  Color _verdictColour(ColorScheme scheme) {
    switch (exchange.evaluation.verdict) {
      case assistant_pb.GroundednessVerdict.GROUNDEDNESS_VERDICT_GROUNDED:
        return scheme.primaryContainer;
      case assistant_pb.GroundednessVerdict.GROUNDEDNESS_VERDICT_UNGROUNDED:
        return scheme.errorContainer;
      default:
        return scheme.tertiaryContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Text(
              exchange.question,
              style: theme.textTheme.titleSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // How the answer was produced, above the answer itself. A
                // reader who stops after the first line should already know
                // whether they are reading advice or a quotation.
                Text(
                  _answerKindLabel(),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                SelectableText(exchange.answer, style: theme.textTheme.bodyMedium),

                if (exchange.hasEvaluation()) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _verdictColour(theme.colorScheme),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_verdictLabel(), style: theme.textTheme.labelMedium),
                        if (exchange.evaluation.unsupportedNumbers.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              exchange.evaluation.unsupportedNumbers.join(', '),
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                        if (exchange.evaluation.needsReview)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              l10n.advisoryReviewFlagged,
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                if (exchange.citations.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.advisorySources,
                    style: theme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  // Collapsed by default: the snippet is what the model was
                  // actually shown, which matters to anyone checking the
                  // answer and is too long to sit in a chat bubble on a phone.
                  for (final citation in exchange.citations)
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(bottom: 8),
                      title: Text(
                        '[${citation.marker}] ${citation.title}',
                        style: theme.textTheme.bodySmall,
                      ),
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: SelectableText(
                            citation.snippet,
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                ],

                if (exchange.toolCalls.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(l10n.advisoryToolsUsed, style: theme.textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final call in exchange.toolCalls)
                        // A failed lookup is shown, not hidden. An answer given
                        // without the field's open alerts because alert-service
                        // was down is a different answer, and only this says so.
                        Chip(
                          label: Text(call.name),
                          avatar: Icon(
                            call.ok ? Icons.check : Icons.close,
                            size: 14,
                            color: call.ok
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
