<script lang="ts">
  import { authStore } from '@samavāya/stores';
  import { goto } from '$app/navigation';
  import { page } from '$app/stores';
  import { get } from 'svelte/store';

  let email = $state('');
  let password = $state('');
  let rememberMe = $state(false);
  let isLoading = $state(false);
  let error = $state<string | null>(null);

  async function handleSubmit(e: Event) {
    e.preventDefault();
    error = null;
    isLoading = true;

    try {
      await authStore.login({ email, password, rememberMe });

      // Hand the access token to the server so it can set the HttpOnly
      // `session` cookie. Without this the store is signed in but the server
      // is not, and the `(app)` guard sends us straight back here.
      const token = get(authStore).tokens?.accessToken;
      const res = await fetch('/session', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ accessToken: token }),
      });

      if (!res.ok) {
        // Reported rather than navigated past: going on to /dashboard would
        // bounce back to this page with no explanation.
        throw new Error('Signed in, but the session could not be established.');
      }

      // `redirectTo` is set by the `(app)` guard when it turns someone away,
      // so an expired session resumes where it left off.
      const target = $page.url.searchParams.get('redirectTo');
      await goto(target && target.startsWith('/') ? target : '/dashboard');
    } catch (err) {
      error = err instanceof Error ? err.message : 'Login failed. Please try again.';
    } finally {
      isLoading = false;
    }
  }
</script>

<svelte:head>
  <title>Login - samavāya ERP</title>
</svelte:head>

<div class="w-full">
  <h2 class="text-2xl font-semibold text-text mb-xs">Welcome back</h2>
  <p class="text-text-secondary mb-xl">Sign in to your account</p>

  <form onsubmit={handleSubmit} class="flex flex-col gap-lg">
    {#if error}
      <div class="form-error" role="alert">
        {error}
      </div>
    {/if}

    <div class="flex flex-col gap-xs">
      <label for="email" class="flex justify-between items-center text-sm font-medium text-text">Email</label>
      <input
        type="email"
        id="email"
        bind:value={email}
        required
        autocomplete="email"
        class="form-input"
        placeholder="you@company.com"
        disabled={isLoading}
      />
    </div>

    <div class="flex flex-col gap-xs">
      <label for="password" class="flex justify-between items-center text-sm font-medium text-text">
        Password
        <a href="/forgot-password" class="text-xs font-normal text-primary">Forgot password?</a>
      </label>
      <input
        type="password"
        id="password"
        bind:value={password}
        required
        autocomplete="current-password"
        class="form-input"
        placeholder="Enter your password"
        disabled={isLoading}
      />
    </div>

    <div class="flex items-center">
      <label class="flex items-center gap-sm text-sm text-text-secondary cursor-pointer">
        <input type="checkbox" bind:checked={rememberMe} disabled={isLoading} class="form-checkbox" />
        <span>Remember me</span>
      </label>
    </div>

    <button type="submit" class="btn btn-primary w-full" disabled={isLoading}>
      {#if isLoading}
        <span class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></span>
        Signing in...
      {:else}
        Sign in
      {/if}
    </button>
  </form>

  <p class="text-center mt-xl text-sm text-text-secondary">
    Don't have an account? <a href="/register" class="text-primary font-medium">Sign up</a>
  </p>
</div>
