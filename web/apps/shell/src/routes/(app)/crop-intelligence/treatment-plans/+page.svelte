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

  let pageTokens: string[] = [''];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    const __i = Math.floor(pageOffset / Math.max(pageSize, 1));
    loading = true;
    error = null;
    try {
      // pest-prediction has no ListTreatmentPlans: a plan hangs off a
      // prediction and GetTreatmentPlan takes a prediction_id. So the plans on
      // offer are the plans for this page of predictions, fetched one apiece.
      // N+1 over a page of twenty-five, which is the cost of the service not
      // having a listing — visible here rather than hidden behind a method
      // that does not exist.
      const page = await pestClient.listPredictions({
        pageSize,
        pageToken: pageTokens[__i] ?? '',
      });
      if (page.nextPageToken) pageTokens[__i + 1] = page.nextPageToken;

      const plans = await Promise.all(
        page.predictions.map((p) =>
          pestClient
            .getTreatmentPlan({ predictionId: p.id })
            .then((r) => ({
              id: p.id,
              fieldId: p.fieldId,
              pestSpeciesId: p.pestSpeciesId,
              riskLevel: p.riskLevel,
              treatments: r.treatments.length,
            }))
            // One prediction without a plan must not empty the whole page.
            .catch(() => null),
        ),
      );
      rows = plans.filter((p): p is NonNullable<typeof p> => p !== null);
      totalCount = page.totalCount;
      return page.totalCount;
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
  onRowClick={(id) => goto(`/crop-intelligence/treatment-plans/${id}`)}
  {fetchData}
/>
