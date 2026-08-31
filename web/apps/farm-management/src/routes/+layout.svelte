<script lang="ts">
  import 'virtual:uno.css';
  import { ErpRootLayout, ErpShell } from '@samavāya/ui';
  import { page } from '$app/stores';

  let { children } = $props();
</script>

<ErpRootLayout>
  <ErpShell
    activeModule="farm-management"
    currentPath={$page.url.pathname}
    brandName="samavāya"
  >
    {@render children()}
  </ErpShell>
</ErpRootLayout>
