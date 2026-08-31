<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { detectStressFormSchema } from '@samavāya/agriculture/schemas';
  import { analyticsClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await analyticsClient.detectStress(formValues as any);
      goto('/stress-alerts');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to run stress detection';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Detect Stress"
  subtitle="Run stress detection analysis on satellite imagery"
  mode="create"
  schema={detectStressFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/stress-alerts"
  onSubmit={handleSubmit}
/>
