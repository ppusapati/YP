<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { computeIndicesFormSchema } from '@samavāya/agriculture/schemas';
  import { vegetationIndexClient } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const res = await vegetationIndexClient.getVegetationIndex({ id });
      values = { ...res.index };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load vegetation index';
    } finally {
      isLoading = false;
    }
  });
</script>

<CrudFormPage
  title="Vegetation Index Details"
  subtitle="View computed vegetation index data"
  mode="view"
  schema={computeIndicesFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/computed-indices"
/>

{#if !isLoading && !error}
  <div class="mt-6 bg-white border border-gray-200 rounded-lg p-6 mx-6">
    <h3 class="text-lg font-semibold mb-4">Index Results</h3>
    <div class="grid grid-cols-2 gap-4 sm:grid-cols-4">
      <div class="rounded-md bg-gray-50 p-4">
        <p class="text-sm text-gray-500">Mean Value</p>
        <p class="text-xl font-bold">{values.meanValue ?? '—'}</p>
      </div>
      <div class="rounded-md bg-gray-50 p-4">
        <p class="text-sm text-gray-500">Min Value</p>
        <p class="text-xl font-bold">{values.minValue ?? '—'}</p>
      </div>
      <div class="rounded-md bg-gray-50 p-4">
        <p class="text-sm text-gray-500">Max Value</p>
        <p class="text-xl font-bold">{values.maxValue ?? '—'}</p>
      </div>
      <div class="rounded-md bg-gray-50 p-4">
        <p class="text-sm text-gray-500">Std Deviation</p>
        <p class="text-xl font-bold">{values.stdDeviation ?? '—'}</p>
      </div>
    </div>
  </div>
{/if}
