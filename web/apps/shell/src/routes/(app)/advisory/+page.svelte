<script lang="ts">
  import { page } from '$app/stores';
  import { t, locale } from '@samavāya/i18n';
  import { advisoryClient } from '@samavāya/agriculture/services';
  import {
    AdvisoryLocale,
    AnswerKind,
    CitationKind,
    GroundednessVerdict,
    type AdvisoryExchange,
    type AdvisoryCitation,
    type TenantBudget,
  } from '@samavāya/proto';

  /**
   * The agronomy assistant.
   *
   * Three things this page must not do, because each of them turns a grounded
   * answer back into an unverifiable one:
   *
   *  * Render a generated answer and an extractive quotation identically. The
   *    service distinguishes them and so does this page — a quotation from a
   *    crop guide is not advice written for this farm, and a UI that presents
   *    them the same way is lying by omission.
   *
   *  * Drop the citation markers. The [2] in an answer is the only thread back
   *    to the passage or the service reading it came from; stripped out for
   *    tidiness it becomes a claim with no provenance.
   *
   *  * Hide the evaluation. When the service could not tie an answer to a
   *    source, that is the single most important thing on the screen.
   */

  let lang = $derived($locale);

  // `t` reads the locale store imperatively rather than returning one, so this
  // wrapper reads `lang` to make the call re-run when the locale changes.
  // Without it the page would translate once, at first render, and then stay
  // in whatever language it started in.
  function tr(key: string, vars?: Record<string, string | number>): string {
    void lang;
    return t(`advisory.${key}`, vars);
  }

  const LOCALE_TO_PROTO: Record<string, AdvisoryLocale> = {
    en: AdvisoryLocale.EN,
    hi: AdvisoryLocale.HI,
    mr: AdvisoryLocale.MR,
    te: AdvisoryLocale.TE,
    ta: AdvisoryLocale.TA,
    kn: AdvisoryLocale.KN,
    pa: AdvisoryLocale.PA,
    bn: AdvisoryLocale.BN,
  };

  const LANGUAGE_NAMES: Record<string, string> = {
    en: 'English',
    hi: 'हिन्दी',
    mr: 'मराठी',
    te: 'తెలుగు',
    ta: 'தமிழ்',
    kn: 'ಕನ್ನಡ',
    pa: 'ਪੰਜਾਬੀ',
    bn: 'বাংলা',
  };

  let question = $state('');
  let exchanges = $state<AdvisoryExchange[]>([]);
  let conversationId = $state('');
  let budget = $state<TenantBudget | null>(null);
  let loading = $state(false);
  let error = $state<string | null>(null);

  // The field the question is about, taken from the URL so a link from a field
  // page arrives with its own context. Without it the assistant answers about
  // farming in general rather than about this farm.
  let fieldId = $derived($page.url.searchParams.get('fieldId') ?? '');
  let farmId = $derived($page.url.searchParams.get('farmId') ?? '');

  async function ask() {
    const asked = question.trim();
    if (!asked || loading) return;

    loading = true;
    error = null;
    try {
      const res = await advisoryClient.ask({
        conversationId,
        question: asked,
        locale: LOCALE_TO_PROTO[lang] ?? AdvisoryLocale.EN,
        fieldId,
        farmId,
      });

      conversationId = res.conversationId;
      if (res.exchange) exchanges = [...exchanges, res.exchange];
      budget = res.budget ?? null;
      question = '';
    } catch (e) {
      // The question is left in the box on failure. Clearing it would make a
      // transport error cost the farmer the sentence they just typed.
      error = e instanceof Error ? e.message : tr('failed');
    } finally {
      loading = false;
    }
  }

  function onKeydown(event: KeyboardEvent) {
    // Enter sends, Shift+Enter starts a line. A question describing a problem
    // often runs to several lines.
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      void ask();
    }
  }

  function startNew() {
    conversationId = '';
    exchanges = [];
    error = null;
  }

  /**
   * Split an answer into text and citation markers so each [n] renders as a
   * link to its source.
   *
   * The regex keeps its capture group, so `split` returns the markers as well
   * as the text around them and nothing is lost.
   */
  function segments(answer: string): Array<{ text: string; marker: number | null }> {
    return answer.split(/(\[\d+\])/g).map((part) => {
      const match = /^\[(\d+)\]$/.exec(part);
      return match ? { text: part, marker: Number(match[1]) } : { text: part, marker: null };
    });
  }

  function citationFor(exchange: AdvisoryExchange, marker: number): AdvisoryCitation | undefined {
    return exchange.citations.find((c) => c.marker === marker);
  }

  function answerKindLabel(kind: AnswerKind): string {
    switch (kind) {
      case AnswerKind.GENERATED:
        return tr('kindGenerated');
      case AnswerKind.EXTRACTIVE:
        return tr('kindExtractive');
      case AnswerKind.REFUSED:
        return tr('kindRefused');
      default:
        return '';
    }
  }

  function verdictLabel(verdict: GroundednessVerdict): string {
    switch (verdict) {
      case GroundednessVerdict.GROUNDED:
        return tr('verdictGrounded');
      case GroundednessVerdict.PARTIAL:
        return tr('verdictPartial');
      case GroundednessVerdict.UNGROUNDED:
        return tr('verdictUngrounded');
      default:
        return '';
    }
  }

  // Colour carries the same information as the text, for the reader who scans
  // rather than reads. It never carries it alone.
  function verdictClass(verdict: GroundednessVerdict): string {
    switch (verdict) {
      case GroundednessVerdict.GROUNDED:
        return 'bg-semantic-success-50 text-semantic-success-700 border-semantic-success-200';
      case GroundednessVerdict.PARTIAL:
        return 'bg-semantic-warning-50 text-semantic-warning-700 border-semantic-warning-200';
      case GroundednessVerdict.UNGROUNDED:
        return 'bg-semantic-error-50 text-semantic-error-700 border-semantic-error-200';
      default:
        return 'bg-neutral-50 text-neutral-700 border-neutral-200';
    }
  }

  const CITATION_KIND_LABELS: Record<number, string> = {
    [CitationKind.DOCUMENT]: 'Reference',
    [CitationKind.FIELD]: 'Field record',
    [CitationKind.PRESCRIPTION]: 'Prescription',
    [CitationKind.ALERT]: 'Alert',
    [CitationKind.WEATHER]: 'Weather',
    [CitationKind.DIAGNOSIS]: 'Diagnosis',
    [CitationKind.YIELD_FORECAST]: 'Yield forecast',
    [CitationKind.IRRIGATION]: 'Irrigation decision',
    [CitationKind.PEST_RISK]: 'Pest risk',
    [CitationKind.SOIL]: 'Soil',
  };
