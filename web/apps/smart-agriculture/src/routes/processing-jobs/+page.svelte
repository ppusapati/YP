<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { processingClient } from '@samavāya/agriculture/services';
  import type { ProcessingJob } from '@samavāya/proto';

  let rows: ProcessingJob[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'ingestionTaskId', label: 'Ingestion Task' },
    { key: 'farmId', label: 'Farm' },
    { key: 'status', label: 'Status' },
    { key: 'inputLevel', label: 'Input Level' },
    { key: 'outputLevel', label: 'Output Level' },
    { key: 'algorithm', label: 'Algorithm' },
    { key: 'processingTimeSeconds', label: 'Time (s)' },
    { key: 'createdAt', label: 'Created' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await processingClient.listProcessingJobs({ pageSize, pageToken: '' });
      rows = res.jobs;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load processing jobs';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Processing Jobs"
  createHref="/processing-jobs/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/processing-jobs/${id}`)}
  {totalCount}
  {fetchData}
/>
