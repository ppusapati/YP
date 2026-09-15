<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { pestClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'field_name', label: 'Field' },
    { key: 'crop_name', label: 'Crop' },
    { key: 'overall_risk', label: 'Overall Risk' },
    { key: 'pest_risk', label: 'Pest Risk' },
    { key: 'disease_risk', label: 'Disease Risk' },
    { key: 'assessment_date', label: 'Assessment Date' },
  ];

  // A risk assessment is what PredictPestRisk produces — a prediction — and ListPredictions is how they are listed.
  // Token-paginated, like the RPC it now calls.
  let pageTokens: string[] = [''];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    const __i = Math.floor(pageOffset / Math.max(pageSize, 1));
    loading = true;
    error = null;
    try {
      const res = await pestClient.listPredictions({ pageSize, pageToken: pageTokens[__i] ?? '' });
      rows = res.predictions;
      if (res.nextPageToken) pageTokens[__i + 1] = res.nextPageToken;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load risk assessments';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Risk Assessments"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/risk-assessments/${id}`)}
  {fetchData}
/>
