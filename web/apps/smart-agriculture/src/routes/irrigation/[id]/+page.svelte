<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { irrigationScheduleFormSchema } from '@samavāya/agriculture/schemas';
  import { irrigationScheduleService } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const schedule = await irrigationScheduleService.get(id);
      values = { ...schedule };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load irrigation schedule';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await irrigationScheduleService.update(id, formValues as any);
      goto('/irrigation');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update irrigation schedule';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await irrigationScheduleService.remove(id);
      goto('/irrigation');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete irrigation schedule';
    }
  }
</script>

<CrudFormPage
  title="Edit Irrigation Schedule"
  subtitle="Update irrigation schedule"
  mode="edit"
  schema={irrigationScheduleFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/irrigation"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
