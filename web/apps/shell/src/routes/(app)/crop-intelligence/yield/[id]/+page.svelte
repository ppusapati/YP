<script lang="ts">
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { yieldRecordSchema } from '@samavāya/agriculture/schemas';
  import { yieldClient } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const res = await yieldClient.getPrediction({ id });
      values = { ...res.prediction };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load yield record';
    } finally {
      isLoading = false;
    }
  });

  // This page offered Save and Delete for a record that cannot be either.
  //
  // A yield record is the result of an observation or a computation, and its
  // service declares no Update or Delete — deliberately. Correcting one means
  // submitting another; removing one erases evidence that a later report is
  // built on, and the report still renders, which is what makes it dangerous.
  async function handleSubmit(_formValues: Record<string, unknown>) {
    error = 'A yield record cannot be edited. Submit a new one instead.';
  }

</script>

<CrudFormPage
  title="Edit Yield Record"
  subtitle="Update yield record"
  mode="edit"
  schema={yieldRecordSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/crop-intelligence/yield"
  showDelete={false}
  onSubmit={handleSubmit}
/>