</script>

<svelte:head>
  <title>{tr('title')}</title>
</svelte:head>

<main class="mx-auto max-w-4xl px-6 py-8">
  <header class="mb-6">
    <div class="flex items-start justify-between gap-4">
      <div>
        <h1 class="text-2xl font-semibold text-neutral-900">{tr('title')}</h1>
        <p class="mt-1 max-w-2xl text-sm text-neutral-600">{tr('subtitle')}</p>
      </div>
      {#if exchanges.length > 0}
        <button
          type="button"
          class="shrink-0 rounded border border-neutral-300 px-3 py-1.5 text-sm text-neutral-700 hover:bg-neutral-50"
          onclick={startNew}
        >
          {tr('newConversation')}
        </button>
      {/if}
    </div>

    <div class="mt-3 flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-neutral-500">
      <span>{tr('answeredIn', { language: LANGUAGE_NAMES[lang] ?? 'English' })}</span>
      <span>{fieldId ? `${tr('fieldContext')} ${fieldId}` : tr('noField')}</span>
      {#if budget && budget.dailyQuestionLimit > 0}
        <span>
          {tr('budgetRemaining', {
            used: budget.spentQuestions,
            limit: budget.dailyQuestionLimit,
          })}
        </span>
      {/if}
    </div>
  </header>

  {#if budget?.exhausted}
    <p class="mb-4 rounded border border-semantic-warning-200 bg-semantic-warning-50 px-3 py-2 text-sm text-semantic-warning-800">
      {tr('budgetExhausted')}
    </p>
  {/if}

  {#if exchanges.length === 0 && !loading}
    <div class="mb-6 rounded border border-dashed border-neutral-300 px-6 py-10 text-center">
      <p class="text-sm font-medium text-neutral-700">{tr('emptyTitle')}</p>
      <p class="mx-auto mt-1 max-w-md text-sm text-neutral-500">{tr('emptyBody')}</p>
    </div>
  {/if}

  <div class="flex flex-col gap-6">
    {#each exchanges as exchange (exchange.id)}
      <article class="rounded border border-neutral-200">
        <p class="border-b border-neutral-200 bg-neutral-50 px-4 py-3 text-sm font-medium text-neutral-900">
          {exchange.question}
        </p>

        <div class="px-4 py-3">
          <!--
            How the answer was produced, above the answer itself. A reader who
            stops after the first line should already know whether they are
            reading advice or a quotation.
          -->
          <p class="mb-2 text-xs text-neutral-500">{answerKindLabel(exchange.answerKind)}</p>

          <p class="whitespace-pre-wrap text-sm text-neutral-800">
            {#each segments(exchange.answer) as segment}
              {#if segment.marker !== null}
                {@const cited = citationFor(exchange, segment.marker)}
                {#if cited?.uri}
                  <a
                    href={cited.uri}
                    class="mx-0.5 rounded bg-brand-primary-50 px-1 text-xs font-medium text-brand-primary-700 no-underline hover:bg-brand-primary-100"
                    title={cited.title}
                  >{segment.text}</a>
                {:else}
                  <!--
                    A marker with no matching citation is shown as plain text
                    rather than as a dead link. It means the model invented the
                    number, and a link that goes nowhere hides that.
                  -->
                  <span class="mx-0.5 text-xs text-neutral-400">{segment.text}</span>
                {/if}
              {:else}{segment.text}{/if}
            {/each}
          </p>

          {#if exchange.evaluation}
            {@const evaluation = exchange.evaluation}
            <div class="mt-3 rounded border px-3 py-2 text-xs {verdictClass(evaluation.verdict)}">
              <p class="font-medium">{verdictLabel(evaluation.verdict)}</p>
              {#if evaluation.unsupportedNumbers.length > 0}
                <p class="mt-1">
                  {tr('unsupportedNumbers', { numbers: evaluation.unsupportedNumbers.join(', ') })}
                </p>
              {/if}
              {#if evaluation.needsReview}
                <p class="mt-1">{tr('reviewFlagged')}</p>
              {/if}
            </div>
          {/if}

          {#if exchange.citations.length > 0}
            <section class="mt-4">
              <h2 class="mb-2 text-xs font-semibold uppercase tracking-wide text-neutral-500">
                {tr('sources')}
              </h2>
              <ol class="flex flex-col gap-2">
                {#each exchange.citations as citation (citation.id)}
                  <li class="rounded border border-neutral-200 px-3 py-2">
                    <div class="flex items-baseline gap-2">
                      <span class="text-xs font-medium text-brand-primary-700">[{citation.marker}]</span>
                      <span class="text-xs uppercase tracking-wide text-neutral-400">
                        {CITATION_KIND_LABELS[citation.kind] ?? ''}
                      </span>
                    </div>
                    <p class="mt-0.5 text-sm text-neutral-800">{citation.title}</p>
                    <!--
                      The snippet is what the model was actually shown. A
                      reviewer checking the answer needs this rather than the
                      whole source, and a farmer deciding whether to trust a
                      number can read the sentence it came from.
                    -->
                    <p class="mt-1 line-clamp-3 whitespace-pre-wrap text-xs text-neutral-500">
                      {citation.snippet}
                    </p>
                    {#if citation.uri}
                      <a
                        href={citation.uri}
                        class="mt-1 inline-block text-xs text-brand-primary-600 hover:underline"
                      >
                        {citation.uri}
                      </a>
                    {/if}
                  </li>
                {/each}
              </ol>
            </section>
          {/if}

          {#if exchange.toolCalls.length > 0}
            <section class="mt-4">
              <h2 class="mb-2 text-xs font-semibold uppercase tracking-wide text-neutral-500">
                {tr('toolsUsed')}
              </h2>
              <ul class="flex flex-wrap gap-1.5">
                {#each exchange.toolCalls as call}
                  <li
                    class="rounded border px-2 py-0.5 text-xs {call.ok
                      ? 'border-neutral-200 text-neutral-600'
                      : 'border-semantic-error-200 bg-semantic-error-50 text-semantic-error-700'}"
                    title={call.ok ? call.resultJson : call.error}
                  >
                    {call.name}
                    <!--
                      A failed lookup is shown, not hidden. An answer given
                      without the field's open alerts because alert-service was
                      down is a different answer, and only this says so.
                    -->
                    {#if !call.ok}✕{/if}
                  </li>
                {/each}
              </ul>
            </section>
          {/if}

          {#if exchange.usage}
            <p class="mt-3 text-xs text-neutral-400">
              {tr('latency', { ms: Number(exchange.usage.latencyMs) })}
              {#if exchange.usage.model}· {exchange.usage.model}{/if}
            </p>
          {/if}
        </div>
      </article>
    {/each}
  </div>

  {#if loading}
    <p class="mt-4 text-sm text-neutral-500">{tr('thinking')}</p>
  {/if}

  {#if error}
    <p class="mt-4 rounded border border-semantic-error-200 bg-semantic-error-50 px-3 py-2 text-sm text-semantic-error-700">
      {error}
    </p>
  {/if}

  <form
    class="mt-6 flex items-end gap-2"
    onsubmit={(event) => {
      event.preventDefault();
      void ask();
    }}
  >
    <textarea
      bind:value={question}
      onkeydown={onKeydown}
      rows="2"
      placeholder={tr('askPlaceholder')}
      class="flex-1 resize-y rounded border border-neutral-300 px-3 py-2 text-sm text-neutral-900 focus:border-brand-primary-500 focus:outline-none"
    ></textarea>
    <button
      type="submit"
      disabled={loading || question.trim() === ''}
      class="rounded bg-brand-primary-500 px-4 py-2 text-sm font-medium text-white disabled:cursor-not-allowed disabled:opacity-50"
    >
      {tr('send')}
    </button>
  </form>
</main>
