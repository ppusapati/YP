<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { submitProcessingJobFormSchema } from '@samavāya/agriculture/schemas';
  import { processingClient } from '@samavāya/agriculture/services';
  import { numberValue, stringValue } from '@samavāya/agriculture/convert';

  /**
   * A processing job's settings.
   *
   * satellite-processing-service has no update operation — Submit, Get, List,
   * Cancel and Stats are the whole surface, and `SubmitProcessingJobRequest`
   * has no id field. This page called Submit with an `id` and navigated away,
   * so pressing Save created a *second* job with the same settings and left the
   * first one exactly as it was. The id went nowhere; protobuf dropped it.
   *
   * A job is a unit of work that has already run or is running, so editing one
   * in place is not a thing that can mean anything. What a person actually
   * wants here is to run it again with a tweak, so that is what the button
   * says, and the subtitle says the original is left alone.
   */

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;
  let isLoading = true;
  let status = '';

  $: id = $page.params.id;
  $: if (id) void loadData(id);

  async function loadData(jobId: string) {
    isLoading = true;
    try {
      const res = await processingClient.getProcessingJob({ id: jobId });
      const job = res.job;
      if (job) {
        // This form's field names are already the client's camelCase ones, so
        // these line up directly — unlike the snake_case schemas elsewhere.
        values = {
          ingestionTaskId: job.ingestionTaskId,
          farmId: job.farmId,
          outputLevel: String(job.outputLevel),
          algorithm: String(job.algorithm),
          cloudMaskThreshold: job.cloudMaskThreshold,
          applyAtmosphericCorrection: job.applyAtmosphericCorrection,
          applyCloudMasking: job.applyCloudMasking,
          applyOrthorectification: job.applyOrthorectification,
          outputResolutionMeters: job.outputResolutionMeters,
          outputCrs: job.outputCrs,
        };
        status = job.status ? String(job.status) : '';
      }
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load processing job';
    } finally {
      isLoading = false;
    }
  }

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      // No id: this creates a new job, which is the only thing the service
      // offers. Sending one would be dropped anyway — the request has no such
      // field — and would make this read like an edit.
      const res = await processingClient.submitProcessingJob({
        ingestionTaskId: stringValue(formValues.ingestionTaskId),
        farmId: stringValue(formValues.farmId),
        outputLevel: numberValue(formValues.outputLevel),
        algorithm: numberValue(formValues.algorithm),
        cloudMaskThreshold: numberValue(formValues.cloudMaskThreshold) ?? 0,
        applyAtmosphericCorrection: formValues.applyAtmosphericCorrection === true,
        applyCloudMasking: formValues.applyCloudMasking === true,
        applyOrthorectification: formValues.applyOrthorectification === true,
        outputResolutionMeters: numberValue(formValues.outputResolutionMeters) ?? 0,
        outputCrs: stringValue(formValues.outputCrs),
      });
      // Straight to the new job rather than back to the list, so it is obvious
      // that a different job now exists.
      const newId = res.job?.id;
      goto(newId ? `/processing-jobs/${newId}` : '/processing-jobs');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to submit processing job';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Processing Job"
  subtitle={status
    ? `Status ${status}. This service has no edit operation — submitting runs a new job and leaves this one unchanged.`
    : 'This service has no edit operation — submitting runs a new job and leaves this one unchanged.'}
  mode="edit"
  submitLabel="Run as a new job"
  schema={submitProcessingJobFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/processing-jobs"
  onSubmit={handleSubmit}
/>
