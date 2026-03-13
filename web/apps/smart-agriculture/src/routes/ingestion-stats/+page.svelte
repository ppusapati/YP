<script lang="ts">
  import { ingestionClient } from '@samavāya/agriculture/services';

  let stats: any = null;
  let loading = true;
  let error: string | null = null;

  async function loadStats() {
    loading = true;
    try {
      const res = await ingestionClient.getIngestionStats({});
      stats = res;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load ingestion stats';
    } finally {
      loading = false;
    }
  }

  loadStats();
</script>

<div class="p-6">
  <h1 class="text-2xl font-semibold text-gray-900 mb-6">Ingestion Statistics</h1>

  {#if loading}
    <p class="text-gray-500">Loading...</p>
  {:else if error}
    <p class="text-red-600">{error}</p>
  {:else if stats}
    <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
      <div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
        <p class="text-sm text-gray-500">Total Tasks</p>
        <p class="mt-1 text-3xl font-bold text-gray-900">{stats.totalTasks}</p>
      </div>
      <div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
        <p class="text-sm text-gray-500">Completed</p>
        <p class="mt-1 text-3xl font-bold text-green-600">{stats.completedTasks}</p>
      </div>
      <div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
        <p class="text-sm text-gray-500">Failed</p>
        <p class="mt-1 text-3xl font-bold text-red-600">{stats.failedTasks}</p>
      </div>
      <div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
        <p class="text-sm text-gray-500">Pending</p>
        <p class="mt-1 text-3xl font-bold text-yellow-600">{stats.pendingTasks}</p>
      </div>
    </div>
    <div class="mt-4 rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
      <p class="text-sm text-gray-500">Total Storage Used</p>
      <p class="mt-1 text-2xl font-bold text-gray-900">{(stats.totalBytesStored / 1073741824).toFixed(2)} GB</p>
    </div>
  {/if}
</div>
