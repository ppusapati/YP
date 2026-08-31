<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { yieldRecordFormSchema } from '@samavāya/agriculture/schemas';
  import { yieldClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = { status: 'draft', yield_unit: 'tonnes', area_unit: 'hectares' };
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await yieldClient.recordYield(formValues as any);
      goto('/yield');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to create yield record';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="New Yield Record"
  subtitle="Record a new harvest yield"
  mode="create"
  schema={yieldRecordFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/yield"
  onSubmit={handleSubmit}
/>
