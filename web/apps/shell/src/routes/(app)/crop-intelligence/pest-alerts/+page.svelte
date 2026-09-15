<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { pestClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'field_name', label: 'Field' },
    { key: 'pest_name', label: 'Pest' },
    { key: 'severity', label: 'Severity' },
    { key: 'message', label: 'Message' },
    { key: 'triggered_at', label: 'Triggered At' },
    { key: 'acknowledged', label: 'Acknowledged', format: (v: unknown) => v ? 'Yes' : 'No' },
  ];

  // pest-prediction names this ListAlerts.
  // Token-paginated, like the RPC it now calls.
  let pageTokens: string[] = [''];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    const __i = Math.floor(pageOffset / Math.max(pageSize, 1));
    loading = true;
    error = null;
    try {
      const res = await pestClient.listAlerts({ pageSize, pageToken: pageTokens[__i] ?? '' });
      rows = res.alerts;
      if (res.nextPageToken) pageTokens[__i + 1] = res.nextPageToken;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load pest alerts';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Pest Alerts"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/crop-intelligence/pest-alerts/${id}`)}
  {fetchData}
/>
