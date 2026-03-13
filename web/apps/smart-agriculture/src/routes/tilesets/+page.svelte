<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { tileClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'farmId', label: 'Farm' },
    { key: 'layer', label: 'Layer' },
    { key: 'format', label: 'Format' },
    { key: 'status', label: 'Status' },
    { key: 'minZoom', label: 'Zoom Range', render: (row: any) => `${row.minZoom}–${row.maxZoom}` },
    { key: 'totalTiles', label: 'Tiles' },
    { key: 'createdAt', label: 'Created' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await tileClient.listTilesets({ pageSize, pageOffset });
      rows = res.tilesets;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load tilesets';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Tilesets"
  createHref="/tilesets/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/tilesets/${id}`)}
  {totalCount}
  {fetchData}
/>
