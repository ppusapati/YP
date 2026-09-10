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
 */
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
