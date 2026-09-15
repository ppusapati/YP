<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { analyticsClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'farmId', label: 'Farm' },
    { key: 'fieldId', label: 'Field' },
    { key: 'stressType', label: 'Stress Type' },
    { key: 'severity', label: 'Severity' },
    { key: 'confidence', label: 'Confidence' },
    { key: 'affectedAreaHectares', label: 'Affected Area' },
    { key: 'acknowledged', label: 'Acknowledged', format: (v: unknown) => v ? 'Yes' : 'No' },
    { key: 'detectedAt', label: 'Detected' },
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
      const res = await analyticsClient.listStressAlerts({ pageSize, pageToken: pageTokens[__i] ?? '' });
      rows = res.alerts;
      if (res.nextPageToken) pageTokens[__i + 1] = res.nextPageToken;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load stress alerts';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Stress Alerts"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/stress-alerts/${id}`)}
  {fetchData}
/>
