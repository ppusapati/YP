<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { soilService } from '@samavāya/agriculture/services';
  import type { SoilSample } from '@samavāya/agriculture/types';

  let rows: SoilSample[] = [];
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'field_id', label: 'Field' },
    { key: 'sample_date', label: 'Sample Date' },
    { key: 'ph', label: 'pH' },
    { key: 'nitrogen_ppm', label: 'N (ppm)' },
    { key: 'phosphorus_ppm', label: 'P (ppm)' },
    { key: 'potassium_ppm', label: 'K (ppm)' },
    { key: 'texture_class', label: 'Texture' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData() {
    loading = true;
    error = null;
    try {
      const res = await soilService.list({ page: 1, page_size: 50 });
      rows = res.items;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load soil samples';
      rows = [];
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Soil Samples"
  createHref="/soil/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/soil/${id}`)}
  {fetchData}
/>
