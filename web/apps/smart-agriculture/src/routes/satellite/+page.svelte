<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { satelliteClient } from '@samavāya/agriculture/services';
  import type { SatelliteImage } from '@samavāya/agriculture/types';

  let rows: SatelliteImage[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'field_id', label: 'Field' },
    { key: 'acquisitionDate', label: 'Capture Date' },
    { key: 'satelliteProvider', label: 'Satellite' },
    { key: 'processingStatus', label: 'Type' },
    { key: 'cloudCoverPct', label: 'Cloud %' },
    { key: 'ndvi_mean', label: 'NDVI' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await satelliteClient.listImages({ pageSize, pageOffset });
      rows = res.images;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load satellite images';
      rows = [];
      return 0;
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
  {totalCount}
  {fetchData}
/>
