<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { pestClient } from '@samavāya/agriculture/services';
  import type { PestPrediction } from '@samavāya/agriculture/types';

  let rows: PestPrediction[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'pestSpeciesId', label: 'Pest' },
    { key: 'field_id', label: 'Field' },
    { key: 'predictionDate', label: 'Date' },
    { key: 'riskLevel', label: 'Risk Level' },
    { key: 'probability', label: 'Probability (%)' },
    { key: 'confidence', label: 'Confidence (%)' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await pestClient.listPredictions({ pageSize, pageOffset });
      rows = res.predictions;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load pest predictions';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Pest Predictions"
  createHref="/pest/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/pest/${id}`)}
  {totalCount}
  {fetchData}
/>
