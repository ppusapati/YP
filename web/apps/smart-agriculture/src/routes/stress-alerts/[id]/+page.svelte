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
      const res = await analyticsClient.getStressAlert({ id: alertId });
      alert = res.alert as any || {};
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load stress alert';
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
</script>

<div class="page-container">
  <header class="page-header">
    <h1>Stress Alert Details</h1>
    <p class="subtitle">View stress alert information and take action</p>
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
    <div class="page-content">
      <div class="detail-grid">
        <div class="detail-field">
          <span class="detail-label">Farm ID</span>
          <span class="detail-value">{alert.farmId ?? '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Field ID</span>
          <span class="detail-value">{alert.fieldId ?? '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Stress Type</span>
          <span class="detail-value">{alert.stressType ?? '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Severity</span>
          <span class="detail-value">{alert.severity ?? '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Confidence</span>
          <span class="detail-value">{alert.confidence ?? '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Affected Area (ha)</span>
          <span class="detail-value">{alert.affectedAreaHectares ?? '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Acknowledged</span>
          <span class="detail-value">{alert.acknowledged ? 'Yes' : 'No'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Detected At</span>
          <span class="detail-value">{alert.detectedAt ?? '—'}</span>
        </div>
      </div>
    </div>

    <div class="mt-4 flex gap-3 px-6">
      <button
        class="rounded-md bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-500"
        on:click={handleAcknowledge}
        disabled={isSubmitting || !!alert.acknowledged}
      >Acknowledge Alert</button>
      <button
        class="rounded-md bg-gray-200 px-4 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-300"
        on:click={() => goto('/stress-alerts')}
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
  .detail-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 1rem; }
  .detail-field { display: flex; flex-direction: column; gap: 0.25rem; }
  .detail-label { font-size: 0.75rem; font-weight: 500; color: #6b7280; text-transform: uppercase; }
  .detail-value { font-size: 0.875rem; color: #111827; }
</style>
