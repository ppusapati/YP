import { error } from '@sveltejs/kit';
import { env } from '$env/dynamic/private';
import type { PageServerLoad } from './$types';

const ADMIN_API_URL = env.ADMIN_API_URL || 'http://localhost:8080';

type HealthState = 'ok' | 'quiet' | 'degraded' | 'suspended' | 'unknown';

export type TenantSummary = {
  tenant_id: string;
  name: string;
  region: string;
  type: string;
  is_active: boolean;
  farms: number;
  fields: number;
  sensors: number;
  users: number;
  last_activity_at?: string;
  storage_bytes: number;
  usage_gathered_at?: string;
  health: HealthState;
  health_reason?: string;
};

/**
 * The cross-tenant operations view.
 *
 * Loaded on the server, and the authorization is checked there too — twice,
 * in fact, and deliberately.
 *
 * The backend refuses anything but the platform role, which is the check that
 * actually protects the data. The check below is not a substitute for it: it
 * exists so a tenant admin who navigates here gets a 403 page instead of an
 * empty dashboard with a failed fetch behind it. A UI-only check would be
 * security theatre; a UI check *in addition to* the server's is just a better
 * error message.
 */
export const load: PageServerLoad = async ({ locals, fetch }) => {
  if (locals.user?.role !== 'platform') {
    error(403, 'This page is for platform operators.');
  }

  const res = await fetch(`${ADMIN_API_URL}/admin/tenants`, {
    headers: { Accept: 'application/json' },
  });

  if (!res.ok) {
    // Surfaced rather than swallowed into an empty list. An operations page
    // that shows no tenants because the call failed looks identical to one
    // showing a platform with no tenants, and the second is the reassuring
    // reading.
    error(res.status, `Could not load tenants: ${res.statusText}`);
  }

  const tenants = (await res.json()) as TenantSummary[];
  return { tenants };
};
