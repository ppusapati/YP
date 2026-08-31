<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { cropClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'crop_name', label: 'Crop' },
    { key: 'optimal_temp_min', label: 'Min Temp (C)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'optimal_temp_max', label: 'Max Temp (C)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'soil_ph_min', label: 'pH Min', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'soil_ph_max', label: 'pH Max', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'water_requirement_mm', label: 'Water (mm)', format: (v: unknown) => v != null ? `${v}` : '—' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await cropClient.getCropRequirements({ pageSize, pageOffset });
      rows = res.requirements;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load crop requirements';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Crop Requirements"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/crop-requirements/${id}`)}
  {fetchData}
/>
