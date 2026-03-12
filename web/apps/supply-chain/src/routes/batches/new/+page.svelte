<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { batchRecordFormSchema } from '@samavāya/agriculture/schemas';
  import { batchRecordService } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = { status: 'active', unit: 'kg', quality_check_status: 'pending' };
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await batchRecordService.create(formValues as any);
      goto('/batches');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to create batch record';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="New Batch Record"
  subtitle="Register a new production batch"
  mode="create"
  schema={batchRecordFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/batches"
  onSubmit={handleSubmit}
/>
