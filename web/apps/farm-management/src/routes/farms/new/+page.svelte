<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { farmFormSchema } from '@samavāya/agriculture/schemas';
  import { farmClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = { status: 'active', area_unit: 'hectares', country: 'India' };
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await farmClient.createFarm(formValues as any);
      goto('/farms');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to create farm';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="New Farm"
  subtitle="Create a new farm profile"
  mode="create"
  schema={farmFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/farms"
  onSubmit={handleSubmit}
/>
