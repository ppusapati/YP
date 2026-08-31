<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { yieldRecordSchema } from '@samavāya/agriculture/schemas';
  import { yieldClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await yieldClient.recordYield(formValues as any);
      goto('/historical-yields');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to record yield';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Record Yield"
  subtitle="Record a historical yield measurement"
  mode="create"
  schema={yieldRecordSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/historical-yields"
  onSubmit={handleSubmit}
/>
