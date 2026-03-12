<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { farmClient } from '@samavāya/agriculture/services';
  import type { Farm } from '@samavāya/agriculture/types';

  let rows: Farm[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'name', label: 'Farm Name' },
    { key: 'farmType', label: 'Type' },
    { key: 'totalAreaHectares', label: 'Area (ha)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'region', label: 'Region' },
    { key: 'country', label: 'Country' },
    { key: 'status', label: 'Status' },
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
      error = e instanceof Error ? e.message : 'Failed to load farms';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Farms"
  createHref="/farms/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/farms/${id}`)}
  {fetchData}
/>
