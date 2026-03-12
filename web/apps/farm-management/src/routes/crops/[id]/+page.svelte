<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { cropFormSchema } from '@samavāya/agriculture/schemas';
  import { cropService } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const crop = await cropService.get(id);
      values = { ...crop };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load crop';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await cropService.update(id, formValues as any);
      goto('/crops');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update crop';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await cropService.remove(id);
      goto('/crops');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete crop';
    }
  }
</script>

<CrudFormPage
  title="Edit Crop"
  subtitle="Update crop details"
  mode="edit"
  schema={cropFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/crops"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
