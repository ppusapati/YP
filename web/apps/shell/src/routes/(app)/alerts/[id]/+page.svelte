<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { analyticsClient } from '@samavāya/agriculture/services';

  let alert: Record<string, unknown> = {};
  let loading = true;
  let error: string | null = null;
  let isSubmitting = false;

  $: id = $page.params.id;

  $: if (id) loadData(id);

  async function loadData(alertId: string) {
    loading = true;
    error = null;
    try {
      const res = await analyticsClient.getAlert({ id: alertId });
      alert = res.alert as any || {};
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load alert';
    } finally {
      loading = false;
    }
  }

  async function handleAcknowledge() {
    isSubmitting = true;
    error = null;
    try {
      await analyticsClient.acknowledgeAlert({ id });
      await loadData(id);
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to acknowledge alert';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleResolve() {
    isSubmitting = true;
    error = null;
    try {
      await analyticsClient.resolveAlert({ id });
      await loadData(id);
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to resolve alert';
    } finally {
      isSubmitting = false;
    }
  }

  function severityColor(s: unknown): string {
    switch (s) {
      case 'emergency': return '#dc2626';
      case 'critical': return '#ea580c';
      case 'warning': return '#ca8a04';
      case 'info': return '#0284c7';
      default: return '#6b7280';
    }
  }

  function severityBg(s: unknown): string {
    switch (s) {
      case 'emergency': return '#fef2f2';
      case 'critical': return '#fff7ed';
      case 'warning': return '#fefce8';
      case 'info': return '#eff6ff';
      default: return '#f9fafb';
    }
  }

  function formatType(type: string): string {
    return type.replace(/([A-Z])/g, ' $1').replace(/^./, (s) => s.toUpperCase()).trim();
  }
</script>

<div class="page-container">
  <header class="page-header">
    <h1>Alert Details</h1>
    <p class="subtitle">View alert information and take action</p>
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
    <!-- Severity banner -->
    <div class="severity-banner" style:background={severityBg(alert.severity)} style:border-color={severityColor(alert.severity)}>
      <span class="severity-badge" style:background={severityColor(alert.severity)}>
        {(alert.severity as string ?? 'unknown').toUpperCase()}
      </span>
      {#if alert.status && alert.status !== 'active'}
        <span class="status-badge">{alert.status}</span>
      {/if}
    </div>

    <div class="page-content">
      <h2 class="alert-title">{alert.title ?? '—'}</h2>

      <div class="detail-grid">
        <div class="detail-field">
          <span class="detail-label">Type</span>
          <span class="detail-value">{alert.type ? formatType(alert.type as string) : '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Field</span>
          <span class="detail-value">
            {#if alert.fieldId}
              <a href="/farm-management/fields/{alert.fieldId}">{alert.fieldName ?? alert.fieldId}</a>
            {:else}
              —
            {/if}
          </span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Farm ID</span>
          <span class="detail-value">{alert.farmId ?? '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Timestamp</span>
          <span class="detail-value">{alert.timestamp ? new Date(alert.timestamp as string).toLocaleString() : '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Status</span>
          <span class="detail-value">{alert.status ?? '—'}</span>
        </div>
        {#if alert.acknowledgedAt}
          <div class="detail-field">
            <span class="detail-label">Acknowledged</span>
            <span class="detail-value">
              {new Date(alert.acknowledgedAt as string).toLocaleString()}
              {#if alert.acknowledgedBy}
                by {alert.acknowledgedBy}
              {/if}
            </span>
          </div>
        {/if}
      </div>

      <!-- Message -->
      <div class="section">
        <h3>Description</h3>
        <p class="message">{alert.message ?? '—'}</p>
      </div>

      <!-- Recommendations -->
      {#if Array.isArray(alert.recommendations) && (alert.recommendations as string[]).length > 0}
        <div class="section">
          <h3>Recommendations</h3>
          <ol class="recommendations">
            {#each alert.recommendations as rec}
              <li>{rec}</li>
            {/each}
          </ol>
        </div>
      {/if}

      <!-- Metrics -->
      {#if alert.metrics && typeof alert.metrics === 'object'}
        <div class="section">
          <h3>Metrics</h3>
          <div class="metrics-grid">
            {#each Object.entries(alert.metrics as Record<string, unknown>) as [key, value]}
              <div class="metric-card">
                <span class="metric-label">{key.replace(/([A-Z])/g, ' $1').replace(/_/g, ' ')}</span>
                <span class="metric-value">{value}</span>
              </div>
            {/each}
          </div>
        </div>
      {/if}
    </div>

    <div class="actions">
      {#if alert.status === 'active'}
        <button
          class="btn btn-primary"
          on:click={handleAcknowledge}
          disabled={isSubmitting}
        >Acknowledge Alert</button>
      {/if}
      {#if alert.status === 'acknowledged'}
        <button
          class="btn btn-success"
          on:click={handleResolve}
          disabled={isSubmitting}
        >Resolve Alert</button>
      {/if}
      <button
        class="btn btn-secondary"
        on:click={() => goto('/alerts')}
      >Back to Alerts</button>
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
  .severity-banner { display: flex; align-items: center; gap: 0.75rem; padding: 0.75rem 1rem; border-radius: 0.5rem; border: 1px solid; margin-bottom: 1rem; }
  .severity-badge { color: #fff; padding: 0.25rem 0.75rem; border-radius: 0.25rem; font-size: 0.75rem; font-weight: 700; letter-spacing: 0.05em; }
  .status-badge { padding: 0.25rem 0.75rem; border-radius: 0.25rem; font-size: 0.75rem; font-weight: 500; background: #e5e7eb; color: #374151; text-transform: capitalize; }
  .alert-title { font-size: 1.25rem; font-weight: 600; margin: 0 0 1rem 0; }
  .detail-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 1rem; }
  .detail-field { display: flex; flex-direction: column; gap: 0.25rem; }
  .detail-label { font-size: 0.75rem; font-weight: 500; color: #6b7280; text-transform: uppercase; }
  .detail-value { font-size: 0.875rem; color: #111827; }
  .detail-value a { color: #2563eb; text-decoration: none; }
  .detail-value a:hover { text-decoration: underline; }
  .section { margin-top: 1.5rem; }
  .section h3 { font-size: 0.875rem; font-weight: 600; margin: 0 0 0.75rem 0; color: #374151; }
  .message { font-size: 0.875rem; color: #374151; line-height: 1.6; margin: 0; }
  .recommendations { margin: 0; padding-left: 1.25rem; }
  .recommendations li { font-size: 0.875rem; color: #374151; line-height: 1.6; margin-bottom: 0.5rem; }
  .metrics-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 0.75rem; }
  .metric-card { background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 0.75rem; display: flex; flex-direction: column; gap: 0.25rem; }
  .metric-label { font-size: 0.7rem; font-weight: 500; color: #6b7280; text-transform: capitalize; }
  .metric-value { font-size: 1.125rem; font-weight: 600; color: #111827; }
  .actions { margin-top: 1rem; display: flex; gap: 0.75rem; }
  .btn { padding: 0.5rem 1rem; border-radius: 0.375rem; font-size: 0.875rem; font-weight: 600; cursor: pointer; border: 1px solid; }
  .btn:disabled { opacity: 0.5; cursor: not-allowed; }
  .btn-primary { background: #2563eb; color: #fff; border-color: #2563eb; }
  .btn-primary:hover:not(:disabled) { background: #1d4ed8; }
  .btn-success { background: #16a34a; color: #fff; border-color: #16a34a; }
  .btn-success:hover:not(:disabled) { background: #15803d; }
  .btn-secondary { background: #fff; color: #374151; border-color: #d1d5db; }
  .btn-secondary:hover { background: #f3f4f6; }
</style>
