<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { certificationFormSchema } from '@samavāya/agriculture/schemas';
  import { certificationService } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const cert = await certificationService.get(id);
      values = { ...cert };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load certification';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await certificationService.update(id, formValues as any);
      goto('/certifications');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update certification';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await certificationService.remove(id);
      goto('/certifications');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete certification';
    }
  }
</script>

<CrudFormPage
  title="Edit Certification"
  subtitle="Update certification details"
  mode="edit"
  schema={certificationFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/certifications"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
