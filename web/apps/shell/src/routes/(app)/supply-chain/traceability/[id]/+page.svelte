<script lang="ts">
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { traceabilityRecordSchema } from '@samavāya/agriculture/schemas';
  import { traceabilityClient } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const res = await traceabilityClient.getRecord({ id });
      values = { ...res.record };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load traceability record';
    } finally {
      isLoading = false;
    }
  });

  // UpdateRecord is declared in traceability.proto and missing from the
  // generated TypeScript client, which is stale — the proto has twenty-one
  // RPCs and the client fourteen. DeleteRecord does not exist at all, and
  // should not: a traceability record is the chain of custody for a batch and
  // removing one erases provenance rather than correcting it.
  //
  // So this page loads and shows the record, and saving says why it cannot.
  // See docs/proto-generation.md.
  async function handleSubmit(_formValues: Record<string, unknown>) {
    error =
      'Saving is unavailable: this app\'s generated client is missing ' +
      'UpdateRecord. Regenerate it to enable editing.';
  }
</script>

<CrudFormPage
  title="Edit Traceability Record"
  subtitle="Update traceability details"
  mode="edit"
  schema={traceabilityRecordSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/traceability"
  showDelete={false}
  onSubmit={handleSubmit}
/>
