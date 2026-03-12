<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { assignCropSchema } from '@samavāya/agriculture/schemas';
  import { fieldClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await fieldClient.assignCrop(formValues as any);
      goto('/crop-assignment');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to assign crop';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Assign Crop"
  subtitle="Assign a crop to a field"
  mode="create"
  schema={assignCropSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/crop-assignment"
  onSubmit={handleSubmit}
/>
