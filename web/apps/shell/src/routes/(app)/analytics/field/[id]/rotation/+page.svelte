<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { analyticsClient } from '@samavāya/agriculture/services';

  let rotation: Record<string, unknown> = {};
  let rotationPattern: any[] = [];
  let recommendations: string[] = [];
  let loading = true;
  let error: string | null = null;

  $: id = $page.params.id;

  $: if (id) loadData(id);

  async function loadData(fieldId: string) {
    loading = true;
    error = null;
    try {
      const res = await analyticsClient.getRotationAnalysis({ fieldId });
      rotation = res as any || {};
      rotationPattern = (res as any).rotationPattern || [];
      recommendations = (res as any).recommendations || [];
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load rotation analysis';
    } finally {
      loading = false;
    }
  }

  function scoreColor(score: number): string {
    if (score >= 80) return '#16a34a';
    if (score >= 60) return '#f59e0b';
    if (score >= 40) return '#f97316';
    return '#dc2626';
  }
</script>

<div class="page-container">
  <header class="page-header">
    <div class="header-row">
      <div>
        <h1>Rotation Analysis</h1>
        <p class="subtitle">Crop rotation patterns and effectiveness for field {id}</p>
      </div>
      <button
        class="rounded-md bg-gray-200 px-4 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-300"
        on:click={() => goto(`/analytics/field/${id}`)}
      >Back to Field Analytics</button>
    </div>
  </header>

  {#if loading}
    <div class="page-content">
      <p>Loading...</p>
    </div>
  {:else if error}
    <div class="page-content error-banner">
      <p>{error}</p>
    </div>
  {:else}
    <!-- Effectiveness Score Gauge -->
    <div class="page-content">
      <h2 class="section-title">Effectiveness Score</h2>
      <div class="gauge-container">
        <div class="gauge">
          <svg viewBox="0 0 120 70" class="gauge-svg">
            <path d="M10 60 A50 50 0 0 1 110 60" fill="none" stroke="#e5e7eb" stroke-width="8" stroke-linecap="round" />
            <path
              d="M10 60 A50 50 0 0 1 110 60"
              fill="none"
              stroke={scoreColor(Number(rotation.effectivenessScore) || 0)}
              stroke-width="8"
              stroke-linecap="round"
              stroke-dasharray="{((Number(rotation.effectivenessScore) || 0) / 100) * 157} 157"
            />
          </svg>
          <span class="gauge-value" style="color: {scoreColor(Number(rotation.effectivenessScore) || 0)}">
            {rotation.effectivenessScore ?? '—'}
          </span>
          <span class="gauge-label">out of 100</span>
        </div>
        <div class="score-details">
          <div class="detail-field">
            <span class="detail-label">Diversity Index</span>
            <span class="detail-value">{rotation.diversityIndex ?? '—'}</span>
          </div>
          <div class="detail-field">
            <span class="detail-label">Rotation Length</span>
            <span class="detail-value">{rotation.rotationLength ?? '—'} <small>years</small></span>
          </div>
          <div class="detail-field">
            <span class="detail-label">Soil Health Impact</span>
            <span class="detail-value">{rotation.soilHealthImpact ?? '—'}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Rotation Pattern Timeline -->
    <div class="page-content mt-4">
      <h2 class="section-title">Rotation Pattern</h2>
      {#if rotationPattern.length > 0}
        <div class="timeline">
          {#each rotationPattern as entry, i}
            <div class="timeline-item">
              <div class="timeline-dot" class:active={i === 0}></div>
              {#if i < rotationPattern.length - 1}
                <div class="timeline-line"></div>
              {/if}
              <div class="timeline-content">
                <span class="timeline-year">{entry.season ?? entry.year}</span>
                <span class="timeline-crop">{entry.crop}</span>
                {#if entry.yield}
                  <span class="timeline-yield">{entry.yield} t/ha</span>
                {/if}
              </div>
            </div>
          {/each}
        </div>
      {:else}
        <p class="empty-text">No rotation pattern data available</p>
      {/if}
    </div>

    <!-- Recommendations -->
    <div class="page-content mt-4">
      <h2 class="section-title">Recommendations</h2>
      {#if recommendations.length > 0}
        <ul class="recommendations-list">
          {#each recommendations as rec}
            <li class="recommendation-item">{rec}</li>
          {/each}
        </ul>
      {:else}
        <p class="empty-text">No recommendations available</p>
      {/if}
    </div>
  {/if}
</div>

<style>
  .page-container { max-width: 1200px; }
  .page-header { margin-bottom: 1.5rem; }
  .page-header h1 { font-size: 1.5rem; font-weight: 600; margin: 0; }
  .subtitle { font-size: 0.875rem; color: #6b7280; margin: 0.25rem 0 0 0; }
  .header-row { display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem; }
  .page-content { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.5rem; }
  .error-banner { color: #dc2626; }
  .section-title { font-size: 1rem; font-weight: 600; margin: 0 0 1rem 0; }
  .gauge-container { display: flex; gap: 2rem; align-items: center; flex-wrap: wrap; }
  .gauge { display: flex; flex-direction: column; align-items: center; min-width: 160px; }
  .gauge-svg { width: 160px; height: 90px; }
  .gauge-value { font-size: 2rem; font-weight: 700; margin-top: -0.5rem; }
  .gauge-label { font-size: 0.75rem; color: #6b7280; }
  .score-details { display: flex; gap: 2rem; flex-wrap: wrap; }
  .detail-field { display: flex; flex-direction: column; gap: 0.25rem; }
  .detail-label { font-size: 0.75rem; font-weight: 500; color: #6b7280; text-transform: uppercase; }
  .detail-value { font-size: 0.875rem; color: #111827; }
  .detail-value small { font-size: 0.75rem; color: #6b7280; }
  .timeline { display: flex; flex-direction: column; position: relative; padding-left: 2rem; }
  .timeline-item { display: flex; align-items: flex-start; position: relative; padding-bottom: 1.5rem; }
  .timeline-dot { width: 12px; height: 12px; border-radius: 50%; background: #d1d5db; position: absolute; left: -2rem; top: 0.25rem; z-index: 1; }
  .timeline-dot.active { background: #3b82f6; }
  .timeline-line { position: absolute; left: calc(-2rem + 5px); top: 14px; width: 2px; height: calc(100% - 4px); background: #e5e7eb; }
  .timeline-content { display: flex; gap: 1rem; align-items: baseline; }
  .timeline-year { font-size: 0.75rem; font-weight: 500; color: #6b7280; min-width: 80px; }
  .timeline-crop { font-size: 0.875rem; font-weight: 600; color: #111827; }
  .timeline-yield { font-size: 0.75rem; color: #6b7280; }
  .recommendations-list { list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 0.75rem; }
  .recommendation-item { padding: 0.75rem 1rem; background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 0.375rem; font-size: 0.875rem; color: #166534; }
  .empty-text { color: #6b7280; font-size: 0.875rem; }
  .mt-4 { margin-top: 1rem; }
</style>
