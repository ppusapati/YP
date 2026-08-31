<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { traceabilityRecordFormSchema } from '@samavāya/agriculture/schemas';
  import { traceabilityClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = { status: 'created', unit: 'kg' };
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await traceabilityClient.createRecord(formValues as any);
      goto('/traceability');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to create traceability record';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="New Traceability Record"
  subtitle="Create a new product traceability record"
  mode="create"
  schema={traceabilityRecordFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/traceability"
  onSubmit={handleSubmit}
/>
