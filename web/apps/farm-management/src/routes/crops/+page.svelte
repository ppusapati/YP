<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { cropService } from '@samavāya/agriculture/services';
  import type { Crop } from '@samavāya/agriculture/types';

  let rows: Crop[] = [];
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'name', label: 'Crop Name' },
    { key: 'scientific_name', label: 'Scientific Name' },
    { key: 'code', label: 'Code' },
    { key: 'category', label: 'Category' },
    { key: 'crop_type', label: 'Type' },
    { key: 'season', label: 'Season' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData() {
    loading = true;
    error = null;
    try {
      const res = await cropService.list({ page: 1, page_size: 50 });
      rows = res.items;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load crops';
      rows = [];
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
  {fetchData}
/>
