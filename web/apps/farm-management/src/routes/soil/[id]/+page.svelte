<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { soilSampleFormSchema } from '@samavāya/agriculture/schemas';
  import { soilService } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const sample = await soilService.get(id);
      values = { ...sample };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load soil sample';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await soilService.update(id, formValues as any);
      goto('/soil');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update soil sample';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await soilService.remove(id);
      goto('/soil');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete soil sample';
    }
  }
</script>

<CrudFormPage
  title="Edit Soil Sample"
  subtitle="Update soil sample data"
  mode="edit"
  schema={soilSampleFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/soil"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
