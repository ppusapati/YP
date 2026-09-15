<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { alertClient } from '@samavāya/agriculture/services';
  import { AlertSeverity, AlertStatus } from '@samavāya/proto';
  import type { Timestamp } from '@bufbuild/protobuf/wkt';

  /**
   * Severity and status are protobuf enums on the wire, not strings.
   *
   * This page filtered with `'critical'` and `'active'` and rendered the
   * `severity` column straight out of the message, which meant the request
   * carried a string where a number belongs and the table showed `3` where the
   * user expected "Critical". Both halves go through these tables now.
   *
   * The type and sort filters are gone: `ListAlertsRequest` has neither a
   * `type` nor a `sort_by` field, so those eight chips sent nothing and the
   * list never changed when they were clicked. A filter that looks like it
   * works is worse than one that is not offered.
   */

  const SEVERITIES = [
    { value: AlertSeverity.INFO, label: 'Info', color: '#0284c7' },
    { value: AlertSeverity.WARNING, label: 'Warning', color: '#ca8a04' },
    { value: AlertSeverity.CRITICAL, label: 'Critical', color: '#ea580c' },
    { value: AlertSeverity.EMERGENCY, label: 'Emergency', color: '#dc2626' },
  ];

  // No 'expired': alert.proto declares active, acknowledged and resolved only.
  const STATUSES = [
    { value: AlertStatus.ACTIVE, label: 'Active' },
    { value: AlertStatus.ACKNOWLEDGED, label: 'Acknowledged' },
    { value: AlertStatus.RESOLVED, label: 'Resolved' },
  ];

  let rows: Record<string, unknown>[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  let severityFilter: AlertSeverity | null = null;
  let statusFilter: AlertStatus | null = null;

  /**
   * Page tokens seen so far, indexed by page. `listAlerts` is token-paginated
   * and `EntityListPage` counts in offsets, so the offset is divided back into
   * a page number and used to look up the token that opens it.
   */
  let pageTokens: string[] = [''];

  const columns = [
    { key: 'severity', label: 'Severity', format: (v: unknown) => severityLabel(v as AlertSeverity) },
    { key: 'title', label: 'Title' },
    { key: 'type', label: 'Type', format: (v: unknown) => formatType(v as string) },
    { key: 'fieldName', label: 'Field' },
    { key: 'status', label: 'Status', format: (v: unknown) => statusLabel(v as AlertStatus) },
    { key: 'timestamp', label: 'Time', format: (v: unknown) => formatTimeAgo(v as Timestamp | undefined) },
  ];

  function severityLabel(s: AlertSeverity): string {
    return SEVERITIES.find((x) => x.value === s)?.label ?? 'Unspecified';
  }

  function statusLabel(s: AlertStatus): string {
    return STATUSES.find((x) => x.value === s)?.label ?? 'Unspecified';
  }

  function formatType(type: string): string {
    if (!type) return '—';
    return type.replace(/([A-Z])/g, ' $1').replace(/^./, (s) => s.toUpperCase()).trim();
  }

  function formatTimeAgo(ts: Timestamp | undefined): string {
    if (!ts?.seconds) return '—';
    const d = new Date(Number(ts.seconds) * 1000);
    const mins = Math.floor((Date.now() - d.getTime()) / 60000);
    if (mins < 60) return `${mins}m ago`;
    const hours = Math.floor(mins / 60);
    if (hours < 24) return `${hours}h ago`;
    const days = Math.floor(hours / 24);
    if (days < 7) return `${days}d ago`;
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  }

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const pageIndex = Math.floor(pageOffset / Math.max(pageSize, 1));
      const res = await alertClient.listAlerts({
        pageSize,
        pageToken: pageTokens[pageIndex] ?? '',
        severity: severityFilter ?? AlertSeverity.UNSPECIFIED,
        status: statusFilter ?? AlertStatus.UNSPECIFIED,
      });
      if (res.nextPageToken) pageTokens[pageIndex + 1] = res.nextPageToken;
      rows = res.alerts as unknown as Record<string, unknown>[];
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

  function toggleSeverity(s: AlertSeverity) {
    severityFilter = severityFilter === s ? null : s;
    pageTokens = [''];
    fetchData();
  }

  function toggleStatus(s: AlertStatus) {
    statusFilter = statusFilter === s ? null : s;
    pageTokens = [''];
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
      {#each SEVERITIES as s}
        <button
          class="chip"
          class:active={severityFilter === s.value}
          style:--chip-color={s.color}
          on:click={() => toggleSeverity(s.value)}
        >{s.label}</button>
      {/each}
    </div>
    <div class="filter-group">
      <span class="filter-label">Status:</span>
      {#each STATUSES as s}
        <button
          class="chip"
          class:active={statusFilter === s.value}
          on:click={() => toggleStatus(s.value)}
        >{s.label}</button>
      {/each}
    </div>
  </div>

  <EntityListPage
    title=""
    {columns}
    {rows}
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
