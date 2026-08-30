<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { analyticsClient } from '@samavāya/agriculture/services';

  let analytics: Record<string, unknown> = {};
  let yieldTrends: any[] = [];
  let seasonComparisons: any[] = [];
  let ndviTrends: any[] = [];
  let loading = true;
  let error: string | null = null;

  $: id = $page.params.id;

  $: if (id) loadData(id);

  async function loadData(fieldId: string) {
    loading = true;
    error = null;
    try {
      const res = await analyticsClient.getFieldHistoricalAnalytics({ fieldId });
      analytics = res as any || {};
      yieldTrends = (res as any).yieldTrends || [];
      seasonComparisons = (res as any).seasonComparisons || [];
      ndviTrends = (res as any).ndviTrends || [];
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load field analytics';
    } finally {
      loading = false;
    }
  }
</script>

<div class="page-container">
  <header class="page-header">
    <div class="header-row">
      <div>
        <h1>Field Analytics</h1>
        <p class="subtitle">Detailed historical analysis for field {id}</p>
      </div>
      <div class="header-actions">
        <button
          class="rounded-md bg-gray-200 px-4 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-300"
          on:click={() => goto(`/analytics/field/${id}/seasons`)}
        >Season Comparison</button>
        <button
          class="rounded-md bg-gray-200 px-4 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-300"
          on:click={() => goto(`/analytics/field/${id}/rotation`)}
        >Rotation Analysis</button>
        <button
          class="rounded-md bg-gray-200 px-4 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-300"
          on:click={() => goto('/analytics')}
        >Back to Dashboard</button>
      </div>
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
    <!-- Yield Trend Chart Area -->
    <div class="page-content">
      <h2 class="section-title">Yield Trend</h2>
      {#if yieldTrends.length > 0}
        <div class="chart-area">
          <div class="bar-chart">
            {#each yieldTrends as point}
              <div class="bar-col">
                <div class="bar" style="height: {Math.min((point.yield / (analytics.peakYield || 1)) * 100, 100)}%"></div>
                <span class="bar-label">{point.season ?? point.year}</span>
                <span class="bar-value">{point.yield}</span>
              </div>
            {/each}
          </div>
        </div>
      {:else}
        <p class="empty-text">No yield trend data available</p>
      {/if}
    </div>

    <!-- Season Comparison Table -->
    <div class="page-content mt-4">
      <h2 class="section-title">Season Comparison</h2>
      {#if seasonComparisons.length > 0}
        <table class="data-table">
          <thead>
            <tr>
              <th>Season</th>
              <th>Crop</th>
              <th>Yield (t/ha)</th>
              <th>vs Mean</th>
              <th>Stress Days</th>
              <th>NDVI Peak</th>
            </tr>
          </thead>
          <tbody>
            {#each seasonComparisons as season}
              <tr>
                <td>{season.season ?? '—'}</td>
                <td>{season.crop ?? '—'}</td>
                <td>{season.yield ?? '—'}</td>
                <td class={season.yieldVsMean >= 0 ? 'positive' : 'negative'}>
                  {season.yieldVsMean != null ? `${season.yieldVsMean > 0 ? '+' : ''}${season.yieldVsMean}%` : '—'}
                </td>
                <td>{season.stressDays ?? '—'}</td>
                <td>{season.ndviPeak ?? '—'}</td>
              </tr>
            {/each}
          </tbody>
        </table>
      {:else}
        <p class="empty-text">No season comparison data available</p>
      {/if}
    </div>

    <!-- Rotation Effectiveness Score -->
    <div class="page-content mt-4">
      <h2 class="section-title">Rotation Effectiveness</h2>
      <div class="detail-grid">
        <div class="detail-field">
          <span class="detail-label">Rotation Score</span>
          <span class="detail-value score">{analytics.rotationScore ?? '—'}<small>/100</small></span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Current Rotation</span>
          <span class="detail-value">{analytics.currentRotation ?? '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Rotation Length</span>
          <span class="detail-value">{analytics.rotationLength ?? '—'} <small>years</small></span>
        </div>
      </div>
    </div>

    <!-- NDVI Trend Section -->
    <div class="page-content mt-4">
      <h2 class="section-title">NDVI Trend</h2>
      {#if ndviTrends.length > 0}
        <div class="chart-area">
          <div class="bar-chart ndvi-chart">
            {#each ndviTrends as point}
              <div class="bar-col">
                <div class="bar ndvi-bar" style="height: {(point.ndvi || 0) * 100}%"></div>
                <span class="bar-label">{point.date ?? point.season}</span>
                <span class="bar-value">{point.ndvi?.toFixed(2) ?? '—'}</span>
              </div>
            {/each}
          </div>
        </div>
      {:else}
        <p class="empty-text">No NDVI trend data available</p>
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
  .header-actions { display: flex; gap: 0.5rem; flex-wrap: wrap; }
  .page-content { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.5rem; }
  .error-banner { color: #dc2626; }
  .section-title { font-size: 1rem; font-weight: 600; margin: 0 0 1rem 0; }
  .detail-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem; }
  .detail-field { display: flex; flex-direction: column; gap: 0.25rem; }
  .detail-label { font-size: 0.75rem; font-weight: 500; color: #6b7280; text-transform: uppercase; }
  .detail-value { font-size: 0.875rem; color: #111827; }
  .detail-value.score { font-size: 1.5rem; font-weight: 700; color: #16a34a; }
  .detail-value.score small { font-size: 0.875rem; font-weight: 400; color: #6b7280; }
  .detail-value small { font-size: 0.75rem; color: #6b7280; }
  .data-table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
  .data-table th { text-align: left; padding: 0.5rem 0.75rem; border-bottom: 2px solid #e5e7eb; font-weight: 500; color: #6b7280; font-size: 0.75rem; text-transform: uppercase; }
  .data-table td { padding: 0.5rem 0.75rem; border-bottom: 1px solid #f3f4f6; }
  .positive { color: #16a34a; font-weight: 500; }
  .negative { color: #dc2626; font-weight: 500; }
  .chart-area { padding: 1rem 0; }
  .bar-chart { display: flex; gap: 0.5rem; align-items: flex-end; height: 200px; border-bottom: 1px solid #e5e7eb; padding-bottom: 0.5rem; }
  .bar-col { display: flex; flex-direction: column; align-items: center; flex: 1; height: 100%; justify-content: flex-end; }
  .bar { background: #3b82f6; border-radius: 0.25rem 0.25rem 0 0; width: 100%; max-width: 40px; min-height: 4px; transition: height 0.3s ease; }
  .ndvi-bar { background: #16a34a; }
  .bar-label { font-size: 0.625rem; color: #6b7280; margin-top: 0.5rem; text-align: center; }
  .bar-value { font-size: 0.625rem; color: #111827; font-weight: 500; }
  .empty-text { color: #6b7280; font-size: 0.875rem; }
  .mt-4 { margin-top: 1rem; }
</style>
