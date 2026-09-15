<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { soilClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'field_name', label: 'Field' },
    { key: 'nitrogen_ppm', label: 'Nitrogen (ppm)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'phosphorus_ppm', label: 'Phosphorus (ppm)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'potassium_ppm', label: 'Potassium (ppm)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'calcium_ppm', label: 'Calcium (ppm)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'magnesium_ppm', label: 'Magnesium (ppm)', format: (v: unknown) => v != null ? `${v}` : '—' },
  ];

  async function load() {
    // getNutrientLevels takes a soil sample id and returns that soil sample's
    // records. It is not a listing: there is no page token, no offset and no
    // total count, which is what this page was asking it for.
    const sampleId = $page.url.searchParams.get('sampleId') ?? '';
    if (!sampleId) {
      // Calling with an empty id returns nothing, and an empty table reads as
      // "this soil sample has none" rather than "you have not chosen one".
      error = 'Choose a soil sample to see its records.';
      loading = false;
      return;
    }

    loading = true;
    error = null;
    try {
      const res = await soilClient.getNutrientLevels({ sampleId });
      rows = res.nutrients;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load nutrient levels';
      rows = [];
    } finally {
      loading = false;
    }
  }

  onMount(load);
</script>

<EntityListPage
  title="Nutrient Levels"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/nutrient-levels/${id}`)}
/>
