<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { farmBoundarySchema } from '@samavāya/agriculture/schemas';
  import { fieldClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await fieldClient.setFieldBoundary(formValues as any);
      goto('/field-boundaries');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to set field boundary';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Set Field Boundary"
  subtitle="Define the geographic boundary for a field"
  mode="create"
  schema={farmBoundarySchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/field-boundaries"
  onSubmit={handleSubmit}
/>
