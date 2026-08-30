<script lang="ts">
  import { goto } from '$app/navigation';
  import { analyticsClient } from '@samavāya/agriculture/services';

  interface HistoryAlert {
    id: string;
    type: string;
    title: string;
    severity: string;
    status: string;
    timestamp: string;
    fieldName?: string;
  }

  let alerts: HistoryAlert[] = [];
  let loading = true;
  let error: string | null = null;

  let startDate = '';
  let endDate = '';

  // Distribution counts by type.
  let typeCounts: Record<string, number> = {};

  loadHistory();

  async function loadHistory() {
    loading = true;
    error = null;
    try {
      const params: Record<string, unknown> = {};
      if (startDate) params.startDate = startDate;
      if (endDate) params.endDate = endDate;

      const res = await analyticsClient.listAlertHistory(params);
      alerts = res.alerts ?? [];

      // Compute type distribution.
      typeCounts = {};
      for (const a of alerts) {
        typeCounts[a.type] = (typeCounts[a.type] ?? 0) + 1;
      }
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load alert history';
    } finally {
      loading = false;
    }
  }

  function formatType(type: string): string {
    return type.replace(/([A-Z])/g, ' $1').replace(/^./, (s) => s.toUpperCase()).trim();
  }

  function severityColor(s: string): string {
    switch (s) {
      case 'emergency': return '#dc2626';
      case 'critical': return '#ea580c';
      case 'warning': return '#ca8a04';
      case 'info': return '#0284c7';
      default: return '#6b7280';
    }
  }

  function handleFilter() {
    loadHistory();
  }

  function clearFilter() {
    startDate = '';
    endDate = '';
    loadHistory();
  }
</script>

