<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { pestClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'prediction_id', label: 'Prediction ID' },
    { key: 'treatment_type', label: 'Treatment Type' },
    { key: 'product_name', label: 'Product' },
    { key: 'dosage', label: 'Dosage' },
    { key: 'application_method', label: 'Method' },
    { key: 'application_date', label: 'Application Date' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await pestClient.listTreatmentPlans({ pageSize, pageOffset });
      rows = res.plans;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load treatment plans';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Treatment Plans"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/treatment-plans/${id}`)}
  {fetchData}
/>
