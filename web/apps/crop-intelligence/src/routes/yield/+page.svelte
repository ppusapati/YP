<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { yieldRecordService } from '@samavāya/agriculture/services';
  import type { YieldRecord } from '@samavāya/agriculture/types';

  let rows: YieldRecord[] = [];
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'crop_name', label: 'Crop' },
    { key: 'field_id', label: 'Field' },
    { key: 'harvest_date', label: 'Harvest Date' },
    { key: 'actual_yield', label: 'Yield' },
    { key: 'yield_unit', label: 'Unit' },
    { key: 'quality_grade', label: 'Grade' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData() {
    loading = true;
    error = null;
    try {
      const res = await yieldRecordService.list({ page: 1, page_size: 50 });
      rows = res.items;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load yield records';
      rows = [];
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Yield Records"
  createHref="/yield/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/yield/${id}`)}
  {fetchData}
/>
