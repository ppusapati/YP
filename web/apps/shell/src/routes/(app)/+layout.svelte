<script lang="ts">
  import { ErpShell } from '@samavāya/ui';
  import { page } from '$app/stores';

  let { children } = $props();

  const MODULE_IDS = [
    'identity', 'masters', 'finance', 'sales', 'purchase',
    'inventory', 'hr', 'manufacturing', 'projects', 'asset',
    'fulfillment', 'insights', 'workflow', 'budget', 'banking',
    'notifications', 'audit', 'platform', 'communication', 'data', 'land',
    'farm-management', 'smart-agriculture', 'crop-intelligence', 'supply-chain',
  ];

  const activeModule = $derived(() => {
    const path = $page.url.pathname;
    const segment = path.split('/')[1] ?? '';
    return MODULE_IDS.includes(segment) ? segment : 'dashboard';
  });
</script>

<ErpShell activeModule={activeModule()} currentPath={$page.url.pathname}>
  {@render children()}
</ErpShell>
