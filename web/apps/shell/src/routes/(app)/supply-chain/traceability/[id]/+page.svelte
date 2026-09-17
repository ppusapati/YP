<script lang="ts">
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { traceabilityRecordUpdateSchema } from '@samavāya/agriculture/schemas';
  import { traceabilityClient } from '@samavāya/agriculture/services';
  import { stringValue, toDateInput, toTimestamp } from '@samavāya/agriculture/convert';

  /**
   * Editing a traceability record.
   *
   * The form is the *update* schema, not the create one. `UpdateRecord` accepts
   * origin, seed source and four dates; batch id, product name, farm, field and
   * crop are immutable, because a record is the chain of custody for one
   * specific batch and repointing it rewrites provenance rather than correcting
   * it. Rendering the create form here would have offered five fields the RPC
   * silently discards.
   *
   * There is no DeleteRecord and there should not be: removing a record erases
   * provenance instead of amending it.
   */

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const res = await traceabilityClient.getRecord({ id });
      const record = res.record;
      if (record) {
        values = {
          origin_country: record.originCountry ?? '',
          origin_region: record.originRegion ?? '',
          seed_source: record.seedSource ?? '',
          planting_date: toDateInput(record.plantingDate),
          harvest_date: toDateInput(record.harvestDate),
          processing_date: toDateInput(record.processingDate),
          packaging_date: toDateInput(record.packagingDate),
        };
      }
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
      // Each field named explicitly rather than spread. The form uses the
      // proto's snake_case names and the generated client uses camelCase, so a
      // spread would hand protobuf-es keys it does not recognise — it drops
      // them, the request succeeds, and nothing changes.
      await traceabilityClient.updateRecord({
        id,
        originCountry: stringValue(formValues.origin_country),
        originRegion: stringValue(formValues.origin_region),
        seedSource: stringValue(formValues.seed_source),
        plantingDate: toTimestamp(formValues.planting_date),
        harvestDate: toTimestamp(formValues.harvest_date),
        processingDate: toTimestamp(formValues.processing_date),
        packagingDate: toTimestamp(formValues.packaging_date),
      });
      await goto('/supply-chain/traceability');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to save traceability record';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Edit Traceability Record"
  subtitle="Origin, seed source and key dates"
  mode="edit"
  schema={traceabilityRecordUpdateSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/supply-chain/traceability"
  showDelete={false}
  onSubmit={handleSubmit}
/>
