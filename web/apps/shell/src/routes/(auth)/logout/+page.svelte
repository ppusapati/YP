<script lang="ts">
  import { authStore } from '@samavāya/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';

  /**
   * Signs out, and completes the other half of the login flow.
   *
   * There are three places a session lives and all three have to be cleared or
   * the user is not really signed out: auth-service's `sessions` row (so the
   * refresh token cannot be replayed), the browser's stored token pair, and
   * the server-visible `session` cookie. `authStore.logout()` does the first
   * two; the DELETE below does the third.
   *
   * A page rather than a button because the shell chrome is shared with the
   * other apps — `/logout` is a link anything can point at.
   */

  let message = $state('Signing out…');

  onMount(async () => {
    await authStore.logout();

    try {
      await fetch('/session', { method: 'DELETE' });
    } catch {
      // The cookie outlives a failed request here. Say so rather than claim a
      // clean sign-out: on a shared machine the difference matters.
      message = 'Signed out locally, but the server session could not be cleared.';
      return;
    }

    await goto('/login');
  });
</script>

<svelte:head>
  <title>Signing out - samavāya</title>
</svelte:head>

<p>{message}</p>
