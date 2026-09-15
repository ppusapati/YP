<script lang="ts">
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { createSoilSampleSchema } from '@samavāya/agriculture/schemas';
  import { soilClient } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const res = await soilClient.getSoilSample({ id });
      values = { ...res.sample };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load soil sample';
    } finally {
      isLoading = false;
    }
  });

  // This page offered Save and Delete for a record that cannot be either.
  //
  // A soil sample is the result of an observation or a computation, and its
  // service declares no Update or Delete — deliberately. Correcting one means
  // submitting another; removing one erases evidence that a later report is
  // built on, and the report still renders, which is what makes it dangerous.
  async function handleSubmit(_formValues: Record<string, unknown>) {
    error = 'A soil sample cannot be edited. Submit a new one instead.';
  }

</script>

<CrudFormPage
  title="Edit Soil Sample"
  subtitle="Update soil sample data"
  mode="edit"
  schema={createSoilSampleSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/farm-management/soil"
  showDelete={false}
  onSubmit={handleSubmit}
/>
