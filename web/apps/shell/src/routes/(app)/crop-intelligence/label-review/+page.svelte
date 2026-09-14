<script lang="ts">
  import { onDestroy, onMount } from 'svelte';
  import { diagnosisClient } from '@samavāya/agriculture/services';
  import {
    LabelReviewDecision,
    type LabelReviewSample,
    type ReviewAgreement,
  } from '@samavāya/agriculture/types';

  // Human-in-the-loop label review. Samples come from the AI gateway's training
  // store (proxied tenant-scoped by plant-diagnosis-service), lowest-confidence
  // first so reviewer time goes where the model is least sure.

  const TASKS = [
    { value: 'disease', label: 'Disease' },
    { value: 'pest', label: 'Pest' },
    { value: 'nutrient_deficiency', label: 'Nutrient deficiency' },
    { value: 'plant_classification', label: 'Plant species' },
  ];
  const PAGE_SIZE = 25;

  let task = 'disease';
  let includeReviewed = false;
  let newestFirst = false;
  // Labels a trained model confidently contradicted. These are usually wrong
  // data rather than hard images, and a wrong label teaches the next model the
  // same mistake — so they are worth a reviewer's time before anything else.
  let suspectOnly = false;
  // Samples where two reviewers already disagreed, or where one asked for
  // another pair of eyes. A disagreement is a question, not a failure.
  let secondOpinionOnly = false;
  let agreement: ReviewAgreement | null = null;

  let samples: LabelReviewSample[] = [];
  let totalCount = 0;
  let unreviewedCount = 0;
  let pageOffset = 0;
  let loading = false;
  let error: string | null = null;
  let notice: string | null = null;

  let selected: LabelReviewSample | null = null;
  let imageUrl: string | null = null;
  let imageLoading = false;
  let correctedLabel = '';
  let notes = '';
  let submitting = false;

  $: totalPages = totalCount > 0 ? Math.ceil(totalCount / PAGE_SIZE) : 1;
  $: currentPage = Math.floor(pageOffset / PAGE_SIZE);

  function pct(v: number | undefined): string {
    return v == null ? '—' : `${Math.round(v * 100)}%`;
  }

  function when(ts: { seconds: bigint | number } | undefined): string {
    if (!ts) return '—';
    return new Date(Number(ts.seconds) * 1000).toLocaleString();
  }

  function decisionLabel(d: LabelReviewDecision | undefined): string {
    switch (d) {
      case LabelReviewDecision.CONFIRMED:
        return 'Confirmed';
      case LabelReviewDecision.CORRECTED:
        return 'Corrected';
      case LabelReviewDecision.REJECTED:
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  function releaseImage() {
    if (imageUrl) {
      URL.revokeObjectURL(imageUrl);
      imageUrl = null;
    }
  }

  async function loadQueue(offset = 0) {
    loading = true;
    error = null;
    pageOffset = offset;
    try {
      const res = await diagnosisClient.listLabelReviewQueue({
        task,
        includeReviewed,
        newestFirst,
        suspectOnly,
        secondOpinionOnly,
        pageSize: PAGE_SIZE,
        pageOffset: offset,
      });
      samples = res.samples;
      totalCount = res.totalCount;
      unreviewedCount = res.unreviewedCount;
      void loadAgreement();
      if (samples.length > 0) {
        await select(samples[0]);
      } else {
        selected = null;
        releaseImage();
      }
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load the review queue';
      samples = [];
      selected = null;
      releaseImage();
    } finally {
      loading = false;
    }
  }

  // How much two reviewers agree on this task, and whether that is more than
  // chance. Raw agreement flatters an imbalanced set; kappa is the number to
  // read.
  async function loadAgreement() {
    try {
      const res = await diagnosisClient.getReviewAgreement({ task });
      agreement = res.agreement ?? null;
    } catch {
      // A missing agreement is not worth interrupting the queue for.
      agreement = null;
    }
  }

  async function askSecondOpinion() {
    if (!selected) return;
    try {
      const res = await diagnosisClient.requestSecondOpinion({
        task: selected.task,
        sampleId: selected.id,
        wanted: !selected.needsSecondOpinion,
      });
      if (res.sample) selected = res.sample;
      notice = selected.needsSecondOpinion
        ? 'Flagged for another reviewer.'
        : 'Second-opinion flag cleared.';
    } catch (e) {
      error = e instanceof Error ? e.message : 'Could not flag this sample';
    }
  }

  async function select(sample: LabelReviewSample) {
    selected = sample;
    correctedLabel = '';
    notes = '';
    notice = null;
    releaseImage();
    imageLoading = true;
    try {
      const res = await diagnosisClient.getLabelReviewImage({ task: sample.task, sampleId: sample.id });
      const blob = new Blob([res.imageBytes], { type: res.mimeType || 'image/jpeg' });
      imageUrl = URL.createObjectURL(blob);
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load the sample image';
    } finally {
      imageLoading = false;
    }
  }

  async function submit(decision: LabelReviewDecision) {
    if (!selected) return;
    if (decision === LabelReviewDecision.CORRECTED && !correctedLabel.trim()) {
      error = 'Enter the corrected label first';
      return;
    }
    submitting = true;
    error = null;
    const reviewed = selected;
    try {
      const res = await diagnosisClient.submitLabelReview({
        task: reviewed.task,
        sampleId: reviewed.id,
        decision,
        correctedLabel: correctedLabel.trim(),
        notes: notes.trim(),
      });
      notice = `${decisionLabel(decision)}: ${res.sample?.effectiveLabel || reviewed.effectiveLabel || 'sample'}`;
      const idx = samples.findIndex((s) => s.id === reviewed.id);
      if (includeReviewed && res.sample) {
        samples = samples.map((s) => (s.id === reviewed.id ? res.sample! : s));
      } else {
        samples = samples.filter((s) => s.id !== reviewed.id);
        totalCount = Math.max(0, totalCount - 1);
      }
      unreviewedCount = Math.max(0, unreviewedCount - (reviewed.review ? 0 : 1));
      const next = samples[Math.min(idx, samples.length - 1)];
      if (next) {
        await select(next);
      } else if (totalCount > pageOffset) {
        await loadQueue(pageOffset);
      } else {
        selected = null;
        releaseImage();
      }
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to submit the review';
    } finally {
      submitting = false;
    }
  }

  onMount(() => loadQueue(0));
  onDestroy(releaseImage);
</script>

<div class="p-6">
  <div class="mb-6 flex flex-wrap items-end justify-between gap-4">
    <div>
      <h1 class="text-2xl font-semibold text-gray-900">Label Review</h1>
      <p class="mt-1 text-sm text-gray-500">
        Confirm, correct, or reject AI auto-labels before they are used for training.
        Lowest-confidence samples are shown first.
      </p>
    </div>
    <div class="flex flex-wrap items-center gap-3 text-sm">
      <label class="flex items-center gap-2">
        <span class="text-gray-600">Task</span>
        <select
          bind:value={task}
          on:change={() => loadQueue(0)}
          class="rounded-md border border-gray-300 px-2 py-1.5 text-sm focus:border-green-500 focus:outline-none"
        >
          {#each TASKS as t}
            <option value={t.value}>{t.label}</option>
          {/each}
        </select>
      </label>
      <label class="flex items-center gap-2 text-gray-600">
        <input type="checkbox" bind:checked={includeReviewed} on:change={() => loadQueue(0)} />
        Show reviewed
      </label>
      <label class="flex items-center gap-2 text-gray-600">
        <input type="checkbox" bind:checked={newestFirst} on:change={() => loadQueue(0)} />
        Newest first
      </label>
      <label class="flex items-center gap-2 text-gray-600" title="Labels a trained model disagreed with">
        <input type="checkbox" bind:checked={suspectOnly} on:change={() => loadQueue(0)} />
        Model-disputed only
      </label>
      <label class="flex items-center gap-2 text-gray-600" title="Samples where reviewers disagreed or a second opinion was asked for">
        <input type="checkbox" bind:checked={secondOpinionOnly} on:change={() => loadQueue(0)} />
        Needs a second opinion
      </label>
      <span class="rounded-full bg-amber-50 px-3 py-1 text-xs font-medium text-amber-700">
        {unreviewedCount} awaiting review
      </span>
      {#if agreement && agreement.compared > 0}
        <span
          class="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-700"
          title="Cohen's kappa over {agreement.compared} samples two people both reviewed. Raw agreement of {Math.round(agreement.rawAgreement * 100)}% flatters an imbalanced set; kappa measures agreement above chance."
        >
          reviewer agreement: {agreement.kappa.toFixed(2)} ({agreement.strength})
        </span>
      {/if}
    </div>
  </div>

  {#if error}
    <div class="mb-4 rounded-md border border-red-200 bg-red-50 p-4 text-sm text-red-600">{error}</div>
  {/if}
  {#if notice}
    <div class="mb-4 rounded-md border border-green-200 bg-green-50 p-3 text-sm text-green-700">{notice}</div>
  {/if}

  <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
    <!-- Queue -->
    <div class="overflow-hidden rounded-lg border border-gray-200 bg-white shadow-sm">
      {#if loading}
        <div class="flex items-center justify-center py-12 text-sm text-gray-500">Loading...</div>
      {:else if samples.length === 0}
        <div class="flex flex-col items-center justify-center py-12 text-sm text-gray-500">
          <p>Nothing to review</p>
          <p class="mt-1 text-xs text-gray-400">New samples appear as diagnoses are submitted.</p>
        </div>
      {:else}
        <ul class="max-h-[70vh] divide-y divide-gray-50 overflow-y-auto">
          {#each samples as s (s.id)}
            <li>
              <button
                type="button"
                class="w-full px-4 py-3 text-left transition-colors hover:bg-gray-50
                       {selected?.id === s.id ? 'bg-green-50' : ''}"
                on:click={() => select(s)}
              >
                <div class="flex items-center justify-between gap-2">
                  <span class="truncate text-sm font-medium text-gray-800">
                    {s.effectiveLabel || s.labels[0]?.name || 'unlabelled'}
                  </span>
                  <span class="shrink-0 text-xs text-gray-500">{pct(s.topConfidence)}</span>
                </div>
                <div class="mt-1 flex items-center gap-2 text-xs text-gray-500">
                  <span class="rounded bg-gray-100 px-1.5 py-0.5">{s.provenance || 'unknown'}</span>
                  {#if s.crop}<span>{s.crop}</span>{/if}
                  {#if s.review}
                    <span class="ml-auto text-green-600">{decisionLabel(s.review.decision)}</span>
                  {/if}
                </div>
              </button>
            </li>
          {/each}
        </ul>
      {/if}
      <div class="flex items-center justify-between border-t border-gray-100 px-4 py-2 text-xs text-gray-500">
        <span>{totalCount} total</span>
        <div class="flex items-center gap-2">
          <button
            type="button"
            class="rounded border border-gray-300 px-2 py-1 disabled:opacity-40"
            disabled={currentPage === 0 || loading}
            on:click={() => loadQueue(Math.max(0, pageOffset - PAGE_SIZE))}
          >
            Prev
          </button>
          <span>{currentPage + 1} / {totalPages}</span>
          <button
            type="button"
            class="rounded border border-gray-300 px-2 py-1 disabled:opacity-40"
            disabled={currentPage >= totalPages - 1 || loading}
            on:click={() => loadQueue(pageOffset + PAGE_SIZE)}
          >
            Next
          </button>
        </div>
      </div>
    </div>

    <!-- Sample detail -->
    <div class="lg:col-span-2">
      {#if selected}
        <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
          <div class="overflow-hidden rounded-lg border border-gray-200 bg-white shadow-sm">
            {#if imageLoading}
              <div class="flex h-72 items-center justify-center text-sm text-gray-500">Loading image...</div>
            {:else if imageUrl}
              <img src={imageUrl} alt="Sample {selected.id}" class="max-h-[60vh] w-full object-contain bg-gray-50" />
            {:else}
              <div class="flex h-72 items-center justify-center text-sm text-gray-400">Image unavailable</div>
            {/if}
          </div>

          <div class="space-y-4">
            <div class="rounded-lg border border-gray-200 bg-white p-4 shadow-sm">
              <h2 class="mb-3 text-sm font-semibold text-gray-700">Auto-labels</h2>
              <ul class="space-y-1 text-sm">
                {#each selected.labels as l}
                  <li class="flex items-center justify-between">
                    <span class="text-gray-800">
                      {l.name}
                      {#if l.severity}<span class="ml-1 text-xs text-gray-400">({l.severity})</span>{/if}
                    </span>
                    <span class="text-gray-500">{pct(l.confidence)}</span>
                  </li>
                {:else}
                  <li class="text-gray-400">No labels recorded</li>
                {/each}
              </ul>
              {#if selected.needsSecondOpinion}
                <div class="mt-4 rounded border border-sky-300 bg-sky-50 p-3 text-xs text-sky-900">
                  <p class="font-semibold">This sample is waiting on another reviewer</p>
                  <p class="mt-1">
                    Either two reviewers chose different labels, or someone asked for a second
                    opinion. Your verdict settles it.
                  </p>
                </div>
              {/if}
              {#if selected.reviews && selected.reviews.length > 1}
                <div class="mt-3 rounded border border-gray-200 p-3 text-xs">
                  <p class="font-semibold text-gray-700">Previous verdicts</p>
                  <ul class="mt-1 space-y-1 text-gray-600">
                    {#each selected.reviews as r}
                      <li>
                        {r.reviewerId || 'unknown'}: {decisionLabel(r.decision)}
                        {#if r.correctedLabel}→ <strong>{r.correctedLabel}</strong>{/if}
                      </li>
                    {/each}
                  </ul>
                </div>
              {/if}
              {#if selected.suspect}
                <div class="mt-4 rounded border border-amber-300 bg-amber-50 p-3 text-xs text-amber-900">
                  <p class="font-semibold">A trained model disagrees with this label</p>
                  <p class="mt-1">
                    {selected.suspect.modelVersion || 'A model'} predicted
                    <strong>{selected.suspect.predicted}</strong>
                    at {pct(selected.suspect.predictedProb)}, giving the stored label only
                    {pct(selected.suspect.labelProb)}.
                  </p>
                  <p class="mt-1 text-amber-800">
                    That usually means the label is wrong rather than the image hard. Confirm it or
                    correct it — leaving it teaches the next model the same mistake.
                  </p>
                </div>
              {/if}
              <dl class="mt-4 grid grid-cols-2 gap-x-4 gap-y-1 text-xs text-gray-500">
                <dt>Source</dt>
                <dd class="text-gray-700">{selected.provenance || '—'} · {selected.provider || '—'}</dd>
                <dt>Collected</dt>
                <dd class="text-gray-700">{when(selected.collectedAt)}</dd>
                <dt>Crop</dt>
                <dd class="text-gray-700">{selected.crop || '—'}</dd>
                <dt>Field</dt>
                <dd class="text-gray-700">{selected.fieldId || '—'}</dd>
                <dt>Sample</dt>
                <dd class="truncate font-mono text-gray-700" title={selected.id}>{selected.id.slice(0, 16)}…</dd>
              </dl>
              {#if selected.review}
                <p class="mt-3 rounded bg-gray-50 p-2 text-xs text-gray-600">
                  {decisionLabel(selected.review.decision)} by {selected.review.reviewerId || 'unknown'}
                  on {when(selected.review.reviewedAt)}
                  {#if selected.review.correctedLabel}→ <strong>{selected.review.correctedLabel}</strong>{/if}
                  {#if selected.review.notes}<br />{selected.review.notes}{/if}
                </p>
              {/if}
            </div>

            <div class="rounded-lg border border-gray-200 bg-white p-4 shadow-sm">
              <h2 class="mb-3 text-sm font-semibold text-gray-700">Your decision</h2>
              <label class="block text-xs text-gray-600">
                Corrected label
                <input
                  type="text"
                  bind:value={correctedLabel}
                  placeholder="e.g. leaf_spot"
                  class="mt-1 w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-green-500 focus:outline-none"
                />
              </label>
              <label class="mt-3 block text-xs text-gray-600">
                Notes
                <textarea
                  bind:value={notes}
                  rows="2"
                  class="mt-1 w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-green-500 focus:outline-none"
                ></textarea>
              </label>
              <div class="mt-4 flex flex-wrap gap-2">
                <button
                  type="button"
                  class="rounded-md bg-green-600 px-4 py-2 text-sm font-medium text-white hover:bg-green-700 disabled:opacity-50"
                  disabled={submitting}
                  on:click={() => submit(LabelReviewDecision.CONFIRMED)}
                >
                  Confirm
                </button>
                <button
                  type="button"
                  class="rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50"
                  disabled={submitting || !correctedLabel.trim()}
                  on:click={() => submit(LabelReviewDecision.CORRECTED)}
                >
                  Correct
                </button>
                <button
                  type="button"
                  class="rounded-md border border-red-300 px-4 py-2 text-sm font-medium text-red-600 hover:bg-red-50 disabled:opacity-50"
                  disabled={submitting}
                  on:click={() => submit(LabelReviewDecision.REJECTED)}
                >
                  Reject
                </button>
                <button
                  type="button"
                  class="rounded-md border border-sky-300 px-4 py-2 text-sm font-medium text-sky-700 hover:bg-sky-50 disabled:opacity-50"
                  disabled={submitting}
                  title="Send this sample to another reviewer instead of deciding it alone"
                  on:click={askSecondOpinion}
                >
                  {selected.needsSecondOpinion ? 'Clear second opinion' : 'Ask a second reviewer'}
                </button>
              </div>
            </div>
          </div>
        </div>
      {:else if !loading}
        <div class="flex h-72 items-center justify-center rounded-lg border border-dashed border-gray-200 text-sm text-gray-400">
          Select a sample to review
        </div>
      {/if}
    </div>
  </div>
</div>
