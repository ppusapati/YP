<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { vegetationIndexClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'farmId', label: 'Farm' },
    { key: 'fieldId', label: 'Field' },
    { key: 'indexType', label: 'Index' },
    { key: 'meanValue', label: 'Mean' },
    { key: 'minValue', label: 'Min' },
    { key: 'maxValue', label: 'Max' },
    { key: 'stdDeviation', label: 'Std Dev' },
    { key: 'acquisitionDate', label: 'Date' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await vegetationIndexClient.listVegetationIndices({ pageSize, pageOffset });
      rows = res.indices;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load vegetation indices';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Computed Indices"
  createHref="/compute-indices"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/computed-indices/${id}`)}
  {totalCount}
  {fetchData}
/>
