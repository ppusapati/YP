<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { farmFormSchema } from '@samavāya/agriculture/schemas';
  import { farmClient } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;
  let mode: 'edit' | 'view' = 'edit';

  onMount(async () => {
    try {
      const res = await farmClient.getFarm({ id });
      values = { ...res.farm };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load farm';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await farmClient.updateFarm({ id, ...formValues } as any);
      goto('/farms');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update farm';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await farmClient.deleteFarm({ id });
      goto('/farms');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete farm';
    }
  }
</script>

<CrudFormPage
  title="Edit Farm"
  subtitle="Update farm details"
  {mode}
  schema={farmFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/farms"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
