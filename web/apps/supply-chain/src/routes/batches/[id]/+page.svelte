<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { batchRecordFormSchema } from '@samavāya/agriculture/schemas';
  import { traceabilityClient } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const res = await traceabilityClient.getBatch({ id });
      values = { ...res.batch };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load batch record';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await traceabilityClient.updateBatch({ id, ...formValues } as any);
      goto('/batches');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update batch record';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await traceabilityClient.deleteBatch({ id } as any);
      goto('/batches');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete batch record';
    }
  }
</script>

<CrudFormPage
  title="Edit Batch Record"
  subtitle="Update batch record"
  mode="edit"
  schema={batchRecordFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/batches"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
