<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { yieldClient } from '@samavāya/agriculture/services';
  import type { YieldRecord } from '@samavāya/agriculture/types';

  let rows: YieldRecord[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'crop_name', label: 'Crop' },
    { key: 'field_id', label: 'Field' },
    { key: 'harvestDate', label: 'Harvest Date' },
    { key: 'actual_yield', label: 'Yield' },
    { key: 'yield_unit', label: 'Unit' },
    { key: 'quality_grade', label: 'Grade' },
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
      const res = await yieldClient.getYieldHistory({ pageSize, pageToken: pageTokens[__i] ?? '' });
      rows = res.records;
      if (res.nextPageToken) pageTokens[__i + 1] = res.nextPageToken;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load yield records';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Yield Records"
  createHref="/crop-intelligence/yield/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/crop-intelligence/yield/${id}`)}
  {totalCount}
  {fetchData}
/>
