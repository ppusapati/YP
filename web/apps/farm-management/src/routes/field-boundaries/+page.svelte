<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { fieldClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'name', label: 'Field Name' },
    { key: 'area_hectares', label: 'Area (ha)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'perimeter_meters', label: 'Perimeter (m)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'boundary_type', label: 'Boundary Type' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await fieldClient.listFields({ pageSize, pageOffset });
      rows = res.fields;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load field boundaries';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Field Boundaries"
  createHref="/field-boundaries/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/field-boundaries/${id}`)}
  {fetchData}
/>
