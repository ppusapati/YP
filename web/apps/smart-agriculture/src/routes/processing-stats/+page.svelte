<script lang="ts">
  import { processingClient } from '@samavāya/agriculture/services';

  let stats: any = null;
  let loading = true;
  let error: string | null = null;

  async function loadStats() {
    loading = true;
    try {
      const res = await processingClient.getProcessingStats({});
      stats = res;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load processing stats';
    } finally {
      loading = false;
    }
  }

  loadStats();
</script>

<div class="p-6">
  <h1 class="text-2xl font-semibold text-gray-900 mb-6">Processing Statistics</h1>

  {#if loading}
    <p class="text-gray-500">Loading...</p>
  {:else if error}
    <p class="text-red-600">{error}</p>
  {:else if stats}
    <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-5">
      <div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
        <p class="text-sm text-gray-500">Total Jobs</p>
        <p class="mt-1 text-3xl font-bold text-gray-900">{stats.totalJobs}</p>
      </div>
      <div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
        <p class="text-sm text-gray-500">Completed</p>
        <p class="mt-1 text-3xl font-bold text-green-600">{stats.completedJobs}</p>
      </div>
      <div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
        <p class="text-sm text-gray-500">Failed</p>
        <p class="mt-1 text-3xl font-bold text-red-600">{stats.failedJobs}</p>
      </div>
      <div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
        <p class="text-sm text-gray-500">Pending</p>
        <p class="mt-1 text-3xl font-bold text-yellow-600">{stats.pendingJobs}</p>
      </div>
      <div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
        <p class="text-sm text-gray-500">Avg Processing Time</p>
        <p class="mt-1 text-3xl font-bold text-blue-600">{stats.avgProcessingTimeSeconds?.toFixed(1)}s</p>
      </div>
    </div>
  {/if}
</div>
