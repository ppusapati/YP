<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { cropClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'crop_name', label: 'Crop' },
    { key: 'stage_name', label: 'Growth Stage' },
    { key: 'stage_order', label: 'Order' },
    { key: 'duration_days', label: 'Duration (days)', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'description', label: 'Description' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await cropClient.getGrowthStages({ pageSize, pageOffset });
      rows = res.stages;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load growth stages';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Growth Stages"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/growth-stages/${id}`)}
  {fetchData}
/>
