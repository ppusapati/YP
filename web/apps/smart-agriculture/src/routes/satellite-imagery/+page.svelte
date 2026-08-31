<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { satelliteClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'field_name', label: 'Field' },
    { key: 'satellite_provider', label: 'Provider' },
    { key: 'capture_date', label: 'Capture Date' },
    { key: 'cloud_cover_pct', label: 'Cloud Cover %', format: (v: unknown) => v != null ? `${v}%` : '—' },
    { key: 'resolution_meters', label: 'Resolution (m)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await satelliteClient.listSatelliteImages({ pageSize, pageOffset });
      rows = res.images;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load satellite imagery';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Satellite Imagery"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/satellite-imagery/${id}`)}
  {fetchData}
/>