<div class="page-container">
  <header class="page-header">
    <h1>Alert History</h1>
    <p class="subtitle">Historical alert timeline with date range filter</p>
  </header>

  <div class="filter-bar">
    <div class="date-inputs">
      <div class="date-field">
        <label for="start">Start Date</label>
        <input id="start" type="date" bind:value={startDate} />
      </div>
      <div class="date-field">
        <label for="end">End Date</label>
        <input id="end" type="date" bind:value={endDate} />
      </div>
      <button class="btn btn-primary" on:click={handleFilter}>Filter</button>
      {#if startDate || endDate}
        <button class="btn btn-secondary" on:click={clearFilter}>Clear</button>
      {/if}
    </div>
  </div>

  {#if loading}
    <div class="page-content"><p>Loading...</p></div>
  {:else if error}
    <div class="page-content error-banner"><p>{error}</p></div>
  {:else}
    <!-- Distribution chart -->
    {#if Object.keys(typeCounts).length > 0}
      <div class="distribution">
        <h3>Alert Type Distribution</h3>
        <div class="chart">
          {#each Object.entries(typeCounts).sort((a, b) => b[1] - a[1]) as [type, count]}
            {@const maxCount = Math.max(...Object.values(typeCounts))}
            <div class="chart-row">
              <span class="chart-label">{formatType(type)}</span>
              <div class="chart-bar-container">
                <div
                  class="chart-bar"
                  style:width="{(count / maxCount) * 100}%"
                ></div>
              </div>
              <span class="chart-count">{count}</span>
            </div>
          {/each}
        </div>
      </div>
    {/if}

    <!-- Timeline -->
    {#if alerts.length === 0}
      <div class="page-content empty">
        <p>No alerts found for the selected period.</p>
      </div>
    {:else}
      <div class="timeline">
        {#each alerts as alert (alert.id)}
          <div
            class="timeline-item"
            on:click={() => goto(`/alerts/${alert.id}`)}
            on:keydown={(e) => e.key === 'Enter' && goto(`/alerts/${alert.id}`)}
            role="button"
            tabindex="0"
          >
            <div class="timeline-marker" style:background={severityColor(alert.severity)}></div>
            <div class="timeline-content">
              <div class="timeline-header">
                <span class="timeline-severity" style:color={severityColor(alert.severity)}>
                  {alert.severity}
                </span>
                <span class="timeline-time">
                  {new Date(alert.timestamp).toLocaleString()}
                </span>
              </div>
              <div class="timeline-title">{alert.title}</div>
              <div class="timeline-meta">
                <span>{formatType(alert.type)}</span>
                {#if alert.fieldName}
                  <span>{alert.fieldName}</span>
                {/if}
                <span class="status-chip">{alert.status}</span>
              </div>
            </div>
          </div>
        {/each}
      </div>
    {/if}
  {/if}

  <div class="back-link">
    <button class="btn btn-secondary" on:click={() => goto('/alerts')}>Back to Alerts</button>
  </div>
</div>

<style>
  .page-container { max-width: 1200px; }
  .page-header { margin-bottom: 1rem; }
  .page-header h1 { font-size: 1.5rem; font-weight: 600; margin: 0; }
  .subtitle { font-size: 0.875rem; color: #6b7280; margin: 0.25rem 0 0 0; }
  .page-content { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.5rem; }
  .error-banner { color: #dc2626; }
  .empty { text-align: center; color: #6b7280; }
  .filter-bar { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1rem; margin-bottom: 1rem; }
  .date-inputs { display: flex; align-items: flex-end; gap: 0.75rem; flex-wrap: wrap; }
  .date-field { display: flex; flex-direction: column; gap: 0.25rem; }
  .date-field label { font-size: 0.75rem; font-weight: 500; color: #6b7280; }
  .date-field input { padding: 0.5rem 0.75rem; border: 1px solid #d1d5db; border-radius: 0.375rem; font-size: 0.875rem; }
  .distribution { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.5rem; margin-bottom: 1rem; }
  .distribution h3 { font-size: 0.875rem; font-weight: 600; margin: 0 0 1rem 0; color: #374151; }
  .chart { display: flex; flex-direction: column; gap: 0.5rem; }
  .chart-row { display: flex; align-items: center; gap: 0.75rem; }
  .chart-label { font-size: 0.75rem; color: #374151; width: 120px; text-align: right; flex-shrink: 0; }
  .chart-bar-container { flex: 1; background: #f3f4f6; border-radius: 4px; height: 20px; overflow: hidden; }
  .chart-bar { height: 100%; background: #3b82f6; border-radius: 4px; min-width: 4px; transition: width 0.3s; }
  .chart-count { font-size: 0.75rem; font-weight: 600; color: #111827; width: 2rem; }
  .timeline { display: flex; flex-direction: column; gap: 0; }
  .timeline-item { display: flex; gap: 1rem; padding: 1rem; background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; margin-bottom: 0.5rem; cursor: pointer; transition: background 0.15s; }
  .timeline-item:hover { background: #f9fafb; }
  .timeline-marker { width: 12px; height: 12px; border-radius: 50%; flex-shrink: 0; margin-top: 0.25rem; }
  .timeline-content { flex: 1; min-width: 0; }
  .timeline-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.25rem; }
  .timeline-severity { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; }
  .timeline-time { font-size: 0.75rem; color: #6b7280; }
  .timeline-title { font-size: 0.875rem; font-weight: 500; color: #111827; margin-bottom: 0.25rem; }
  .timeline-meta { display: flex; gap: 0.75rem; font-size: 0.75rem; color: #6b7280; }
  .status-chip { background: #e5e7eb; padding: 0.125rem 0.5rem; border-radius: 9999px; text-transform: capitalize; }
  .back-link { margin-top: 1.5rem; }
  .btn { padding: 0.5rem 1rem; border-radius: 0.375rem; font-size: 0.875rem; font-weight: 500; cursor: pointer; border: 1px solid #d1d5db; }
  .btn-primary { background: #2563eb; color: #fff; border-color: #2563eb; }
  .btn-primary:hover { background: #1d4ed8; }
  .btn-secondary { background: #fff; color: #374151; }
  .btn-secondary:hover { background: #f3f4f6; }
</style>
