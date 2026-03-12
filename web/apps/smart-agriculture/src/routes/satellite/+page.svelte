<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { satelliteService } from '@samavāya/agriculture/services';
  import type { SatelliteImage } from '@samavāya/agriculture/types';

  let rows: SatelliteImage[] = [];
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'field_id', label: 'Field' },
    { key: 'capture_date', label: 'Capture Date' },
    { key: 'satellite_name', label: 'Satellite' },
    { key: 'image_type', label: 'Type' },
    { key: 'cloud_cover_pct', label: 'Cloud %' },
    { key: 'ndvi_mean', label: 'NDVI' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData() {
    loading = true;
    error = null;
    try {
      const res = await satelliteService.list({ page: 1, page_size: 50 });
      rows = res.items;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load satellite images';
      rows = [];
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Satellite Imagery"
  createHref="/satellite/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/satellite/${id}`)}
  {fetchData}
/>
