<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { certificationService } from '@samavāya/agriculture/services';
  import type { Certification } from '@samavāya/agriculture/types';

  let rows: Certification[] = [];
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

  async function fetchData() {
    loading = true;
    error = null;
    try {
      const res = await certificationService.list({ page: 1, page_size: 50 });
      rows = res.items;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load certifications';
      rows = [];
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
  {fetchData}
/>
