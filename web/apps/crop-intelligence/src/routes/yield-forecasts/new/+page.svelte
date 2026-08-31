<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { yieldForecastRequestSchema } from '@samavāya/agriculture/schemas';
  import { yieldClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await yieldClient.predictYield(formValues as any);
      goto('/yield-forecasts');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to request yield forecast';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Request Yield Forecast"
  subtitle="Request an AI-powered yield prediction"
  mode="create"
  schema={yieldForecastRequestSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/yield-forecasts"
  onSubmit={handleSubmit}
/>
