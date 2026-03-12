<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { pestPredictionFormSchema } from '@samavāya/agriculture/schemas';
  import { pestClient } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const res = await pestClient.getPrediction({ id });
      values = { ...res.prediction };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load prediction';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await pestClient.updatePrediction({ id, ...formValues } as any);
      goto('/pest');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update prediction';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await pestClient.deletePrediction({ id } as any);
      goto('/pest');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete prediction';
    }
  }
</script>

<CrudFormPage
  title="Edit Pest Prediction"
  subtitle="Update pest prediction"
  mode="edit"
  schema={pestPredictionFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/pest"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
