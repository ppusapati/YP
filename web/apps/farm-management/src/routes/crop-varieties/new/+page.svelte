<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { cropVarietySchema } from '@samavāya/agriculture/schemas';
  import { cropClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await cropClient.addVariety(formValues as any);
      goto('/crop-varieties');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to add crop variety';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Add Crop Variety"
  subtitle="Add a new variety for a crop"
  mode="create"
  schema={cropVarietySchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/crop-varieties"
  onSubmit={handleSubmit}
/>
