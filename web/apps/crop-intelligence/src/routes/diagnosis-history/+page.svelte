<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { diagnosisClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'field_name', label: 'Field' },
    { key: 'plant_species', label: 'Plant Species' },
    { key: 'diagnosis', label: 'Diagnosis' },
    { key: 'confidence', label: 'Confidence', format: (v: unknown) => v != null ? `${v}%` : '—' },
    { key: 'severity', label: 'Severity' },
    { key: 'submitted_at', label: 'Submitted At' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await diagnosisClient.listDiagnoses({ pageSize, pageOffset });
      rows = res.diagnoses;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load diagnosis history';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Diagnosis History"
  createHref="/diagnose"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/diagnosis-history/${id}`)}
  {fetchData}
/>
