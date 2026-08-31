<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { pestPredictionFormSchema } from '@samavāya/agriculture/schemas';
  import { pestClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = { status: 'active', risk_level: 'medium' };
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await pestClient.predictPestRisk(formValues as any);
      goto('/pest');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to create prediction';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="New Pest Prediction"
  subtitle="Create a new pest risk prediction"
  mode="create"
  schema={pestPredictionFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/pest"
  onSubmit={handleSubmit}
/>
