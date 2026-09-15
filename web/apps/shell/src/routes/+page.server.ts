import { redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

/**
 * Route the visitor according to whether they are actually signed in.
 *
 * This replaces a client-side `$effect` that called `goto('/dashboard')`
 * unconditionally, under a comment reading "Temporarily bypass auth". Anyone
 * opening the site landed inside the application shell.
 *
 * Deciding on the server matters: `hooks.server.ts` has already validated the
 * session cookie against the auth service and put the result in `locals`, so
 * this is the verified answer rather than whatever the browser believes. A
 * client-side check can be skipped by disabling JavaScript; this cannot.
 */
export const load: PageServerLoad = async ({ locals }) => {
  if (locals.user) {
    redirect(303, '/dashboard');
  }
  redirect(303, '/login');
};
