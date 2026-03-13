<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { requestIngestionFormSchema } from '@samavāya/agriculture/schemas';
  import { ingestionClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = { provider: '1', maxCloudCover: 20 };
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await ingestionClient.requestIngestion(formValues as any);
      goto('/ingestion-tasks');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to request ingestion';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Request Satellite Ingestion"
  subtitle="Download and ingest satellite imagery"
  mode="create"
  schema={requestIngestionFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/ingestion-tasks"
  onSubmit={handleSubmit}
/>
