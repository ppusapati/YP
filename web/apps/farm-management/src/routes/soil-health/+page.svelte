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
    { key: 'overall_score', label: 'Overall Score', format: (v: unknown) => v != null ? `${v}/100` : '—' },
    { key: 'organic_matter_score', label: 'Organic Matter', format: (v: unknown) => v != null ? `${v}/100` : '—' },
    { key: 'nutrient_score', label: 'Nutrient Score', format: (v: unknown) => v != null ? `${v}/100` : '—' },
    { key: 'ph_score', label: 'pH Score', format: (v: unknown) => v != null ? `${v}/100` : '—' },
    { key: 'last_assessed', label: 'Last Assessed' },
  ];

  async function load() {
    // getSoilHealth takes a field id and returns that field's record. It is
    // not a listing, so there is nothing to page through.
    const fieldId = $page.url.searchParams.get('fieldId') ?? '';
    if (!fieldId) {
      error = 'Choose a field to see its soil health.';
      loading = false;
      return;
    }

    loading = true;
    error = null;
    try {
      const res = await soilClient.getSoilHealth({ fieldId });
      rows = res.healthScore ? [res.healthScore] : [];
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load soil health';
      rows = [];
    } finally {
      loading = false;
    }
  }

  onMount(load);
</script>

<EntityListPage
  title="Soil Health Scores"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/soil-health/${id}`)}
/>
