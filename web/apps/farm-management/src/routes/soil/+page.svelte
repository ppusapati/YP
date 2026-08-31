<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { soilClient } from '@samavāya/agriculture/services';
  import type { SoilSample } from '@samavāya/agriculture/types';

  let rows: SoilSample[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'field_id', label: 'Field' },
    { key: 'collectionDate', label: 'Sample Date' },
    { key: 'ph', label: 'pH' },
    { key: 'nitrogen_ppm', label: 'N (ppm)' },
    { key: 'phosphorus_ppm', label: 'P (ppm)' },
    { key: 'potassium_ppm', label: 'K (ppm)' },
    { key: 'texture_class', label: 'Texture' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await soilClient.listSoilSamples({ pageSize, pageOffset });
      rows = res.samples;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load soil samples';
      rows = [];
      return 0;
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
  {totalCount}
  {fetchData}
/>
