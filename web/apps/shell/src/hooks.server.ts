import type { Handle } from '@sveltejs/kit';
import { env } from '$env/dynamic/private';

const AUTH_SERVICE_URL = env.AUTH_SERVICE_URL || 'http://localhost:8090';

interface ValidatedUser {
  id: string;
  tenant_id: string;
  name: string;
  email: string;
  role: string;
}

async function validateSession(accessToken: string): Promise<{ user: ValidatedUser; tenant: { id: string } } | null> {
  const res = await fetch(`${AUTH_SERVICE_URL}/auth/me`, {
    headers: { 'Authorization': `Bearer ${accessToken}` },
  });
  if (!res.ok) return null;
  const user = await res.json() as ValidatedUser;
  return {
    user,
    tenant: { id: user.tenant_id },
  };
}

/**
 * Server-side hook for authentication and tenant context.
 *
 * Reads the access token from the `session` cookie and validates it
 * against the auth service on every server-side request. Invalid or
 * expired tokens cause the cookie to be cleared.
 *
 * SECURITY NOTE: The `session` cookie is currently set on the client side
 * (via the auth store in the browser). This means the cookie lacks HttpOnly
 * and is accessible to JavaScript, exposing it to XSS-based token theft.
 * The recommended fix is to move cookie creation to a server-side login
 * endpoint (e.g. +server.ts) that sets the cookie with the secure flags
 * below. Until then, re-set the cookie here on every successful validation
 * to enforce HttpOnly, Secure, and SameSite attributes.
 */

/** Shared cookie options for the session cookie. */
const SESSION_COOKIE_OPTIONS = {
  path: '/',
  httpOnly: true,
  secure: true,
  sameSite: 'lax' as const,
  maxAge: 60 * 60 * 24 * 7, // 7 days
};

export const handle: Handle = async ({ event, resolve }) => {
  const accessToken = event.cookies.get('session');

  event.locals.user = null;
  event.locals.tenant = null;
  event.locals.sessionId = accessToken ?? null;

  if (accessToken) {
    try {
      const session = await validateSession(accessToken);
      if (session) {
        event.locals.user = session.user as App.Locals['user'];
        event.locals.tenant = session.tenant as App.Locals['tenant'];

        // Re-set the cookie with secure flags so that even if the client
        // originally created it without HttpOnly/Secure, subsequent
        // requests carry the hardened version.
        event.cookies.set('session', accessToken, SESSION_COOKIE_OPTIONS);
      } else {
        event.cookies.delete('session', { path: '/' });
      }
    } catch {
      event.cookies.delete('session', { path: '/' });
    }
  }

  const response = await resolve(event, {
    transformPageChunk: ({ html }) => html,
  });

  return response;
};
