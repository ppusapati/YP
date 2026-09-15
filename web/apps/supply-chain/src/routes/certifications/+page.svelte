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

  // These two RPCs are token-paginated, not offset-paginated: the request
  // carries a page_token the previous response handed back. The page passed an
  // offset the message has never had, so it did not typecheck, and had it
  // compiled the server would have ignored it and returned page one every time.
  let pageTokens: string[] = [''];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      // A token for a page we have not walked to yet does not exist, so a jump
      // past the end restarts from the beginning rather than silently showing
      // the wrong page.
      const index = Math.floor(pageOffset / Math.max(pageSize, 1));
      const pageToken = pageTokens[index] ?? '';

      const res = await traceabilityClient.listCertifications({ pageSize, pageToken });
      rows = res.certifications;
      totalCount = res.totalCount;
      if (res.nextPageToken) {
        pageTokens[index + 1] = res.nextPageToken;
      }
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
