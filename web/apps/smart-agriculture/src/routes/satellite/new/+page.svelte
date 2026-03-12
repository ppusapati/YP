<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { satelliteImageFormSchema } from '@samavāya/agriculture/schemas';
  import { satelliteService } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = { status: 'processing' };
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await satelliteService.create(formValues as any);
      goto('/satellite');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to create satellite image record';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="New Satellite Image"
  subtitle="Record a new satellite image capture"
  mode="create"
  schema={satelliteImageFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/satellite"
  onSubmit={handleSubmit}
/>
