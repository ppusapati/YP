<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { fieldClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'field_name', label: 'Field' },
    { key: 'crop_name', label: 'Crop' },
    { key: 'variety', label: 'Variety' },
    { key: 'season', label: 'Season' },
    { key: 'planting_date', label: 'Planting Date' },
    { key: 'harvest_date', label: 'Harvest Date' },
    { key: 'yield_amount', label: 'Yield', format: (v: unknown) => v != null ? `${v}` : '—' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await fieldClient.getCropHistory({ pageSize, pageOffset });
      rows = res.history;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load crop history';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Crop History"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/crop-history/${id}`)}
  {fetchData}
/>
