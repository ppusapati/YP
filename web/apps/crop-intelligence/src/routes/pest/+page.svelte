<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { pestPredictionService } from '@samavāya/agriculture/services';
  import type { PestPrediction } from '@samavāya/agriculture/types';

  let rows: PestPrediction[] = [];
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'pest_name', label: 'Pest' },
    { key: 'field_id', label: 'Field' },
    { key: 'prediction_date', label: 'Date' },
    { key: 'risk_level', label: 'Risk Level' },
    { key: 'probability', label: 'Probability (%)' },
    { key: 'confidence', label: 'Confidence (%)' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData() {
    loading = true;
    error = null;
    try {
      const res = await pestPredictionService.list({ page: 1, page_size: 50 });
      rows = res.items;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load pest predictions';
      rows = [];
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
  {fetchData}
/>
