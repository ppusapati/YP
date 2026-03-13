<script lang="ts">
  import { CrudFormPage } from '@samavāya/ui';
  import { ndviTimeSeriesFormSchema } from '@samavāya/agriculture/schemas';
  import { vegetationIndexClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;
  let timeSeriesData: any[] = [];
  let hasResults = false;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    hasResults = false;
    try {
      const res = await vegetationIndexClient.getNDVITimeSeries(formValues as any);
      timeSeriesData = res.dataPoints || [];
      hasResults = true;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to fetch NDVI time series';
      timeSeriesData = [];
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="NDVI Time Series"
  subtitle="Query NDVI values over time for a specific field"
  mode="create"
  schema={ndviTimeSeriesFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/computed-indices"
  onSubmit={handleSubmit}
/>

{#if hasResults}
  <div class="mt-6 bg-white border border-gray-200 rounded-lg p-6 mx-6">
    <h3 class="text-lg font-semibold mb-4">Time Series Results</h3>
    {#if timeSeriesData.length === 0}
      <p class="text-gray-500">No data points found for the selected date range.</p>
    {:else}
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
              <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">NDVI Mean</th>
              <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">NDVI Min</th>
              <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">NDVI Max</th>
              <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cloud Cover %</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            {#each timeSeriesData as point}
              <tr class="hover:bg-gray-50">
                <td class="px-4 py-3 text-sm text-gray-900">{point.date}</td>
                <td class="px-4 py-3 text-sm text-gray-900">{point.ndviMean?.toFixed(4) ?? '—'}</td>
                <td class="px-4 py-3 text-sm text-gray-900">{point.ndviMin?.toFixed(4) ?? '—'}</td>
                <td class="px-4 py-3 text-sm text-gray-900">{point.ndviMax?.toFixed(4) ?? '—'}</td>
                <td class="px-4 py-3 text-sm text-gray-900">{point.cloudCoverPct ?? '—'}</td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}
  </div>
{/if}
