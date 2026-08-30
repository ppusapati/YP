<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { analyticsClient } from '@samavāya/agriculture/services';

  let prescription: Record<string, unknown> = {};
  let zones: any[] = [];
  let loading = true;
  let error: string | null = null;

  $: id = $page.params.id;

  $: if (id) loadData(id);

  async function loadData(prescriptionId: string) {
    loading = true;
    error = null;
    try {
      const res = await analyticsClient.getPrescription({ id: prescriptionId });
      prescription = res as any || {};
      zones = (res as any).zones || [];
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load prescription';
    } finally {
      loading = false;
    }
  }

  function zoneColor(zone: string): string {
    const colors: Record<string, string> = {
      low: '#dcfce7',
      medium: '#fef3c7',
      high: '#fee2e2',
    };
    return colors[zone?.toLowerCase()] || '#f3f4f6';
  }

  function zoneBorder(zone: string): string {
    const colors: Record<string, string> = {
      low: '#86efac',
      medium: '#fcd34d',
      high: '#fca5a5',
    };
    return colors[zone?.toLowerCase()] || '#d1d5db';
  }
</script>

<div class="page-container">
  <header class="page-header">
    <div class="header-row">
      <div>
        <h1>Prescription Detail</h1>
        <p class="subtitle">Variable-rate prescription for {prescription.fieldName ?? prescription.fieldId ?? id}</p>
      </div>
      <div class="header-actions">
        <button
          class="rounded-md bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-500"
          on:click={() => goto(`/prescriptions/${id}/export`)}
        >Export</button>
        <button
          class="rounded-md bg-gray-200 px-4 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-300"
          on:click={() => goto('/prescriptions')}
        >Back to Prescriptions</button>
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
    <!-- Prescription Info -->
    <div class="page-content">
      <div class="detail-grid">
        <div class="detail-field">
          <span class="detail-label">Field</span>
          <span class="detail-value">{prescription.fieldName ?? prescription.fieldId ?? '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Crop Type</span>
          <span class="detail-value">{prescription.cropType ?? '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Target Yield</span>
          <span class="detail-value">{prescription.targetYield ?? '—'} <small>t/ha</small></span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Created</span>
          <span class="detail-value">{prescription.createdAt ? new Date(prescription.createdAt as string).toLocaleDateString() : '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Est. Cost Savings</span>
          <span class="detail-value savings">{prescription.estimatedCostSavings != null ? `$${prescription.estimatedCostSavings}` : '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Prescription Type</span>
          <span class="detail-value">{prescription.prescriptionType ?? '—'}</span>
        </div>
      </div>
    </div>

    <!-- Zone Map Visualization -->
    <div class="page-content mt-4">
      <h2 class="section-title">Zone Map</h2>
      {#if (prescription.zoneGrid as any[])?.length}
        <div class="zone-map">
          {#each prescription.zoneGrid as row}
            <div class="zone-row">
              {#each row as cell}
                <div
                  class="zone-cell"
                  style="background: {zoneColor(cell.zone ?? cell)}; border-color: {zoneBorder(cell.zone ?? cell)}"
                  title="{cell.zone ?? cell}: {cell.rate ?? ''}"
                >
                  <span class="cell-rate">{cell.rate ?? ''}</span>
                </div>
              {/each}
            </div>
          {/each}
        </div>
        <div class="zone-legend">
          <div class="legend-item"><span class="legend-swatch" style="background: #dcfce7; border: 1px solid #86efac;"></span> Low</div>
          <div class="legend-item"><span class="legend-swatch" style="background: #fef3c7; border: 1px solid #fcd34d;"></span> Medium</div>
          <div class="legend-item"><span class="legend-swatch" style="background: #fee2e2; border: 1px solid #fca5a5;"></span> High</div>
        </div>
      {:else}
        <p class="empty-text">No zone map data available</p>
      {/if}
    </div>

    <!-- Zone Summary Table -->
    <div class="page-content mt-4">
      <h2 class="section-title">Zone Summary</h2>
      {#if zones.length > 0}
        <table class="data-table">
          <thead>
            <tr>
              <th>Zone</th>
              <th>Area (ha)</th>
              <th>Min Rate</th>
              <th>Mean Rate</th>
              <th>Max Rate</th>
              <th>Total Amount</th>
            </tr>
          </thead>
          <tbody>
            {#each zones as zone}
              <tr>
                <td>
                  <span class="zone-badge" style="background: {zoneColor(zone.zone)}; border: 1px solid {zoneBorder(zone.zone)}">
                    {zone.zone ?? '—'}
                  </span>
                </td>
                <td>{zone.areaHectares ?? '—'}</td>
                <td>{zone.minRate ?? '—'}</td>
                <td>{zone.meanRate ?? '—'}</td>
                <td>{zone.maxRate ?? '—'}</td>
                <td>{zone.totalAmount ?? '—'}</td>
              </tr>
            {/each}
          </tbody>
        </table>
      {:else}
        <p class="empty-text">No zone summary data available</p>
      {/if}
    </div>

    <!-- Rate Distribution -->
    <div class="page-content mt-4">
      <h2 class="section-title">Rate Distribution</h2>
      <div class="detail-grid">
        <div class="detail-field">
          <span class="detail-label">Total Area</span>
          <span class="detail-value">{prescription.totalArea ?? '—'} <small>ha</small></span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Total Amount</span>
          <span class="detail-value">{prescription.totalAmount ?? '—'} <small>{prescription.unit ?? ''}</small></span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Avg Rate</span>
          <span class="detail-value">{prescription.avgRate ?? '—'} <small>{prescription.unit ?? ''}/ha</small></span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Uniform Rate Comparison</span>
          <span class="detail-value">{prescription.uniformRate ?? '—'} <small>{prescription.unit ?? ''}/ha</small></span>
        </div>
      </div>
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
  .detail-value small { font-size: 0.75rem; color: #6b7280; }
  .detail-value.savings { color: #16a34a; font-weight: 600; font-size: 1rem; }
  .zone-map { display: inline-grid; gap: 2px; padding: 0.5rem; background: #f9fafb; border-radius: 0.5rem; border: 1px solid #e5e7eb; }
  .zone-row { display: flex; gap: 2px; }
  .zone-cell { width: 40px; height: 40px; border-radius: 0.25rem; border: 1px solid; display: flex; align-items: center; justify-content: center; }
  .cell-rate { font-size: 0.625rem; font-weight: 500; color: #374151; }
  .zone-legend { display: flex; gap: 1rem; margin-top: 0.75rem; }
  .legend-item { display: flex; align-items: center; gap: 0.375rem; font-size: 0.75rem; color: #374151; }
  .legend-swatch { width: 16px; height: 16px; border-radius: 0.25rem; display: inline-block; }
  .data-table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
  .data-table th { text-align: left; padding: 0.5rem 0.75rem; border-bottom: 2px solid #e5e7eb; font-weight: 500; color: #6b7280; font-size: 0.75rem; text-transform: uppercase; }
  .data-table td { padding: 0.5rem 0.75rem; border-bottom: 1px solid #f3f4f6; }
  .zone-badge { display: inline-block; padding: 0.125rem 0.5rem; border-radius: 0.25rem; font-size: 0.75rem; font-weight: 500; text-transform: capitalize; }
  .empty-text { color: #6b7280; font-size: 0.875rem; }
  .mt-4 { margin-top: 1rem; }
</style>
