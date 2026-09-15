<script lang="ts">
  import { onDestroy } from 'svelte';
  import { diagnosisClient } from '@samavāya/agriculture/services';
  import type { Explanation, NutrientDeficiency, PestDamage } from '@samavāya/agriculture/types';

  // Run the vision models over a field photo and show not just what they found
  // but where they looked. The heatmap comes from Grad-CAM over the serving
  // model's own feature map, so it is the evidence the answer was actually
  // based on — the difference between a result a farmer can check and one they
  // have to take on trust.

  type Analysis = 'pest' | 'nutrient';

  let imageUrl = '';
  let plantSpeciesId = '';
  let analysis: Analysis = 'pest';

  let pests: PestDamage[] = [];
  let deficiencies: NutrientDeficiency[] = [];
  let explanations: Explanation[] = [];
  let modelVersion = '';
  let ran = false;
  let running = false;
  let error: string | null = null;

  let selectedExplanation = 0;
  let overlayOpacity = 0.6;
  let showOverlay = true;
  let overlayUrl: string | null = null;

  $: current = explanations[selectedExplanation];
  $: if (current) void renderOverlay(current);

  function pct(v: number | undefined): string {
    return v == null ? '—' : `${Math.round(v * 100)}%`;
  }

  function severityLabel(v: number | undefined): string {
    // The proto enum is numeric; 0 means the model did not commit to a level.
    return ['Unspecified', 'Mild', 'Moderate', 'Severe', 'Critical'][v ?? 0] ?? 'Unspecified';
  }

  function releaseOverlay() {
    if (overlayUrl) {
      URL.revokeObjectURL(overlayUrl);
      overlayUrl = null;
    }
  }

  /**
   * Turn the greyscale Grad-CAM PNG into a colour overlay.
   *
   * The map arrives as intensity only. Painting it as a warm ramp whose alpha
   * follows the intensity keeps the photo readable underneath: cold areas stay
   * fully transparent rather than greying out parts of the leaf the model
   * simply did not use.
   */
  async function renderOverlay(explanation: Explanation) {
    releaseOverlay();
    if (!explanation.heatmapPng || explanation.heatmapPng.length === 0) return;

    const blob = new Blob([new Uint8Array(explanation.heatmapPng).slice().buffer], { type: 'image/png' });
    const bitmap = await createImageBitmap(blob);
    const canvas = document.createElement('canvas');
    canvas.width = bitmap.width;
    canvas.height = bitmap.height;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;
    ctx.drawImage(bitmap, 0, 0);
    bitmap.close();

    const pixels = ctx.getImageData(0, 0, canvas.width, canvas.height);
    const d = pixels.data;
    for (let i = 0; i < d.length; i += 4) {
      const t = d[i] / 255; // greyscale: all three channels are equal
      // Blue (cool, low evidence) through yellow to red (hot).
      d[i] = Math.round(255 * Math.min(1, t * 2));
      d[i + 1] = Math.round(255 * Math.max(0, Math.min(1, 1.6 - Math.abs(t - 0.5) * 3.2)));
      d[i + 2] = Math.round(255 * Math.max(0, 1 - t * 2));
      // Fade out entirely where there is no evidence.
      d[i + 3] = Math.round(255 * Math.min(1, t * 1.4));
    }
    ctx.putImageData(pixels, 0, 0);

    const out = await new Promise<Blob | null>((resolve) => canvas.toBlob(resolve, 'image/png'));
    if (out) overlayUrl = URL.createObjectURL(out);
  }

  async function run() {
    if (!imageUrl.trim()) {
      error = 'Enter the URL of an image to analyse.';
      return;
    }
    running = true;
    error = null;
    releaseOverlay();
    pests = [];
    deficiencies = [];
    explanations = [];
    selectedExplanation = 0;

    const images = [{ imageUrl: imageUrl.trim(), mimeType: '' }];
    try {
      if (analysis === 'pest') {
        const res = await diagnosisClient.detectPestDamage({ plantSpeciesId, images });
        pests = res.pests;
        explanations = res.explanations;
        modelVersion = res.aiModelVersion;
      } else {
        const res = await diagnosisClient.detectNutrientDeficiency({ plantSpeciesId, images });
        deficiencies = res.deficiencies;
        explanations = res.explanations;
        modelVersion = res.aiModelVersion;
      }
      ran = true;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Analysis failed';
    } finally {
      running = false;
    }
  }

  onDestroy(releaseOverlay);
