<script lang="ts">
  import { farmClient, fieldClient, vegetationIndexClient } from '@samavāya/agriculture/services';

  let farmId = '';
  let fieldId = '';
  let farmQuery = '';
  let fieldQuery = '';
  let farmOptions: { label: string; value: string }[] = [];
  let fieldOptions: { label: string; value: string }[] = [];
  let loading = false;
  let error: string | null = null;
  let healthData: Record<string, unknown> | null = null;

  async function searchFarms(query: string) {
    farmQuery = query;
    try {
      const res = await farmClient.listFarms({ search: query, pageSize: 50 });
      farmOptions = (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
    } catch {
      farmOptions = [];
    }
  }

  async function searchFields(query: string) {
    fieldQuery = query;
    try {
      const res = await fieldClient.listFields({ search: query, pageSize: 50 });
      fieldOptions = (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
    } catch {
      fieldOptions = [];
    }
  }

  async function fetchHealth() {
    if (!farmId || !fieldId) {
      error = 'Please select both a farm and a field.';
      return;
    }
    loading = true;
    error = null;
    healthData = null;
    try {
      const res = await vegetationIndexClient.getFieldHealth({ farmId, fieldId });
      healthData = res as Record<string, unknown>;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load field health data';
    } finally {
      loading = false;
    }
  }

  function healthCategoryColor(category: string | undefined): string {
    switch (category) {
      case 'Excellent': return 'text-green-700 bg-green-100';
      case 'Good': return 'text-green-600 bg-green-50';
      case 'Fair': return 'text-yellow-700 bg-yellow-100';
      case 'Poor': return 'text-red-600 bg-red-50';
      case 'Critical': return 'text-red-700 bg-red-100';
      default: return 'text-gray-700 bg-gray-100';
    }
  }
</script>

<div class="max-w-4xl mx-auto p-6">
  <header class="mb-6">
    <h1 class="text-2xl font-bold text-gray-900">Field Health Dashboard</h1>
    <p class="text-sm text-gray-500 mt-1">Monitor vegetation health metrics for a specific field</p>
  </header>

  <div class="bg-white border border-gray-200 rounded-lg p-6 mb-6">
    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-4">
      <div>
        <label for="farm-select" class="block text-sm font-medium text-gray-700 mb-1">Farm</label>
        <input
          id="farm-select"
          type="text"
          class="block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
          placeholder="Search farms..."
          bind:value={farmQuery}
          on:input={() => searchFarms(farmQuery)}
        />
        {#if farmOptions.length > 0}
          <ul class="mt-1 max-h-40 overflow-y-auto border border-gray-200 rounded-md bg-white shadow-sm">
            {#each farmOptions as option}
              <li>
                <button
                  type="button"
                  class="w-full px-3 py-2 text-left text-sm hover:bg-indigo-50"
                  on:click={() => { farmId = option.value; farmQuery = option.label; farmOptions = []; }}
                >{option.label}</button>
              </li>
            {/each}
          </ul>
        {/if}
      </div>
      <div>
        <label for="field-select" class="block text-sm font-medium text-gray-700 mb-1">Field</label>
        <input
          id="field-select"
          type="text"
          class="block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
          placeholder="Search fields..."
          bind:value={fieldQuery}
          on:input={() => searchFields(fieldQuery)}
        />
        {#if fieldOptions.length > 0}
          <ul class="mt-1 max-h-40 overflow-y-auto border border-gray-200 rounded-md bg-white shadow-sm">
            {#each fieldOptions as option}
              <li>
                <button
                  type="button"
                  class="w-full px-3 py-2 text-left text-sm hover:bg-indigo-50"
                  on:click={() => { fieldId = option.value; fieldQuery = option.label; fieldOptions = []; }}
                >{option.label}</button>
              </li>
            {/each}
          </ul>
        {/if}
      </div>
    </div>
    <button
      class="rounded-md bg-indigo-600 px-4 py-2 text-sm font-semibold text-white hover:bg-indigo-500 disabled:opacity-50"
      on:click={fetchHealth}
      disabled={loading}
    >{loading ? 'Loading...' : 'Get Field Health'}</button>
  </div>

  {#if error}
    <div class="rounded-md bg-red-50 border border-red-200 p-4 mb-6">
      <p class="text-sm text-red-700">{error}</p>
    </div>
  {/if}

  {#if healthData}
    <div class="bg-white border border-gray-200 rounded-lg p-6">
      <h2 class="text-lg font-semibold text-gray-900 mb-4">Health Summary</h2>
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <div class="rounded-md bg-gray-50 p-4">
          <p class="text-sm text-gray-500">Current NDVI</p>
          <p class="text-2xl font-bold">{healthData.currentNdvi ?? '—'}</p>
        </div>
        <div class="rounded-md bg-gray-50 p-4">
          <p class="text-sm text-gray-500">NDVI Trend</p>
          <p class="text-2xl font-bold">{healthData.ndviTrend ?? '—'}</p>
        </div>
        <div class="rounded-md bg-gray-50 p-4">
          <p class="text-sm text-gray-500">Health Score</p>
          <p class="text-2xl font-bold">{healthData.healthScore ?? '—'}</p>
        </div>
        <div class="rounded-md p-4 {healthCategoryColor(healthData.healthCategory as string)}">
          <p class="text-sm opacity-75">Health Category</p>
          <p class="text-2xl font-bold">{healthData.healthCategory ?? '—'}</p>
        </div>
        <div class="rounded-md bg-gray-50 p-4">
          <p class="text-sm text-gray-500">Last Computed</p>
          <p class="text-2xl font-bold">{healthData.lastComputed ?? '—'}</p>
        </div>
      </div>
    </div>
  {/if}
</div>
