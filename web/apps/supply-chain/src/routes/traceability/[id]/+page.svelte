<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { traceabilityRecordFormSchema } from '@samavāya/agriculture/schemas';
  import { traceabilityService } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const record = await traceabilityService.get(id);
      values = { ...record };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load traceability record';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await traceabilityService.update(id, formValues as any);
      goto('/traceability');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update traceability record';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await traceabilityService.remove(id);
      goto('/traceability');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete traceability record';
    }
  }
</script>

<CrudFormPage
  title="Edit Traceability Record"
  subtitle="Update traceability details"
  mode="edit"
  schema={traceabilityRecordFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/traceability"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
