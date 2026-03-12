<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { satelliteImageFormSchema } from '@samavāya/agriculture/schemas';
  import { satelliteService } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const image = await satelliteService.get(id);
      values = { ...image };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load satellite image';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await satelliteService.update(id, formValues as any);
      goto('/satellite');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update satellite image';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await satelliteService.remove(id);
      goto('/satellite');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete satellite image';
    }
  }
</script>

<CrudFormPage
  title="Edit Satellite Image"
  subtitle="Update satellite image record"
  mode="edit"
  schema={satelliteImageFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/satellite"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
