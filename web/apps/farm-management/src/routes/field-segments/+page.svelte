<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { fieldClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'name', label: 'Segment Name' },
    { key: 'field_name', label: 'Field' },
    { key: 'area_hectares', label: 'Area (ha)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'soil_type', label: 'Soil Type' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await fieldClient.listFieldSegments({ pageSize, pageOffset });
      rows = res.segments;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load field segments';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Field Segments"
  createHref="/field-segments/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/field-segments/${id}`)}
  {fetchData}
/>
