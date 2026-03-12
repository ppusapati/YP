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
    { key: 'overall_score', label: 'Overall Score', format: (v: unknown) => v != null ? `${v}/100` : '—' },
    { key: 'organic_matter_score', label: 'Organic Matter', format: (v: unknown) => v != null ? `${v}/100` : '—' },
    { key: 'nutrient_score', label: 'Nutrient Score', format: (v: unknown) => v != null ? `${v}/100` : '—' },
    { key: 'ph_score', label: 'pH Score', format: (v: unknown) => v != null ? `${v}/100` : '—' },
    { key: 'last_assessed', label: 'Last Assessed' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await soilClient.getSoilHealthScores({ pageSize, pageOffset });
      rows = res.scores;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load soil health scores';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Soil Health Scores"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/soil-health/${id}`)}
  {fetchData}
/>
