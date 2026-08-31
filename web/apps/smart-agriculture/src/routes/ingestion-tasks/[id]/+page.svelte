<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { requestIngestionFormSchema } from '@samavāya/agriculture/schemas';
  import { ingestionClient } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const res = await ingestionClient.getIngestionTask({ id });
      values = { ...res.task };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load ingestion task';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await ingestionClient.updateIngestionTask({ id, ...formValues } as any);
      goto('/ingestion-tasks');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update ingestion task';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await ingestionClient.cancelIngestion({ id });
      goto('/ingestion-tasks');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to cancel ingestion task';
    }
  }
</script>

<CrudFormPage
  title="Edit Ingestion Task"
  subtitle="Update ingestion task details"
  mode="edit"
  schema={requestIngestionFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/ingestion-tasks"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
