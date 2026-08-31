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
    { key: 'nitrogen_ppm', label: 'Nitrogen (ppm)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'phosphorus_ppm', label: 'Phosphorus (ppm)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'potassium_ppm', label: 'Potassium (ppm)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'calcium_ppm', label: 'Calcium (ppm)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'magnesium_ppm', label: 'Magnesium (ppm)', format: (v: unknown) => v != null ? `${v}` : '—' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await soilClient.getNutrientLevels({ pageSize, pageOffset });
      rows = res.levels;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load nutrient levels';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Nutrient Levels"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/nutrient-levels/${id}`)}
  {fetchData}
/>
