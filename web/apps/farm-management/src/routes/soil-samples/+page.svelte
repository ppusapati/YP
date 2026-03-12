<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { soilClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'field_name', label: 'Field' },
    { key: 'sample_location', label: 'Location' },
    { key: 'depth_cm', label: 'Depth (cm)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'collection_date', label: 'Collection Date' },
    { key: 'ph', label: 'pH', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'organic_matter_pct', label: 'Organic Matter %', format: (v: unknown) => v != null ? `${v}%` : '—' },
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
  createHref="/soil-samples/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/soil-samples/${id}`)}
  {fetchData}
/>
