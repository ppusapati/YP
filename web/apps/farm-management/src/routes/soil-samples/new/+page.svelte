<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { createSoilSampleSchema } from '@samavāya/agriculture/schemas';
  import { soilClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await soilClient.createSoilSample(formValues as any);
      goto('/soil-samples');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to create soil sample';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="New Soil Sample"
  subtitle="Record a new soil sample"
  mode="create"
  schema={createSoilSampleSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/soil-samples"
  onSubmit={handleSubmit}
/>
