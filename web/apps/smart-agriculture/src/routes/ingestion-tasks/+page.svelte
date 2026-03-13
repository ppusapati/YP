<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { ingestionClient } from '@samavāya/agriculture/services';
  import type { IngestionTask } from '@samavāya/proto';

  let rows: IngestionTask[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'farm_id', label: 'Farm' },
    { key: 'provider', label: 'Provider' },
    { key: 'status', label: 'Status' },
    { key: 'cloudCoverPercent', label: 'Cloud %' },
    { key: 'acquisitionDate', label: 'Captured' },
    { key: 'createdAt', label: 'Created' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await ingestionClient.listIngestionTasks({ pageSize, pageToken: '' });
      rows = res.tasks;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load ingestion tasks';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Ingestion Tasks"
  createHref="/ingestion-tasks/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/ingestion-tasks/${id}`)}
  {totalCount}
  {fetchData}
/>
