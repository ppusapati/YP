<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { fieldClient } from '@samavāya/agriculture/services';
  import type { Field } from '@samavāya/agriculture/types';

  let rows: Field[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'name', label: 'Field Name' },
    { key: 'code', label: 'Code' },
    { key: 'area', label: 'Area' },
    { key: 'soilType', label: 'Soil Type' },
    { key: 'irrigationType', label: 'Irrigation' },
    { key: 'current_crop_name', label: 'Current Crop' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await fieldClient.listFields({ pageSize, pageOffset });
      rows = res.fields;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load fields';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Fields"
  createHref="/fields/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/fields/${id}`)}
  {totalCount}
  {fetchData}
/>
