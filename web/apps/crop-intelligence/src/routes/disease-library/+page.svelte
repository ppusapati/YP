<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { diagnosisClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'name', label: 'Disease Name' },
    { key: 'category', label: 'Category' },
    { key: 'affected_crops', label: 'Affected Crops' },
    { key: 'symptoms', label: 'Symptoms' },
    { key: 'severity', label: 'Typical Severity' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await diagnosisClient.listDiseases({ pageSize, pageOffset });
      rows = res.diseases;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load disease library';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Disease Library"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/disease-library/${id}`)}
  {fetchData}
/>
