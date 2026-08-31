<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { cropClient } from '@samavāya/agriculture/services';
  import type { Crop } from '@samavāya/agriculture/types';

  let rows: Crop[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'name', label: 'Crop Name' },
    { key: 'scientificName', label: 'Scientific Name' },
    { key: 'code', label: 'Code' },
    { key: 'category', label: 'Category' },
    { key: 'crop_type', label: 'Type' },
    { key: 'season', label: 'Season' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await cropClient.listCrops({ pageSize, pageOffset });
      rows = res.crops;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load crops';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Crops"
  createHref="/crops/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/crops/${id}`)}
  {totalCount}
  {fetchData}
/>
