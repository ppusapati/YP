<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { yieldClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'field_name', label: 'Field' },
    { key: 'crop_name', label: 'Crop' },
    { key: 'harvest_date', label: 'Harvest Date' },
    { key: 'yield_amount', label: 'Yield', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'unit', label: 'Unit' },
    { key: 'quality_grade', label: 'Quality Grade' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await yieldClient.listYieldRecords({ pageSize, pageOffset });
      rows = res.records;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load historical yields';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Historical Yields"
  createHref="/historical-yields/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/historical-yields/${id}`)}
  {fetchData}
/>
