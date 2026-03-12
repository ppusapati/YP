<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { yieldClient } from '@samavāya/agriculture/services';
  import type { YieldRecord } from '@samavāya/agriculture/types';

  let rows: YieldRecord[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'crop_name', label: 'Crop' },
    { key: 'field_id', label: 'Field' },
    { key: 'harvestDate', label: 'Harvest Date' },
    { key: 'actual_yield', label: 'Yield' },
    { key: 'yield_unit', label: 'Unit' },
    { key: 'quality_grade', label: 'Grade' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await yieldClient.getYieldHistory({ pageSize, pageOffset });
      rows = res.records;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load yield records';
      rows = [];
      return 0;
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
  {totalCount}
  {fetchData}
/>
