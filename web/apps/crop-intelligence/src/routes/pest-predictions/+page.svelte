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
    { key: 'pest_name', label: 'Pest' },
    { key: 'risk_level', label: 'Risk Level' },
    { key: 'probability', label: 'Probability', format: (v: unknown) => v != null ? `${v}%` : '—' },
    { key: 'predicted_date', label: 'Predicted Date' },
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
  createHref="/pest-predictions/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/pest-predictions/${id}`)}
  {fetchData}
/>
