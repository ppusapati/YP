<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { farmClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'owner_name', label: 'Owner Name' },
    { key: 'email', label: 'Email' },
    { key: 'phone', label: 'Phone' },
    { key: 'ownership_percentage', label: 'Ownership %', format: (v: unknown) => v != null ? `${v}%` : '—' },
    { key: 'is_primary', label: 'Primary', format: (v: unknown) => v ? 'Yes' : 'No' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await farmClient.listFarms({ pageSize, pageOffset });
      rows = res.farms;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load farm owners';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Farm Owners"
  createHref="/farm-owners/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/farm-owners/${id}`)}
  {fetchData}
/>
