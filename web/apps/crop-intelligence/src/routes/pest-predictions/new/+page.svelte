<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { pestPredictionRequestSchema } from '@samavāya/agriculture/schemas';
  import { pestClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await pestClient.predictPestRisk(formValues as any);
      goto('/pest-predictions');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to request pest prediction';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Request Pest Prediction"
  subtitle="Submit conditions for pest risk analysis"
  mode="create"
  schema={pestPredictionRequestSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/pest-predictions"
  onSubmit={handleSubmit}
/>
