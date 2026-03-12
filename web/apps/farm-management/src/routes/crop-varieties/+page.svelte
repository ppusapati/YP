<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { cropClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'name', label: 'Variety Name' },
    { key: 'crop_name', label: 'Crop' },
    { key: 'maturity_days', label: 'Maturity (days)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'yield_potential', label: 'Yield Potential (kg/ha)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'is_hybrid', label: 'Hybrid', format: (v: unknown) => v ? 'Yes' : 'No' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await cropClient.listVarieties({ pageSize, pageOffset });
      rows = res.varieties;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load crop varieties';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Crop Varieties"
  createHref="/crop-varieties/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/crop-varieties/${id}`)}
  {fetchData}
/>
