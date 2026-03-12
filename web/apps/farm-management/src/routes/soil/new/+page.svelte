<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { soilSampleFormSchema } from '@samavāya/agriculture/schemas';
  import { soilClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = { status: 'pending' };
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await soilClient.createSoilSample(formValues as any);
      goto('/soil');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to create soil sample';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="New Soil Sample"
  subtitle="Record a new soil sample and analysis"
  mode="create"
  schema={soilSampleFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/soil"
  onSubmit={handleSubmit}
/>
