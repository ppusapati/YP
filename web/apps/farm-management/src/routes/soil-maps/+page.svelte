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
    { key: 'map_type', label: 'Map Type' },
    { key: 'generated_date', label: 'Generated Date' },
    { key: 'resolution', label: 'Resolution' },
    { key: 'status', label: 'Status' },
  ];

  async function load() {
    // getSoilMap takes a field id and returns that field's record. It is
    // not a listing, so there is nothing to page through.
    const fieldId = $page.url.searchParams.get('fieldId') ?? '';
    if (!fieldId) {
      error = 'Choose a field to see its soil map.';
      loading = false;
      return;
    }

    loading = true;
    error = null;
    try {
      const res = await soilClient.getSoilMap({ fieldId });
      rows = res.soilMap ? [res.soilMap] : [];
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load soil map';
      rows = [];
    } finally {
      loading = false;
    }
  }

  onMount(load);
</script>

<EntityListPage
  title="Soil Maps"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/soil-maps/${id}`)}
/>
