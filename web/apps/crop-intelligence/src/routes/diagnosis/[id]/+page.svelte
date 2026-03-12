<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { diagnosisRequestFormSchema } from '@samavāya/agriculture/schemas';
  import { diagnosisService } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const req = await diagnosisService.get(id);
      values = { ...req };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load diagnosis request';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await diagnosisService.update(id, formValues as any);
      goto('/diagnosis');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update diagnosis request';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await diagnosisService.remove(id);
      goto('/diagnosis');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete diagnosis request';
    }
  }
</script>

<CrudFormPage
  title="Diagnosis Request"
  subtitle="View/edit diagnosis details"
  mode="edit"
  schema={diagnosisRequestFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/diagnosis"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
