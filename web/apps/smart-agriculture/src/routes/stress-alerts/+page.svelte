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

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await analyticsClient.listStressAlerts({ pageSize, pageOffset });
      rows = res.alerts;
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
