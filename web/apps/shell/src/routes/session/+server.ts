import { json, type RequestHandler } from '@sveltejs/kit';

/**
 * Creates and destroys the server-visible session cookie.
 *
 * `hooks.server.ts` validates a `session` cookie on every request and the
 * `(app)` layout guard redirects to `/login` when it finds no user. The auth
 * store signs in from the browser, where an HttpOnly cookie cannot be written
 * — so before this endpoint existed, a correct email and password produced a
 * successful login followed immediately by a redirect back to the login page,
 * for ever.
 *
 * Handing the token to the server here, rather than letting the store write
 * the cookie with `document.cookie`, is also what lets it carry HttpOnly: the
 * comment in `hooks.server.ts` describes the client-side cookie as the state
 * of things "until" a server endpoint sets it. This is that endpoint.
 */

/** Seven days, matching the refresh token's lifetime in auth-service. */
const MAX_AGE = 60 * 60 * 24 * 7;

const COOKIE_OPTIONS = {
  path: '/',
  httpOnly: true,
  // Off in dev, where the dev server speaks plain HTTP and a Secure cookie
  // would simply not be stored — which looks exactly like a broken login.
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'lax' as const,
  maxAge: MAX_AGE,
};

export const POST: RequestHandler = async ({ request, cookies }) => {
  const body = (await request.json().catch(() => null)) as { accessToken?: string } | null;

  if (!body?.accessToken) {
    return json({ error: 'accessToken is required' }, { status: 400 });
  }

  // Not validated here: `hooks.server.ts` calls `/auth/me` on the next
  // request and clears the cookie if the token is rejected. Validating twice
  // would double every login's latency to guard against a caller who can only
  // lock themselves out.
  cookies.set('session', body.accessToken, COOKIE_OPTIONS);

  return json({ ok: true });
};

export const DELETE: RequestHandler = async ({ cookies }) => {
  cookies.delete('session', { path: '/' });
  return json({ ok: true });
};
