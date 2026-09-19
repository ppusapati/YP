<script lang="ts">
  // Nothing to decide here.
  //
  // `+page.server.ts` beside this file always redirects — to /dashboard with a
  // session, to /login without — so this component is only ever on screen for
  // the instant before the browser follows a 303, and on a slow connection it
  // is what the visitor sees in the meantime.
  //
  // It used to carry a client-side `$effect` calling `goto('/dashboard')` under
  // a comment reading "Temporarily bypass auth". The server load replaced it,
  // making the effect unreachable, but the comment stayed — and a comment
  // announcing an auth bypass is worth removing even when it is describing code
  // that can no longer run, because the next reader has no way to know that.
</script>

<div class="loading-container">
  <div class="loading-spinner"></div>
  <p>Loading...</p>
</div>

<style>
  .loading-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-height: 100vh;
    gap: var(--spacing-md);
  }

  .loading-spinner {
    width: 40px;
    height: 40px;
    border: 3px solid var(--color-border);
    border-top-color: var(--color-primary);
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }

  p {
    color: var(--color-text-secondary);
    font-size: 0.875rem;
  }
</style>
