<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { cropClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'crop_name', label: 'Crop' },
    { key: 'optimal_temp_min', label: 'Min Temp (C)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'optimal_temp_max', label: 'Max Temp (C)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'soil_ph_min', label: 'pH Min', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'soil_ph_max', label: 'pH Max', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'water_requirement_mm', label: 'Water (mm)', format: (v: unknown) => v != null ? `${v}` : '—' },
  ];

  async function load() {
    // getCropRequirements takes a crop id and returns that crop's
    // records. It is not a listing: there is no page token, no offset and no
    // total count, which is what this page was asking it for.
    const cropId = $page.url.searchParams.get('cropId') ?? '';
    if (!cropId) {
      // Calling with an empty id returns nothing, and an empty table reads as
      // "this crop has none" rather than "you have not chosen one".
      error = 'Choose a crop to see its records.';
      loading = false;
      return;
    }

    loading = true;
    error = null;
    try {
      const res = await cropClient.getCropRequirements({ cropId });
      rows = res.requirements ? [res.requirements] : [];
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load crop requirements';
      rows = [];
    } finally {
      loading = false;
    }
  }

  onMount(load);
</script>

<EntityListPage
  title="Crop Requirements"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/crop-requirements/${id}`)}
/>
