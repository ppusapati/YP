<script lang="ts">
  import { analyticsClient } from '@samavāya/agriculture/services';
  import { farmClient, fieldClient } from '@samavāya/agriculture/services';

  let farmId = '';
  let fieldId = '';
  let farmOptions: { label: string; value: string }[] = [];
  let fieldOptions: { label: string; value: string }[] = [];
  let summary: Record<string, unknown> | null = null;
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
      const res = await fieldClient.listFields({ search: query, pageSize: 50 });
      fieldOptions = (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
    } catch {
      fieldOptions = [];
    }
  }

  async function fetchSummary() {
    if (!farmId || !fieldId) return;
    loading = true;
    error = null;
    summary = null;
    try {
      const res = await analyticsClient.getFieldAnalyticsSummary({ farmId, fieldId });
      summary = res as any;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load field analytics summary';
    } finally {
      loading = false;
    }
  }

  loadFarms();
  loadFields();
</script>

<div class="page-container">
  <header class="page-header">
    <h1>Field Analytics</h1>
    <p class="subtitle">View analytics summary for a specific field</p>
  </header>

  <div class="page-content">
    <div class="selector-row">
      <div class="selector-field">
        <label for="farm-select">Farm</label>
        <select id="farm-select" bind:value={farmId} on:change={() => { summary = null; }}>
          <option value="">Select a farm</option>
          {#each farmOptions as opt}
            <option value={opt.value}>{opt.label}</option>
          {/each}
        </select>
      </div>
      <div class="selector-field">
        <label for="field-select">Field</label>
        <select id="field-select" bind:value={fieldId} on:change={() => { summary = null; }}>
          <option value="">Select a field</option>
          {#each fieldOptions as opt}
            <option value={opt.value}>{opt.label}</option>
          {/each}
        </select>
      </div>
      <button
        class="rounded-md bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-500 self-end"
        on:click={fetchSummary}
        disabled={!farmId || !fieldId || loading}
      >Load Summary</button>
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
  {:else if summary}
    <div class="summary-grid mt-4">
      <div class="summary-card">
        <span class="summary-label">Active Stress Alerts</span>
        <span class="summary-value">{summary.activeStressAlerts ?? '—'}</span>
      </div>
      <div class="summary-card">
        <span class="summary-label">Health Score</span>
        <span class="summary-value">{summary.healthScore ?? '—'}</span>
      </div>
      <div class="summary-card">
        <span class="summary-label">NDVI Trend</span>
        <span class="summary-value">{summary.ndviTrend ?? '—'}</span>
      </div>
      <div class="summary-card">
        <span class="summary-label">Dominant Stress Type</span>
        <span class="summary-value">{summary.dominantStressType ?? '—'}</span>
      </div>
      <div class="summary-card">
        <span class="summary-label">Last Analysis</span>
        <span class="summary-value">{summary.lastAnalysis ?? '—'}</span>
      </div>
    </div>
  {/if}
</div>

<style>
  .page-container { max-width: 1200px; }
  .page-header { margin-bottom: 1.5rem; }
  .page-header h1 { font-size: 1.5rem; font-weight: 600; margin: 0; }
  .subtitle { font-size: 0.875rem; color: #6b7280; margin: 0.25rem 0 0 0; }
  .page-content { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.5rem; }
  .error-banner { color: #dc2626; }
  .selector-row { display: flex; gap: 1rem; align-items: flex-end; }
  .selector-field { display: flex; flex-direction: column; gap: 0.25rem; flex: 1; }
  .selector-field label { font-size: 0.75rem; font-weight: 500; color: #6b7280; text-transform: uppercase; }
  .selector-field select { border: 1px solid #d1d5db; border-radius: 0.375rem; padding: 0.5rem 0.75rem; font-size: 0.875rem; }
  .summary-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem; }
  .summary-card { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.25rem; display: flex; flex-direction: column; gap: 0.5rem; }
  .summary-label { font-size: 0.75rem; font-weight: 500; color: #6b7280; text-transform: uppercase; }
  .summary-value { font-size: 1.25rem; font-weight: 600; color: #111827; }
  .mt-4 { margin-top: 1rem; }
</style>
