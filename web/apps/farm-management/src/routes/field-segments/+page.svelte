<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { fieldClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'name', label: 'Segment Name' },
    { key: 'field_name', label: 'Field' },
    { key: 'area_hectares', label: 'Area (ha)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'soil_type', label: 'Soil Type' },
  ];

  async function load() {
    // getFieldSegments takes a field id and returns that field's
    // records. It is not a listing: there is no page token, no offset and no
    // total count, which is what this page was asking it for.
    const fieldId = $page.url.searchParams.get('fieldId') ?? '';
    if (!fieldId) {
      // Calling with an empty id returns nothing, and an empty table reads as
      // "this field has none" rather than "you have not chosen one".
      error = 'Choose a field to see its records.';
      loading = false;
      return;
    }

    loading = true;
    error = null;
    try {
      const res = await fieldClient.getFieldSegments({ fieldId });
      rows = res.segments;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load field segments';
      rows = [];
    } finally {
      loading = false;
    }
  }

  onMount(load);
</script>

<EntityListPage
  title="Field Segments"
  createHref="/field-segments/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/field-segments/${id}`)}
/>
