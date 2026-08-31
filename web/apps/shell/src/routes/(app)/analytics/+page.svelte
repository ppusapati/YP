<script lang="ts">
  import { goto } from '$app/navigation';
  import { fieldAnalyticsClient, farmClient, fieldClient } from '@samavāya/agriculture/services';

  let farmId = '';
  let fieldId = '';
  let farmOptions: { label: string; value: string }[] = [];
  let fieldOptions: { label: string; value: string }[] = [];
  let timePeriod: 'all' | '3y' | '5y' | '10y' = 'all';
  let metrics: Record<string, unknown> | null = null;
  let fieldList: any[] = [];
  let loading = false;
  let error: string | null = null;

  async function loadFarms(query = '') {
    try {
      const res = await farmClient.listFarms({ search: query, pageSize: 50 });
      farmOptions = (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
    } catch {
      farmOptions = [];
    }
  }

  async function loadFields(query = '') {
    try {
      const params: Record<string, unknown> = { search: query, pageSize: 50 };
      if (farmId) params.farmId = farmId;
      const res = await fieldClient.listFields(params);
      fieldOptions = (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
    } catch {
      fieldOptions = [];
    }
  }

  async function fetchMetrics() {
    loading = true;
    error = null;
    metrics = null;
    try {
      const params: Record<string, unknown> = { timePeriod };
      if (farmId) params.farmId = farmId;
      if (fieldId) params.fieldId = fieldId;
      const res = await fieldAnalyticsClient.getHistoricalMetrics(params);
      metrics = res as any;
      fieldList = (res as any).fields || [];
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load analytics metrics';
    } finally {
      loading = false;
    }
  }

  loadFarms();
  loadFields();
</script>

<div class="page-container">
  <header class="page-header">
    <h1>Historical Analytics</h1>
    <p class="subtitle">Analyze yield trends, stress patterns, and field performance over time</p>
  </header>

  <div class="page-content">
    <div class="selector-row">
      <div class="selector-field">
        <label for="farm-select">Farm</label>
        <select id="farm-select" bind:value={farmId} on:change={() => { metrics = null; loadFields(); }}>
          <option value="">All farms</option>
          {#each farmOptions as opt}
            <option value={opt.value}>{opt.label}</option>
          {/each}
        </select>
      </div>
      <div class="selector-field">
        <label for="field-select">Field</label>
        <select id="field-select" bind:value={fieldId} on:change={() => { metrics = null; }}>
          <option value="">All fields</option>
          {#each fieldOptions as opt}
            <option value={opt.value}>{opt.label}</option>
          {/each}
        </select>
      </div>
      <div class="selector-field">
        <label for="time-period">Time Period</label>
        <select id="time-period" bind:value={timePeriod}>
          <option value="all">All time</option>
          <option value="3y">Last 3 years</option>
          <option value="5y">Last 5 years</option>
          <option value="10y">Last 10 years</option>
        </select>
      </div>
      <button
        class="rounded-md bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-500 self-end"
        on:click={fetchMetrics}
        disabled={loading}
      >Load Analytics</button>
    </div>
  </div>

  {#if loading}
    <div class="page-content mt-4">
      <p>Loading...</p>
    </div>
  {:else if error}
    <div class="page-content mt-4 error-banner">
      <p>{error}</p>
    </div>
  {:else if metrics}
    <div class="summary-grid mt-4">
      <div class="summary-card">
        <span class="summary-label">Mean Yield</span>
        <span class="summary-value">{metrics.meanYield ?? '—'} <small>t/ha</small></span>
      </div>
      <div class="summary-card">
        <span class="summary-label">Yield Trend</span>
        <span class="summary-value trend-{metrics.yieldTrend}">{metrics.yieldTrend ?? '—'}</span>
      </div>
      <div class="summary-card">
        <span class="summary-label">Stress Days (avg/season)</span>
        <span class="summary-value">{metrics.avgStressDays ?? '—'}</span>
      </div>
      <div class="summary-card">
        <span class="summary-label">Peak Yield</span>
        <span class="summary-value">{metrics.peakYield ?? '—'} <small>t/ha</small></span>
      </div>
      <div class="summary-card">
        <span class="summary-label">Seasons Analyzed</span>
        <span class="summary-value">{metrics.seasonsAnalyzed ?? '—'}</span>
      </div>
      <div class="summary-card">
        <span class="summary-label">Avg NDVI</span>
        <span class="summary-value">{metrics.avgNdvi ?? '—'}</span>
      </div>
    </div>

    {#if fieldList.length > 0}
      <div class="page-content mt-4">
        <h2 class="section-title">Fields</h2>
        <table class="data-table">
          <thead>
            <tr>
              <th>Field</th>
              <th>Mean Yield</th>
              <th>Trend</th>
              <th>Stress Days</th>
              <th>NDVI</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {#each fieldList as field}
              <tr>
                <td>{field.name ?? field.id}</td>
                <td>{field.meanYield ?? '—'}</td>
                <td class="trend-{field.yieldTrend}">{field.yieldTrend ?? '—'}</td>
                <td>{field.avgStressDays ?? '—'}</td>
                <td>{field.avgNdvi ?? '—'}</td>
                <td>
                  <button
                    class="link-btn"
                    on:click={() => goto(`/analytics/field/${field.id}`)}
                  >Details</button>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}
  {/if}
</div>

<style>
  .page-container { max-width: 1200px; }
  .page-header { margin-bottom: 1.5rem; }
  .page-header h1 { font-size: 1.5rem; font-weight: 600; margin: 0; }
  .subtitle { font-size: 0.875rem; color: #6b7280; margin: 0.25rem 0 0 0; }
  .page-content { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.5rem; }
  .error-banner { color: #dc2626; }
  .selector-row { display: flex; gap: 1rem; align-items: flex-end; flex-wrap: wrap; }
  .selector-field { display: flex; flex-direction: column; gap: 0.25rem; flex: 1; min-width: 150px; }
  .selector-field label { font-size: 0.75rem; font-weight: 500; color: #6b7280; text-transform: uppercase; }
  .selector-field select { border: 1px solid #d1d5db; border-radius: 0.375rem; padding: 0.5rem 0.75rem; font-size: 0.875rem; }
  .summary-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem; }
  .summary-card { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.25rem; display: flex; flex-direction: column; gap: 0.5rem; }
  .summary-label { font-size: 0.75rem; font-weight: 500; color: #6b7280; text-transform: uppercase; }
  .summary-value { font-size: 1.25rem; font-weight: 600; color: #111827; }
  .summary-value small { font-size: 0.75rem; font-weight: 400; color: #6b7280; }
  .section-title { font-size: 1rem; font-weight: 600; margin: 0 0 1rem 0; }
  .data-table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
  .data-table th { text-align: left; padding: 0.5rem 0.75rem; border-bottom: 2px solid #e5e7eb; font-weight: 500; color: #6b7280; font-size: 0.75rem; text-transform: uppercase; }
  .data-table td { padding: 0.5rem 0.75rem; border-bottom: 1px solid #f3f4f6; }
  .link-btn { background: none; border: none; color: #2563eb; cursor: pointer; font-size: 0.875rem; text-decoration: underline; padding: 0; }
  .link-btn:hover { color: #1d4ed8; }
  :global(.trend-increasing) { color: #16a34a; }
  :global(.trend-decreasing) { color: #dc2626; }
  :global(.trend-stable) { color: #6b7280; }
  .mt-4 { margin-top: 1rem; }
</style>
