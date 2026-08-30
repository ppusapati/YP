<script lang="ts">
  import { goto } from '$app/navigation';
  import { prescriptionClient } from '@samavāya/agriculture/services';

  let prescriptions: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;
  let typeFilter: string = '';

  const prescriptionTypes = [
    { label: 'All Types', value: '' },
    { label: 'Fertilizer', value: 'fertilizer' },
    { label: 'Irrigation', value: 'irrigation' },
    { label: 'Seeding', value: 'seeding' },
    { label: 'Liming', value: 'liming' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25) {
    loading = true;
    error = null;
    try {
      const params: Record<string, unknown> = { pageSize, pageOffset };
      if (typeFilter) params.prescriptionType = typeFilter;
      const res = await prescriptionClient.listPrescriptions(params);
      prescriptions = (res as any).prescriptions || [];
      totalCount = (res as any).totalCount || 0;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load prescriptions';
      prescriptions = [];
    } finally {
      loading = false;
    }
  }

  function formatDate(dateStr: string | undefined): string {
    if (!dateStr) return '—';
    try {
      return new Date(dateStr).toLocaleDateString();
    } catch {
      return dateStr;
    }
  }

  fetchData();
</script>

<div class="page-container">
  <header class="page-header">
    <div class="header-row">
      <div>
        <h1>Prescription Maps</h1>
        <p class="subtitle">Manage variable-rate prescriptions for precision agriculture</p>
      </div>
      <button
        class="rounded-md bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-500"
        on:click={() => goto('/prescriptions/generate')}
      >Generate Prescription</button>
    </div>
  </header>

  <div class="page-content">
    <div class="filter-row">
      <div class="selector-field">
        <label for="type-filter">Prescription Type</label>
        <select id="type-filter" bind:value={typeFilter} on:change={() => fetchData()}>
          {#each prescriptionTypes as opt}
            <option value={opt.value}>{opt.label}</option>
          {/each}
        </select>
      </div>
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
  {:else if prescriptions.length === 0}
    <div class="page-content mt-4">
      <p class="empty-text">No prescriptions found. Generate your first prescription to get started.</p>
    </div>
  {:else}
    <div class="page-content mt-4">
      <div class="prescriptions-list">
        {#each prescriptions as rx}
          <button class="prescription-row" on:click={() => goto(`/prescriptions/${rx.id}`)}>
            <div class="rx-info">
              <span class="rx-field">{rx.fieldName ?? rx.fieldId ?? '—'}</span>
              <span class="rx-meta">
                {rx.cropType ?? ''} &middot; {formatDate(rx.createdAt)}
              </span>
            </div>
            <div class="rx-tags">
              {#if rx.prescriptionTypes?.length}
                {#each rx.prescriptionTypes as pType}
                  <span class="type-tag type-{pType}">{pType}</span>
                {/each}
              {:else if rx.prescriptionType}
                <span class="type-tag type-{rx.prescriptionType}">{rx.prescriptionType}</span>
              {/if}
            </div>
            <div class="rx-savings">
              {#if rx.estimatedCostSavings != null}
                <span class="savings-badge">${rx.estimatedCostSavings}</span>
                <span class="savings-label">est. savings</span>
              {/if}
            </div>
            <span class="rx-arrow">&#8250;</span>
          </button>
        {/each}
      </div>

      {#if totalCount > prescriptions.length}
        <div class="pagination mt-4">
          <span class="pagination-info">Showing {prescriptions.length} of {totalCount}</span>
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
  .filter-row { display: flex; gap: 1rem; }
  .selector-field { display: flex; flex-direction: column; gap: 0.25rem; min-width: 200px; }
  .selector-field label { font-size: 0.75rem; font-weight: 500; color: #6b7280; text-transform: uppercase; }
  .selector-field select { border: 1px solid #d1d5db; border-radius: 0.375rem; padding: 0.5rem 0.75rem; font-size: 0.875rem; }
  .prescriptions-list { display: flex; flex-direction: column; gap: 0.5rem; }
  .prescription-row { display: flex; align-items: center; gap: 1rem; padding: 1rem; border: 1px solid #e5e7eb; border-radius: 0.5rem; background: #fff; cursor: pointer; text-align: left; width: 100%; transition: border-color 0.15s; }
  .prescription-row:hover { border-color: #3b82f6; }
  .rx-info { display: flex; flex-direction: column; flex: 1; }
  .rx-field { font-weight: 600; font-size: 0.875rem; color: #111827; }
  .rx-meta { font-size: 0.75rem; color: #6b7280; margin-top: 0.125rem; }
  .rx-tags { display: flex; gap: 0.375rem; flex-wrap: wrap; }
  .type-tag { font-size: 0.625rem; font-weight: 500; text-transform: uppercase; padding: 0.125rem 0.5rem; border-radius: 999px; }
  .type-fertilizer { background: #fef3c7; color: #92400e; }
  .type-irrigation { background: #dbeafe; color: #1e40af; }
  .type-seeding { background: #dcfce7; color: #166534; }
  .type-liming { background: #f3e8ff; color: #6b21a8; }
  .rx-savings { display: flex; flex-direction: column; align-items: flex-end; min-width: 80px; }
  .savings-badge { font-weight: 600; font-size: 0.875rem; color: #16a34a; }
  .savings-label { font-size: 0.625rem; color: #6b7280; }
  .rx-arrow { font-size: 1.25rem; color: #9ca3af; }
  .empty-text { color: #6b7280; font-size: 0.875rem; }
  .pagination { text-align: center; }
  .pagination-info { font-size: 0.75rem; color: #6b7280; }
  .mt-4 { margin-top: 1rem; }
</style>
