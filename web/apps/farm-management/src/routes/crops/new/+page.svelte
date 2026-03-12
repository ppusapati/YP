<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { cropFormSchema } from '@samavāya/agriculture/schemas';
  import { cropService } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = { status: 'active' };
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await cropService.create(formValues as any);
      goto('/crops');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to create crop';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="New Crop"
  subtitle="Add a new crop to the catalog"
  mode="create"
  schema={cropFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/crops"
  onSubmit={handleSubmit}
/>
