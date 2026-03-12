<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { diagnosisRequestFormSchema } from '@samavāya/agriculture/schemas';
  import { diagnosisClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await diagnosisClient.submitDiagnosis(formValues as any);
      goto('/diagnosis-history');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to submit diagnosis request';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Plant Diagnosis"
  subtitle="Submit a plant diagnosis request"
  mode="create"
  schema={diagnosisRequestFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/diagnosis-history"
  onSubmit={handleSubmit}
/>
