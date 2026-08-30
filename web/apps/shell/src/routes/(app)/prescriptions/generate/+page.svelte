<script lang="ts">
  import { goto } from '$app/navigation';
  import { analyticsClient } from '@samavāya/agriculture/services';
  import { fieldClient } from '@samavāya/agriculture/services';

  let fieldId = '';
  let cropType = '';
  let targetYield = '';
  let soilDataText = '';
  let fieldOptions: { label: string; value: string }[] = [];
  let isSubmitting = false;
  let error: string | null = null;

  const cropTypes = ['Corn', 'Soybean', 'Wheat', 'Cotton', 'Rice', 'Barley', 'Sorghum', 'Canola'];

  async function loadFields(query = '') {
    try {
      const res = await fieldClient.listFields({ search: query, pageSize: 100 });
      fieldOptions = (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
    } catch {
      fieldOptions = [];
    }
  }

  function parseSoilData(text: string): { rows: number; cols: number; data: number[][] } | null {
    if (!text.trim()) return null;
    try {
      const lines = text.trim().split('\n').filter((l) => l.trim());
      const data = lines.map((line) =>
        line.split(/[,\t\s]+/).map((v) => parseFloat(v)).filter((v) => !isNaN(v))
      );
      if (data.length === 0 || data[0].length === 0) return null;
      return { rows: data.length, cols: data[0].length, data };
    } catch {
      return null;
    }
  }

  async function handleSubmit() {
    if (!fieldId || !cropType || !targetYield) return;
    isSubmitting = true;
    error = null;
    try {
      const soilGrid = parseSoilData(soilDataText);
      const params: Record<string, unknown> = {
        fieldId,
        cropType,
        targetYield: parseFloat(targetYield),
      };
      if (soilGrid) params.soilData = soilGrid;
      const res = await analyticsClient.generatePrescription(params);
      const prescriptionId = (res as any).id || (res as any).prescriptionId;
      if (prescriptionId) {
        goto(`/prescriptions/${prescriptionId}`);
      } else {
        goto('/prescriptions');
      }
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to generate prescription';
    } finally {
      isSubmitting = false;
    }
  }

  loadFields();
</script>

<div class="page-container">
  <header class="page-header">
    <div class="header-row">
      <div>
        <h1>Generate Prescription</h1>
        <p class="subtitle">Create a variable-rate prescription map for your field</p>
      </div>
      <button
        class="rounded-md bg-gray-200 px-4 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-300"
        on:click={() => goto('/prescriptions')}
      >Cancel</button>
    </div>
  </header>

  <div class="page-content">
    {#if error}
      <div class="error-banner mb-4">
        <p>{error}</p>
      </div>
    {/if}

    <form on:submit|preventDefault={handleSubmit} class="form-grid">
      <div class="form-field">
        <label for="field-select">Field</label>
        <select id="field-select" bind:value={fieldId} required>
          <option value="">Select a field</option>
          {#each fieldOptions as opt}
            <option value={opt.value}>{opt.label}</option>
          {/each}
        </select>
      </div>

      <div class="form-field">
        <label for="crop-select">Crop Type</label>
        <select id="crop-select" bind:value={cropType} required>
          <option value="">Select crop type</option>
          {#each cropTypes as crop}
            <option value={crop}>{crop}</option>
          {/each}
        </select>
      </div>

      <div class="form-field">
        <label for="target-yield">Target Yield (t/ha)</label>
        <input
          id="target-yield"
          type="number"
          step="0.1"
          min="0"
          bind:value={targetYield}
          placeholder="e.g. 12.5"
          required
        />
      </div>

      <div class="form-field full-width">
        <label for="soil-data">Soil Data Grid</label>
        <p class="field-help">Enter soil test values as a grid (comma or tab separated, one row per line). Optional.</p>
        <textarea
          id="soil-data"
          bind:value={soilDataText}
          rows="6"
          placeholder="45, 52, 48, 50&#10;38, 42, 46, 44&#10;35, 38, 40, 42"
        ></textarea>
        {#if soilDataText.trim()}
          {@const parsed = parseSoilData(soilDataText)}
          {#if parsed}
            <p class="field-help parsed-info">Parsed: {parsed.rows} rows x {parsed.cols} columns</p>
          {:else}
            <p class="field-help parse-error">Could not parse soil data. Use comma or tab-separated numbers.</p>
          {/if}
        {/if}
      </div>

      <div class="form-actions full-width">
        <button
          type="submit"
          class="rounded-md bg-blue-600 px-6 py-2 text-sm font-semibold text-white hover:bg-blue-500"
          disabled={!fieldId || !cropType || !targetYield || isSubmitting}
        >
          {isSubmitting ? 'Generating...' : 'Generate Prescription'}
        </button>
      </div>
    </form>
  </div>
</div>

<style>
  .page-container { max-width: 1200px; }
  .page-header { margin-bottom: 1.5rem; }
  .page-header h1 { font-size: 1.5rem; font-weight: 600; margin: 0; }
  .subtitle { font-size: 0.875rem; color: #6b7280; margin: 0.25rem 0 0 0; }
  .header-row { display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem; }
  .page-content { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.5rem; }
  .error-banner { color: #dc2626; padding: 0.75rem; background: #fef2f2; border: 1px solid #fecaca; border-radius: 0.375rem; }
  .mb-4 { margin-bottom: 1rem; }
  .form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 1.5rem; }
  .form-field { display: flex; flex-direction: column; gap: 0.375rem; }
  .form-field label { font-size: 0.75rem; font-weight: 500; color: #6b7280; text-transform: uppercase; }
  .form-field select,
  .form-field input,
  .form-field textarea { border: 1px solid #d1d5db; border-radius: 0.375rem; padding: 0.5rem 0.75rem; font-size: 0.875rem; font-family: inherit; }
  .form-field textarea { resize: vertical; }
  .field-help { font-size: 0.75rem; color: #6b7280; margin: 0; }
  .parsed-info { color: #16a34a; }
  .parse-error { color: #dc2626; }
  .full-width { grid-column: 1 / -1; }
  .form-actions { display: flex; gap: 0.75rem; justify-content: flex-end; padding-top: 0.5rem; }
</style>
