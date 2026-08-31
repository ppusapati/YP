<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { traceabilityClient } from '@samavāya/agriculture/services';
  import type { Certification } from '@samavāya/agriculture/types';

  let rows: Certification[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'name', label: 'Certification' },
    { key: 'code', label: 'Code' },
    { key: 'certifying_body', label: 'Certifying Body' },
    { key: 'certification_type', label: 'Type' },
    { key: 'issue_date', label: 'Issued' },
    { key: 'expiry_date', label: 'Expires' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await traceabilityClient.listCertifications({ pageSize, pageOffset });
      rows = res.certifications;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load certifications';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Certifications"
  createHref="/certifications/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/certifications/${id}`)}
  {totalCount}
  {fetchData}
/>
