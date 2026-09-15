<script lang="ts">
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { satelliteImageFormSchema } from '@samavāya/agriculture/schemas';
  import { satelliteClient } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const res = await satelliteClient.getImage({ id });
      values = { ...res.image };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load satellite image';
    } finally {
      isLoading = false;
    }
  });

  // This page offered Save and Delete for a record that cannot be either.
  //
  // A satellite image is the result of an observation or a computation, and its
  // service declares no Update or Delete — deliberately. Correcting one means
  // submitting another; removing one erases evidence that a later report is
  // built on, and the report still renders, which is what makes it dangerous.
  async function handleSubmit(_formValues: Record<string, unknown>) {
    error = 'A satellite image cannot be edited. Submit a new one instead.';
  }

</script>

<CrudFormPage
  title="Edit Satellite Image"
  subtitle="Update satellite image record"
  mode="edit"
  schema={satelliteImageFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/smart-agriculture/satellite"
  showDelete={false}
  onSubmit={handleSubmit}
/>
