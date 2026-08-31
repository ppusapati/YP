<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { submitProcessingJobFormSchema } from '@samavāya/agriculture/schemas';
  import { processingClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;
  let loading = true;

  $: id = $page.params.id;

  $: if (id) loadData(id);

  async function loadData(jobId: string) {
    loading = true;
    try {
      const res = await processingClient.getProcessingJob({ id: jobId });
      values = res.job as any || {};
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load processing job';
    } finally {
      loading = false;
    }
  }

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await processingClient.submitProcessingJob({ ...formValues, id } as any);
      goto('/processing-jobs');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update processing job';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Processing Job Details"
  subtitle="View and edit processing job configuration"
  mode="edit"
  schema={submitProcessingJobFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/processing-jobs"
  onSubmit={handleSubmit}
/>
