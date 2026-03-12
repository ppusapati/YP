<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { traceabilityClient } from '@samavāya/agriculture/services';
  import type { TraceabilityRecord } from '@samavāya/agriculture/types';

  let rows: TraceabilityRecord[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'batchNumber', label: 'Batch' },
    { key: 'productType', label: 'Product' },
    { key: 'originCountry', label: 'Code' },
    { key: 'originRegion', label: 'Origin Farm' },
    { key: 'harvestDate', label: 'Harvest Date' },
    { key: 'complianceStatus', label: 'Location' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await traceabilityClient.listRecords({ pageSize, pageOffset });
      rows = res.records;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load traceability records';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Traceability Records"
  createHref="/traceability/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/traceability/${id}`)}
  {totalCount}
  {fetchData}
/>
