<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { fieldService } from '@samavāya/agriculture/services';
  import type { Field } from '@samavāya/agriculture/types';

  let rows: Field[] = [];
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'name', label: 'Field Name' },
    { key: 'code', label: 'Code' },
    { key: 'area', label: 'Area' },
    { key: 'soil_type', label: 'Soil Type' },
    { key: 'irrigation_type', label: 'Irrigation' },
    { key: 'current_crop_name', label: 'Current Crop' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData() {
    loading = true;
    error = null;
    try {
      const res = await fieldService.list({ page: 1, page_size: 50 });
      rows = res.items;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load fields';
      rows = [];
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Fields"
  createHref="/fields/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/fields/${id}`)}
  {fetchData}
/>
