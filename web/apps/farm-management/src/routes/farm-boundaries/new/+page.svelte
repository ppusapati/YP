<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { farmBoundarySchema } from '@samavāya/agriculture/schemas';
  import { farmClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await farmClient.setFarmBoundary(formValues as any);
      goto('/farm-boundaries');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to set farm boundary';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Set Farm Boundary"
  subtitle="Define the geographic boundary for a farm"
  mode="create"
  schema={farmBoundarySchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/farm-boundaries"
  onSubmit={handleSubmit}
/>
