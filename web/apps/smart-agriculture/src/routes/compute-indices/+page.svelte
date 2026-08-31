<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { computeIndicesFormSchema } from '@samavāya/agriculture/schemas';
  import { vegetationIndexClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await vegetationIndexClient.computeIndices(formValues as any);
      goto('/computed-indices');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to compute vegetation indices';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Compute Vegetation Indices"
  subtitle="Submit a vegetation index computation job"
  mode="create"
  schema={computeIndicesFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/computed-indices"
  onSubmit={handleSubmit}
/>
