<script lang="ts">
  import { CrudFormPage } from '@samavāya/ui';
  import { runTemporalAnalysisFormSchema } from '@samavāya/agriculture/schemas';
  import { analyticsClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {
    analysisType: '1',
  };
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;
  let result: Record<string, unknown> | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    result = null;
    try {
      const res = await analyticsClient.runTemporalAnalysis(formValues as any);
      result = res as any;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to run temporal analysis';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Temporal Analysis"
  subtitle="Run temporal analysis on satellite imagery over a time period"
  mode="create"
  schema={runTemporalAnalysisFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/"
  onSubmit={handleSubmit}
/>

{#if result}
  <div class="result-container">
    <h2>Analysis Result</h2>
    <div class="result-content">
      <pre>{JSON.stringify(result, null, 2)}</pre>
    </div>
  </div>
{/if}

<style>
  .result-container { max-width: 1200px; margin-top: 1.5rem; }
  .result-container h2 { font-size: 1.25rem; font-weight: 600; margin: 0 0 0.75rem 0; }
  .result-content { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.5rem; }
  .result-content pre { font-size: 0.8125rem; color: #374151; white-space: pre-wrap; word-break: break-word; margin: 0; }
</style>
