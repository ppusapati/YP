<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { farmService } from '@samavāya/agriculture/services';
  import type { Farm } from '@samavāya/agriculture/types';

  let rows: Farm[] = [];
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'name', label: 'Farm Name' },
    { key: 'code', label: 'Code' },
    { key: 'farm_type', label: 'Type' },
    { key: 'total_area', label: 'Area', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'city', label: 'City' },
    { key: 'state', label: 'State' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData() {
    loading = true;
    error = null;
    try {
      const res = await farmService.list({ page: 1, page_size: 50 });
      rows = res.items;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load farms';
      rows = [];
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Farms"
  createHref="/farms/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/farms/${id}`)}
  {fetchData}
/>
