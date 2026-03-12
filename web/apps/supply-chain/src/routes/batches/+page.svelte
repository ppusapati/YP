<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { batchRecordService } from '@samavāya/agriculture/services';
  import type { BatchRecord } from '@samavāya/agriculture/types';

  let rows: BatchRecord[] = [];
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'batch_number', label: 'Batch #' },
    { key: 'product_name', label: 'Product' },
    { key: 'quantity', label: 'Quantity' },
    { key: 'production_date', label: 'Production Date' },
    { key: 'quality_check_status', label: 'QC Status' },
    { key: 'quality_score', label: 'Score' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData() {
    loading = true;
    error = null;
    try {
      const res = await batchRecordService.list({ page: 1, page_size: 50 });
      rows = res.items;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load batch records';
      rows = [];
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
  {fetchData}
/>