</script>

<svelte:head><title>Image analysis · Crop intelligence</title></svelte:head>

<div class="mx-auto max-w-6xl p-6">
  <header class="mb-6">
    <h1 class="text-xl font-semibold text-gray-900">Image analysis</h1>
    <p class="mt-1 text-sm text-gray-600">
      Run a field photo through the vision models and see what the answer was based on.
    </p>
  </header>

  <div class="mb-6 rounded-lg border border-gray-200 bg-white p-4 shadow-sm">
    <div class="grid gap-4 sm:grid-cols-[1fr_auto_auto_auto]">
      <label class="block text-xs text-gray-600">
        Image URL
        <input
          type="url"
          bind:value={imageUrl}
          placeholder="https://…/leaf.jpg"
          class="mt-1 w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-green-500 focus:outline-none"
        />
      </label>
      <label class="block text-xs text-gray-600">
        Species (optional)
        <input
          type="text"
          bind:value={plantSpeciesId}
          class="mt-1 w-40 rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-green-500 focus:outline-none"
        />
      </label>
      <label class="block text-xs text-gray-600">
        Analysis
        <select
          bind:value={analysis}
          class="mt-1 rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-green-500 focus:outline-none"
        >
          <option value="pest">Pest damage</option>
          <option value="nutrient">Nutrient deficiency</option>
        </select>
      </label>
      <button
        type="button"
        on:click={run}
        disabled={running}
        class="mt-5 h-10 rounded-md bg-green-600 px-4 text-sm font-medium text-white hover:bg-green-700 disabled:opacity-50"
      >
        {running ? 'Analysing…' : 'Analyse'}
      </button>
    </div>
    {#if error}
      <p class="mt-3 rounded bg-red-50 p-2 text-sm text-red-700">{error}</p>
    {/if}
  </div>

  {#if ran}
    <div class="grid gap-6 lg:grid-cols-2">
      <!-- What the model looked at -->
      <div class="rounded-lg border border-gray-200 bg-white p-4 shadow-sm">
        <h2 class="mb-3 text-sm font-semibold text-gray-700">Why this result</h2>

        {#if explanations.length === 0}
          <p class="rounded bg-amber-50 p-3 text-sm text-amber-800">
            This answer came from a model that cannot explain itself — a demo detector or an
            external provider. No heatmap is shown rather than a made-up one.
          </p>
        {:else}
          {#if explanations.length > 1}
            <div class="mb-3 flex gap-2">
              {#each explanations as e, i}
                <button
                  type="button"
                  on:click={() => (selectedExplanation = i)}
                  class="rounded px-2 py-1 text-xs {selectedExplanation === i
                    ? 'bg-green-600 text-white'
                    : 'bg-gray-100 text-gray-700'}"
                >
                  Image {i + 1}
                </button>
              {/each}
            </div>
          {/if}

          <figure class="relative overflow-hidden rounded-md border border-gray-200 bg-gray-50">
            <img src={imageUrl} alt="Analysed leaf" class="block w-full" />
            {#if showOverlay && overlayUrl}
              <img
                src={overlayUrl}
                alt="Heatmap of the regions the model used"
                style="opacity: {overlayOpacity}"
                class="pointer-events-none absolute inset-0 h-full w-full"
              />
            {/if}
            {#if showOverlay && current?.localised}
              <div
                class="pointer-events-none absolute border-2 border-white shadow-[0_0_0_1px_rgba(0,0,0,0.6)]"
                style="left: {current.focusX * 100}%; top: {current.focusY * 100}%;
                       width: {current.focusWidth * 100}%; height: {current.focusHeight * 100}%"
              ></div>
            {/if}
          </figure>

          <div class="mt-3 flex items-center gap-3">
            <label class="flex items-center gap-2 text-xs text-gray-600">
              <input type="checkbox" bind:checked={showOverlay} /> Show heatmap
            </label>
            <input
              type="range"
              min="0"
              max="1"
              step="0.05"
              bind:value={overlayOpacity}
              disabled={!showOverlay}
              class="flex-1"
              aria-label="Heatmap opacity"
            />
          </div>

          {#if current}
            <p class="mt-3 text-sm text-gray-800">{current.summary}</p>
            <dl class="mt-2 grid grid-cols-[auto_1fr] gap-x-3 gap-y-1 text-xs text-gray-500">
              <dt>Explains</dt>
              <dd class="text-gray-700">{current.className}</dd>
              <dt>Area used</dt>
              <dd class="text-gray-700">{pct(current.focusCoverage)} of the image</dd>
              <dt>Method</dt>
              <dd class="text-gray-700">{current.method}</dd>
            </dl>
            {#if !current.localised}
              <p class="mt-2 rounded bg-gray-50 p-2 text-xs text-gray-600">
                The model spread its attention over the whole image rather than any one area, so
                there is nothing specific to point at here.
              </p>
            {/if}
          {/if}
        {/if}
      </div>

      <!-- What it found -->
      <div class="rounded-lg border border-gray-200 bg-white p-4 shadow-sm">
        <h2 class="mb-3 text-sm font-semibold text-gray-700">
          Findings
          {#if modelVersion}<span class="ml-2 font-normal text-xs text-gray-500">{modelVersion}</span
            >{/if}
        </h2>

        {#if analysis === 'pest'}
          {#if pests.length === 0}
            <p class="text-sm text-gray-600">No pest damage detected.</p>
          {:else}
            <ul class="space-y-3">
              {#each pests as p}
                <li class="rounded border border-gray-200 p-3">
                  <div class="flex items-baseline justify-between">
                    <span class="font-medium text-gray-900">{p.pestName}</span>
                    <span class="text-sm text-gray-600">{pct(p.confidenceScore)}</span>
                  </div>
                  {#if p.scientificName}
                    <p class="text-xs italic text-gray-500">{p.scientificName}</p>
                  {/if}
                  <p class="mt-1 text-xs text-gray-600">
                    Damage: {severityLabel(p.damageLevel)}
                    {#if p.damagePattern}· {p.damagePattern}{/if}
                  </p>
                  {#if p.controlMethods?.length}
                    <p class="mt-1 text-xs text-gray-600">
                      Control: {p.controlMethods.join(', ')}
                    </p>
                  {/if}
                </li>
              {/each}
            </ul>
          {/if}
        {:else if deficiencies.length === 0}
          <p class="text-sm text-gray-600">No nutrient deficiency detected.</p>
        {:else}
          <ul class="space-y-3">
            {#each deficiencies as d}
              <li class="rounded border border-gray-200 p-3">
                <div class="flex items-baseline justify-between">
                  <span class="font-medium text-gray-900">{d.nutrient}</span>
                  <span class="text-sm text-gray-600">{pct(d.confidenceScore)}</span>
                </div>
                <p class="mt-1 text-xs text-gray-600">
                  Severity: {severityLabel(d.severity)}
                </p>
                {#if d.visualSymptoms}
                  <p class="mt-1 text-xs text-gray-600">{d.visualSymptoms}</p>
                {/if}
                {#if d.recommendedFertilizers?.length}
                  <p class="mt-1 text-xs text-gray-600">
                    Suggested: {d.recommendedFertilizers.join(', ')}
                  </p>
                {/if}
              </li>
            {/each}
          </ul>
        {/if}

        <p class="mt-4 text-xs text-gray-500">
          Confidence is the model's own estimate. Check it against the heatmap: a high score over
          the wrong part of the plant is a wrong answer, however sure it sounds.
        </p>
      </div>
    </div>
  {/if}
</div>
