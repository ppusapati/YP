<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { fieldFormSchema } from '@samavāya/agriculture/schemas';
  import { fieldClient } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const res = await fieldClient.getField({ id });
      values = { ...res.field };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load field';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await fieldClient.updateField({ id, ...formValues } as any);
      goto('/fields');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update field';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await fieldClient.deleteField({ id });
      goto('/fields');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete field';
    }
  }
</script>

<CrudFormPage
  title="Edit Field"
  subtitle="Update field details"
  mode="edit"
  schema={fieldFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/fields"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
