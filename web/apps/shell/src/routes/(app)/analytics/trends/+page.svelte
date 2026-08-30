<script lang="ts">
  import { analyticsClient } from '@samavāya/agriculture/services';
  import { fieldClient } from '@samavāya/agriculture/services';

  let fieldOptions: { label: string; value: string }[] = [];
  let selectedFields: string[] = [];
  let metric: 'yield' | 'ndvi' = 'yield';
  let trendData: Record<string, any[]> = {};
  let loading = false;
  let error: string | null = null;

  async function loadFields(query = '') {
    try {
      const res = await fieldClient.listFields({ search: query, pageSize: 100 });
      fieldOptions = (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
    } catch {
      fieldOptions = [];
    }
  }

  function toggleField(fieldId: string) {
    if (selectedFields.includes(fieldId)) {
      selectedFields = selectedFields.filter((f) => f !== fieldId);
    } else {
      selectedFields = [...selectedFields, fieldId];
    }
  }

  async function fetchTrends() {
    if (selectedFields.length === 0) return;
    loading = true;
    error = null;
    trendData = {};
    try {
      const res = await analyticsClient.getCrossFieldTrends({
        fieldIds: selectedFields,
        metric,
      });
      trendData = (res as any).trends || {};
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load trend data';
    } finally {
      loading = false;
    }
  }

  function getFieldLabel(fieldId: string): string {
    return fieldOptions.find((f) => f.value === fieldId)?.label ?? fieldId;
  }

  const colors = ['#3b82f6', '#16a34a', '#f59e0b', '#8b5cf6', '#ef4444', '#06b6d4', '#ec4899', '#84cc16'];

  loadFields();
</script>

<div class="page-container">
  <header class="page-header">
    <h1>Cross-Field Trends</h1>
    <p class="subtitle">Compare yield and NDVI trends across multiple fields</p>
  </header>

  <div class="page-content">
    <div class="controls-row">
      <div class="field-picker">
        <label class="picker-label">Select Fields</label>
        <div class="field-chips">
          {#each fieldOptions as opt}
            <button
              class="field-chip"
              class:selected={selectedFields.includes(opt.value)}
              on:click={() => toggleField(opt.value)}
            >{opt.label}</button>
          {/each}
        </div>
      </div>
      <div class="selector-field">
        <label for="metric-select">Metric</label>
        <select id="metric-select" bind:value={metric}>
          <option value="yield">Yield (t/ha)</option>
          <option value="ndvi">NDVI</option>
        </select>
      </div>
      <button
        class="rounded-md bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-500 self-end"
        on:click={fetchTrends}
        disabled={selectedFields.length === 0 || loading}
      >Compare</button>
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
  {:else if Object.keys(trendData).length > 0}
    <div class="page-content mt-4">
      <h2 class="section-title">{metric === 'yield' ? 'Yield' : 'NDVI'} Comparison</h2>

      <!-- Legend -->
      <div class="legend">
        {#each selectedFields as fieldId, i}
          <div class="legend-item">
            <span class="legend-swatch" style="background: {colors[i % colors.length]}"></span>
            <span>{getFieldLabel(fieldId)}</span>
          </div>
        {/each}
      </div>

      <!-- Side-by-side bar chart -->
      <div class="chart-area">
        {@const allSeasons = [...new Set(selectedFields.flatMap((fid) => (trendData[fid] || []).map((p: any) => p.season || p.year)))].sort()}
        <div class="comparison-chart">
          {#each allSeasons as season}
            <div class="season-group">
              <div class="bars-row">
                {#each selectedFields as fieldId, i}
                  {@const point = (trendData[fieldId] || []).find((p: any) => (p.season || p.year) === season)}
                  {@const val = point ? (metric === 'yield' ? point.yield : point.ndvi) : 0}
                  {@const maxVal = metric === 'yield' ? 20 : 1}
                  <div
                    class="comp-bar"
                    style="height: {Math.min((val / maxVal) * 100, 100)}%; background: {colors[i % colors.length]}"
                    title="{getFieldLabel(fieldId)}: {val}"
                  ></div>
                {/each}
              </div>
              <span class="season-label">{season}</span>
            </div>
          {/each}
        </div>
      </div>

      <!-- Data table -->
      <div class="table-wrapper mt-4">
        <table class="data-table">
          <thead>
            <tr>
              <th>Season</th>
              {#each selectedFields as fieldId}
                <th>{getFieldLabel(fieldId)}</th>
              {/each}
            </tr>
          </thead>
          <tbody>
            {@const allSeasons = [...new Set(selectedFields.flatMap((fid) => (trendData[fid] || []).map((p: any) => p.season || p.year)))].sort()}
            {#each allSeasons as season}
              <tr>
                <td class="font-medium">{season}</td>
                {#each selectedFields as fieldId}
                  {@const point = (trendData[fieldId] || []).find((p: any) => (p.season || p.year) === season)}
                  <td>{point ? (metric === 'yield' ? point.yield : point.ndvi?.toFixed(2)) : '—'}</td>
                {/each}
              </tr>
            {/each}
          </tbody>
        </table>
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
  .controls-row { display: flex; gap: 1rem; align-items: flex-end; flex-wrap: wrap; }
  .field-picker { flex: 2; }
  .picker-label { font-size: 0.75rem; font-weight: 500; color: #6b7280; text-transform: uppercase; display: block; margin-bottom: 0.5rem; }
  .field-chips { display: flex; flex-wrap: wrap; gap: 0.375rem; }
  .field-chip { border: 1px solid #d1d5db; border-radius: 999px; padding: 0.25rem 0.75rem; font-size: 0.75rem; background: #fff; cursor: pointer; transition: all 0.15s; }
  .field-chip:hover { border-color: #3b82f6; }
  .field-chip.selected { background: #eff6ff; border-color: #3b82f6; color: #2563eb; font-weight: 500; }
  .selector-field { display: flex; flex-direction: column; gap: 0.25rem; min-width: 150px; }
  .selector-field label { font-size: 0.75rem; font-weight: 500; color: #6b7280; text-transform: uppercase; }
  .selector-field select { border: 1px solid #d1d5db; border-radius: 0.375rem; padding: 0.5rem 0.75rem; font-size: 0.875rem; }
  .section-title { font-size: 1rem; font-weight: 600; margin: 0 0 1rem 0; }
  .legend { display: flex; gap: 1rem; flex-wrap: wrap; margin-bottom: 1rem; }
  .legend-item { display: flex; align-items: center; gap: 0.375rem; font-size: 0.75rem; color: #374151; }
  .legend-swatch { width: 12px; height: 12px; border-radius: 2px; display: inline-block; }
  .chart-area { padding: 1rem 0; }
  .comparison-chart { display: flex; gap: 1rem; align-items: flex-end; height: 200px; border-bottom: 1px solid #e5e7eb; padding-bottom: 0.5rem; overflow-x: auto; }
  .season-group { display: flex; flex-direction: column; align-items: center; }
  .bars-row { display: flex; gap: 2px; align-items: flex-end; height: 180px; }
  .comp-bar { width: 16px; min-height: 2px; border-radius: 2px 2px 0 0; transition: height 0.3s ease; }
  .season-label { font-size: 0.625rem; color: #6b7280; margin-top: 0.5rem; white-space: nowrap; }
  .table-wrapper { overflow-x: auto; }
  .data-table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
  .data-table th { text-align: left; padding: 0.5rem 0.75rem; border-bottom: 2px solid #e5e7eb; font-weight: 500; color: #6b7280; font-size: 0.75rem; text-transform: uppercase; }
  .data-table td { padding: 0.5rem 0.75rem; border-bottom: 1px solid #f3f4f6; }
  .font-medium { font-weight: 500; }
  .mt-4 { margin-top: 1rem; }
</style>
