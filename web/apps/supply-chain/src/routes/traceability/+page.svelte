<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { traceabilityService } from '@samavāya/agriculture/services';
  import type { TraceabilityRecord } from '@samavāya/agriculture/types';

  let rows: TraceabilityRecord[] = [];
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'batch_id', label: 'Batch' },
    { key: 'product_name', label: 'Product' },
    { key: 'product_code', label: 'Code' },
    { key: 'origin_farm_name', label: 'Origin Farm' },
    { key: 'harvest_date', label: 'Harvest Date' },
    { key: 'current_location', label: 'Location' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData() {
    loading = true;
    error = null;
    try {
      const res = await traceabilityService.list({ page: 1, page_size: 50 });
      rows = res.items;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load traceability records';
      rows = [];
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Traceability Records"
  createHref="/traceability/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/traceability/${id}`)}
  {fetchData}
/>
