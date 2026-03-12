<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { diagnosisClient } from '@samavāya/agriculture/services';
  import type { DiagnosisRequest } from '@samavāya/agriculture/types';

  let rows: DiagnosisRequest[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'crop_name', label: 'Crop' },
    { key: 'affected_plant_part', label: 'Affected Part' },
    { key: 'severity', label: 'Severity' },
    { key: 'onset_date', label: 'Onset' },
    { key: 'submitted_by', label: 'Submitted By' },
    { key: 'status', label: 'Status' },
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
      error = e instanceof Error ? e.message : 'Failed to load diagnosis requests';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Plant Diagnosis"
  createHref="/diagnosis/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/diagnosis/${id}`)}
  {totalCount}
  {fetchData}
/>
