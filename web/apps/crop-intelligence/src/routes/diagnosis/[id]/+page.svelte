<script lang="ts">
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { diagnosisRequestFormSchema } from '@samavāya/agriculture/schemas';
  import { diagnosisClient } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const res = await diagnosisClient.getDiagnosis({ id });
      values = { ...res.diagnosis };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load diagnosis request';
    } finally {
      isLoading = false;
    }
  });

  // This page offered Save and Delete for a record that cannot be either.
  //
  // A diagnosis request is the result of an observation or a computation, and its
  // service declares no Update or Delete — deliberately. Correcting one means
  // submitting another; removing one erases evidence that a later report is
  // built on, and the report still renders, which is what makes it dangerous.
  async function handleSubmit(_formValues: Record<string, unknown>) {
    error = 'A diagnosis request cannot be edited. Submit a new one instead.';
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
  showDelete={false}
  onSubmit={handleSubmit}
/>
