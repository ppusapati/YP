<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { farmClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'farm_name', label: 'Farm Name' },
    { key: 'area_hectares', label: 'Area (ha)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'perimeter_meters', label: 'Perimeter (m)', format: (v: unknown) => v != null ? `${v}` : '—' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await farmClient.listFarms({ pageSize, pageOffset });
      rows = res.farms;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load farm boundaries';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Farm Boundaries"
  createHref="/farm-boundaries/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/farm-boundaries/${id}`)}
  {fetchData}
/>
