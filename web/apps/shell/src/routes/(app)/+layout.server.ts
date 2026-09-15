import { redirect } from '@sveltejs/kit';
import type { LayoutServerLoad } from './$types';

/**
 * Require a validated session for everything under `(app)`.
 *
 * The group had no guard at all: `hooks.server.ts` validated the session
 * cookie and put the result in `locals`, and then nothing consulted it. Any
 * route under the shell — dashboard, farm management, prescriptions — rendered
 * for a visitor with no session.
 *
 * A layout load is the right place because it runs for every child route,
 * including ones added later. A guard repeated per route is a guard that will
 * eventually be forgotten on one.
 *
 * `redirectTo` lets the login page send the user back where they were aiming,
 * rather than dropping them on the dashboard after signing in.
 */
export const load: LayoutServerLoad = async ({ locals, url }) => {
  if (!locals.user) {
    const target = url.pathname + url.search;
    redirect(303, `/login?redirectTo=${encodeURIComponent(target)}`);
  }

  return {
    user: locals.user,
    tenant: locals.tenant,
  };
};
