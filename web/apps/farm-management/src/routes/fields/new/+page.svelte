<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { fieldFormSchema } from '@samavāya/agriculture/schemas';
  import { fieldClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = { status: 'active', area_unit: 'hectares' };
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await fieldClient.createField(formValues as any);
      goto('/fields');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to create field';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="New Field"
  subtitle="Register a new field"
  mode="create"
  schema={fieldFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/fields"
  onSubmit={handleSubmit}
/>
