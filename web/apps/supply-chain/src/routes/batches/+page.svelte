<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { traceabilityClient } from '@samavāya/agriculture/services';
  import type { BatchRecord } from '@samavāya/agriculture/types';

  let rows: BatchRecord[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'batchNumber', label: 'Batch #' },
    { key: 'productType', label: 'Product' },
    { key: 'quantity', label: 'Quantity' },
    { key: 'production_date', label: 'Production Date' },
    { key: 'quality_check_status', label: 'QC Status' },
    { key: 'quality_score', label: 'Score' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await traceabilityClient.listBatches({ pageSize, pageOffset });
      rows = res.batches;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load batch records';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Batch Records"
  createHref="/batches/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/batches/${id}`)}
  {totalCount}
  {fetchData}
/>
