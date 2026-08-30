<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { prescriptionClient } from '@samavāya/agriculture/services';

  let prescription: Record<string, unknown> = {};
  let exportFormat: 'csv' | 'shapefile' | 'pdf' = 'csv';
  let loading = true;
  let exporting = false;
  let error: string | null = null;
  let exportSuccess = false;

  $: id = $page.params.id;

  $: if (id) loadData(id);

  async function loadData(prescriptionId: string) {
    loading = true;
    error = null;
    try {
      const res = await prescriptionClient.getPrescription({ id: prescriptionId });
      prescription = res as any || {};
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load prescription';
    } finally {
      loading = false;
    }
  }

  async function handleExport() {
    exporting = true;
    error = null;
    exportSuccess = false;
    try {
      const res = await prescriptionClient.exportPrescription({
        id,
        format: exportFormat,
      });
      exportSuccess = true;
      const downloadUrl = (res as any).downloadUrl;
      if (downloadUrl) {
        window.open(downloadUrl, '_blank');
      }
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to export prescription';
    } finally {
      exporting = false;
    }
  }

  const formatDescriptions: Record<string, string> = {
    csv: 'Comma-separated values with zone data, rates, and coordinates. Compatible with most spreadsheet and GIS tools.',
    shapefile: 'ESRI Shapefile format for direct import into precision agriculture equipment and GIS software.',
    pdf: 'Printable report with zone map, summary table, and application rates.',
  };
</script>

<div class="page-container">
  <header class="page-header">
    <div class="header-row">
      <div>
        <h1>Export Prescription</h1>
        <p class="subtitle">Download prescription data for {prescription.fieldName ?? prescription.fieldId ?? id}</p>
      </div>
      <button
        class="rounded-md bg-gray-200 px-4 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-300"
        on:click={() => goto(`/prescriptions/${id}`)}
      >Back to Prescription</button>
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
    <div class="page-content">
      <div class="detail-grid">
        <div class="detail-field">
          <span class="detail-label">Field</span>
          <span class="detail-value">{prescription.fieldName ?? prescription.fieldId ?? '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Crop</span>
          <span class="detail-value">{prescription.cropType ?? '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Type</span>
          <span class="detail-value">{prescription.prescriptionType ?? '—'}</span>
        </div>
      </div>
    </div>

    <div class="page-content mt-4">
      <h2 class="section-title">Select Export Format</h2>
      <div class="format-options">
        <label class="format-option" class:selected={exportFormat === 'csv'}>
          <input type="radio" bind:group={exportFormat} value="csv" />
          <div class="format-info">
            <span class="format-name">CSV</span>
            <span class="format-desc">{formatDescriptions.csv}</span>
          </div>
        </label>
        <label class="format-option" class:selected={exportFormat === 'shapefile'}>
          <input type="radio" bind:group={exportFormat} value="shapefile" />
          <div class="format-info">
            <span class="format-name">Shapefile</span>
            <span class="format-desc">{formatDescriptions.shapefile}</span>
          </div>
        </label>
        <label class="format-option" class:selected={exportFormat === 'pdf'}>
          <input type="radio" bind:group={exportFormat} value="pdf" />
          <div class="format-info">
            <span class="format-name">PDF Report</span>
            <span class="format-desc">{formatDescriptions.pdf}</span>
          </div>
        </label>
      </div>

      <div class="export-actions mt-4">
        <button
          class="rounded-md bg-blue-600 px-6 py-2 text-sm font-semibold text-white hover:bg-blue-500"
          on:click={handleExport}
          disabled={exporting}
        >
          {exporting ? 'Exporting...' : `Export as ${exportFormat.toUpperCase()}`}
        </button>
      </div>

      {#if exportSuccess}
        <div class="success-banner mt-4">
          <p>Export generated successfully. Your download should start automatically.</p>
        </div>
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
  .page-content { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.5rem; }
  .error-banner { color: #dc2626; }
  .section-title { font-size: 1rem; font-weight: 600; margin: 0 0 1rem 0; }
  .detail-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem; }
  .detail-field { display: flex; flex-direction: column; gap: 0.25rem; }
  .detail-label { font-size: 0.75rem; font-weight: 500; color: #6b7280; text-transform: uppercase; }
  .detail-value { font-size: 0.875rem; color: #111827; }
  .format-options { display: flex; flex-direction: column; gap: 0.75rem; }
  .format-option { display: flex; gap: 0.75rem; padding: 1rem; border: 2px solid #e5e7eb; border-radius: 0.5rem; cursor: pointer; transition: border-color 0.15s; }
  .format-option:hover { border-color: #93c5fd; }
  .format-option.selected { border-color: #3b82f6; background: #eff6ff; }
  .format-option input { margin-top: 0.125rem; }
  .format-info { display: flex; flex-direction: column; gap: 0.25rem; }
  .format-name { font-weight: 600; font-size: 0.875rem; color: #111827; }
  .format-desc { font-size: 0.75rem; color: #6b7280; }
  .export-actions { display: flex; justify-content: flex-end; }
  .success-banner { padding: 0.75rem; background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 0.375rem; color: #166534; font-size: 0.875rem; }
  .mt-4 { margin-top: 1rem; }
</style>
