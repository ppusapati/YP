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
    { key: 'stage_name', label: 'Growth Stage' },
    { key: 'stage_order', label: 'Order' },
    { key: 'duration_days', label: 'Duration (days)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'description', label: 'Description' },
  ];

  async function load() {
    // getGrowthStages takes a crop id and returns that crop's
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
      const res = await cropClient.getGrowthStages({ cropId });
      rows = res.growthStages;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load growth stages';
      rows = [];
    } finally {
      loading = false;
    }
  }

  onMount(load);
</script>

<EntityListPage
  title="Growth Stages"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/farm-management/growth-stages/${id}`)}
/>
