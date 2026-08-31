<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { submitProcessingJobFormSchema } from '@samavāya/agriculture/schemas';
  import { processingClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {
    outputCrs: 'EPSG:4326',
    cloudMaskThreshold: 0.3,
    applyAtmosphericCorrection: true,
    applyCloudMasking: true,
  };
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await processingClient.submitProcessingJob(formValues as any);
      goto('/processing-jobs');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to submit processing job';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Submit Processing Job"
  subtitle="Process ingested satellite imagery"
  mode="create"
  schema={submitProcessingJobFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/processing-jobs"
  onSubmit={handleSubmit}
/>
