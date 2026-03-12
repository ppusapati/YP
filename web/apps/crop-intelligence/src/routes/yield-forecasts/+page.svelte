<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { yieldClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'field_name', label: 'Field' },
    { key: 'crop_name', label: 'Crop' },
    { key: 'season', label: 'Season' },
    { key: 'predicted_yield', label: 'Predicted Yield', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'confidence_interval', label: 'Confidence' },
    { key: 'forecast_date', label: 'Forecast Date' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await yieldClient.listYieldForecasts({ pageSize, pageOffset });
      rows = res.forecasts;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load yield forecasts';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Yield Forecasts"
  createHref="/yield-forecasts/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/yield-forecasts/${id}`)}
  {fetchData}
/>
