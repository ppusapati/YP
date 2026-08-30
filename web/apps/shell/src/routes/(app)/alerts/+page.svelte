<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { alertClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  let severityFilter: string | null = null;
  let typeFilter: string | null = null;
  let statusFilter: string | null = null;
  let sortBy: 'recency' | 'severity' = 'recency';

  const severities = ['info', 'warning', 'critical', 'emergency'];
  const types = [
    'cropStress',
    'waterShortage',
    'diseaseOutbreak',
    'pestOutbreak',
    'irrigationNeeded',
    'frostWarning',
    'soilHealth',
    'weatherEvent',
  ];
  const statuses = ['active', 'acknowledged', 'resolved', 'expired'];

  const columns = [
    { key: 'severity', label: 'Severity' },
    { key: 'title', label: 'Title' },
    { key: 'type', label: 'Type', format: (v: unknown) => formatType(v as string) },
    { key: 'fieldName', label: 'Field' },
    { key: 'status', label: 'Status' },
    { key: 'timestamp', label: 'Time', format: (v: unknown) => formatTimeAgo(v as string) },
  ];

  function formatType(type: string): string {
    return type.replace(/([A-Z])/g, ' $1').replace(/^./, (s) => s.toUpperCase()).trim();
  }

  function formatTimeAgo(ts: string): string {
    const d = new Date(ts);
    const now = Date.now();
    const diffMs = now - d.getTime();
    const mins = Math.floor(diffMs / 60000);
    if (mins < 60) return `${mins}m ago`;
    const hours = Math.floor(mins / 60);
    if (hours < 24) return `${hours}h ago`;
    const days = Math.floor(hours / 24);
    if (days < 7) return `${days}d ago`;
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
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

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await alertClient.listAlerts({
        pageSize,
        pageOffset,
        severity: severityFilter ?? undefined,
        type: typeFilter ?? undefined,
        status: statusFilter ?? undefined,
        sortBy,
      });
      rows = res.alerts;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load alerts';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }

  function toggleSeverity(s: string) {
    severityFilter = severityFilter === s ? null : s;
    fetchData();
  }

  function toggleType(t: string) {
    typeFilter = typeFilter === t ? null : t;
    fetchData();
  }

  function toggleStatus(s: string) {
    statusFilter = statusFilter === s ? null : s;
    fetchData();
  }

  function toggleSort() {
    sortBy = sortBy === 'recency' ? 'severity' : 'recency';
    fetchData();
  }
</script>

<div class="page-container">
  <header class="page-header">
    <div class="header-row">
      <div>
        <h1>Alerts</h1>
        <p class="subtitle">Monitor and manage farm alerts</p>
      </div>
      <div class="header-actions">
        <button class="btn btn-secondary" on:click={() => goto('/alerts/history')}>History</button>
        <button class="btn btn-secondary" on:click={() => goto('/alerts/field-risk')}>Field Risk</button>
        <button class="btn btn-primary" on:click={() => goto('/alerts/rules')}>Manage Rules</button>
      </div>
    </div>
  </header>

  <div class="filters">
    <div class="filter-group">
      <span class="filter-label">Severity:</span>
      {#each severities as s}
        <button
          class="chip"
          class:active={severityFilter === s}
          style:--chip-color={severityColor(s)}
          on:click={() => toggleSeverity(s)}
        >{s}</button>
      {/each}
    </div>
    <div class="filter-group">
      <span class="filter-label">Type:</span>
      {#each types as t}
        <button
          class="chip"
          class:active={typeFilter === t}
          on:click={() => toggleType(t)}
        >{formatType(t)}</button>
      {/each}
    </div>
    <div class="filter-group">
      <span class="filter-label">Status:</span>
      {#each statuses as s}
        <button
          class="chip"
          class:active={statusFilter === s}
          on:click={() => toggleStatus(s)}
        >{s}</button>
      {/each}
    </div>
    <div class="filter-group">
      <span class="filter-label">Sort:</span>
      <button class="chip active" on:click={toggleSort}>
        {sortBy === 'recency' ? 'Most Recent' : 'Highest Severity'}
      </button>
    </div>
  </div>

  <EntityListPage
    title=""
    {columns}
    rows={rows as any}
    {loading}
    {error}
    {totalCount}
    onRowClick={(id) => goto(`/alerts/${id}`)}
    {fetchData}
  />
</div>

<style>
  .page-container { max-width: 1200px; }
  .page-header { margin-bottom: 1rem; }
  .page-header h1 { font-size: 1.5rem; font-weight: 600; margin: 0; }
  .subtitle { font-size: 0.875rem; color: #6b7280; margin: 0.25rem 0 0 0; }
  .header-row { display: flex; justify-content: space-between; align-items: flex-start; gap: 1rem; flex-wrap: wrap; }
  .header-actions { display: flex; gap: 0.5rem; flex-wrap: wrap; }
  .btn { padding: 0.5rem 1rem; border-radius: 0.375rem; font-size: 0.875rem; font-weight: 500; cursor: pointer; border: 1px solid #d1d5db; }
  .btn-primary { background: #2563eb; color: #fff; border-color: #2563eb; }
  .btn-primary:hover { background: #1d4ed8; }
  .btn-secondary { background: #fff; color: #374151; }
  .btn-secondary:hover { background: #f3f4f6; }
  .filters { display: flex; flex-direction: column; gap: 0.5rem; margin-bottom: 1rem; padding: 1rem; background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; }
  .filter-group { display: flex; align-items: center; gap: 0.5rem; flex-wrap: wrap; }
  .filter-label { font-size: 0.75rem; font-weight: 500; color: #6b7280; text-transform: uppercase; min-width: 4rem; }
  .chip { padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.75rem; border: 1px solid #d1d5db; background: #fff; color: #374151; cursor: pointer; text-transform: capitalize; }
  .chip:hover { background: #f3f4f6; }
  .chip.active { background: var(--chip-color, #2563eb); color: #fff; border-color: var(--chip-color, #2563eb); }
</style>
