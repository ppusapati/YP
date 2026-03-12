<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { yieldRecordFormSchema } from '@samavāya/agriculture/schemas';
  import { yieldRecordService } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const record = await yieldRecordService.get(id);
      values = { ...record };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load yield record';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await yieldRecordService.update(id, formValues as any);
      goto('/yield');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update yield record';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await yieldRecordService.remove(id);
      goto('/yield');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete yield record';
    }
  }
</script>

<CrudFormPage
  title="Edit Yield Record"
  subtitle="Update yield record"
  mode="edit"
  schema={yieldRecordFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/yield"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
