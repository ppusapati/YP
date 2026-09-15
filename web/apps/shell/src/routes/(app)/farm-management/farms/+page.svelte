<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { farmClient } from '@samavāya/agriculture/services';
  import type { Farm } from '@samavāya/agriculture/types';

  let rows: Farm[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'name', label: 'Farm Name' },
    { key: 'farmType', label: 'Type' },
    { key: 'totalAreaHectares', label: 'Area (ha)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'region', label: 'Region' },
    { key: 'country', label: 'Country' },
    { key: 'status', label: 'Status' },
  ];

  // Token-paginated: the request carries the page_token the previous response
  // returned. Sending an offset did not typecheck, and had it compiled the
  // server would have ignored it and returned page one every time.
  let pageTokens: string[] = [''];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    const __i = Math.floor(pageOffset / Math.max(pageSize, 1));
    loading = true;
    error = null;
    try {
      const res = await farmClient.listFarms({ pageSize, pageToken: pageTokens[__i] ?? '' });
      rows = res.farms;
      if (res.nextPageToken) pageTokens[__i + 1] = res.nextPageToken;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load farms';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Farms"
  createHref="/farm-management/farms/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/farm-management/farms/${id}`)}
  {fetchData}
/>
