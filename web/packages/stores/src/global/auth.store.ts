/**
 * Auth Store
 * Handles authentication state, tokens, and session management
 */

import { writable, derived, get, type Readable } from 'svelte/store';

// ============================================================================
// AUTH SERVICE ENDPOINT
// ============================================================================

/**
 * Where auth-service is reachable from the browser.
 *
 * The api-gateway publishes it under `/auth/*` at the origin root — not under
 * `/api/`, which is where the ConnectRPC services live. A relative default
 * means the app talks to whatever origin served it, which is what both the
 * dev proxy and the deployed gateway arrange.
 */
let authBaseUrl = '/auth';

/** Points the store at a different auth-service origin (tests, native shells). */
export function configureAuth(options: { baseUrl: string }): void {
  authBaseUrl = options.baseUrl.replace(/\/$/, '');
}

/** The shape auth-service returns for a user, on `/auth/login` and `/auth/me`. */
interface AuthServiceUser {
  id: string;
  tenant_id: string;
  name: string;
  email: string;
  role: string;
}

/** The shape auth-service returns for a token pair. */
interface AuthServiceToken {
  access_token: string;
  refresh_token: string;
  /** Unix seconds. */
  expires_at: number;
}

/**
 * Turns auth-service's flat user into the store's.
 *
 * auth-service holds one `name` column rather than a given/family pair, so the
 * split here is positional and the display name is the original string. That
 * ordering is wrong for a good part of the world, which is why `displayName`
 * — not `firstName lastName` — is what the UI shows.
 */
function toUser(u: AuthServiceUser): User {
  const parts = u.name.trim().split(/\s+/);
  return {
    id: u.id,
    email: u.email,
    firstName: parts[0] ?? '',
    lastName: parts.slice(1).join(' '),
    displayName: u.name || u.email,
    role: u.role,
    tenantId: u.tenant_id,
  };
}

function toTokens(t: AuthServiceToken): AuthTokens {
  return {
    accessToken: t.access_token,
    refreshToken: t.refresh_token,
    expiresAt: new Date(t.expires_at * 1000),
    tokenType: 'Bearer',
  };
}

/**
 * Reads an error message out of an auth-service response.
 *
 * It answers `{"error": "invalid credentials"}` with the right status, so the
 * message is worth surfacing: "invalid credentials" tells someone to check
 * their password, and "Login failed (500)" tells them to try again later.
 * Collapsing both into one string loses that.
 */
async function messageFor(res: Response, fallback: string): Promise<string> {
  try {
    const body = (await res.json()) as { error?: string };
    if (body.error) return body.error;
  } catch {
    // Not JSON — a gateway 502 page, say.
  }
  return `${fallback} (${res.status})`;
}

// ============================================================================
// TYPES
// ============================================================================

export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  displayName: string;
  /** Role name as auth-service issues it, e.g. `admin`, `agronomist`, `platform`. */
  role?: string;
  /** The tenant this user belongs to; every backend call is scoped by it. */
  tenantId?: string;
  avatar?: string;
  phone?: string;
  locale?: string;
  timezone?: string;
  metadata?: Record<string, unknown>;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresAt: Date;
  tokenType: 'Bearer';
}

export interface Permission {
  resource: string;
  action: string;
  conditions?: Record<string, unknown>;
}

export interface Role {
  id: string;
  name: string;
  displayName: string;
  permissions: Permission[];
}

export interface Session {
  id: string;
  userId: string;
  deviceInfo?: {
    userAgent: string;
    platform: string;
    browser: string;
  };
  ipAddress?: string;
  location?: string;
  createdAt: Date;
  lastActiveAt: Date;
  expiresAt: Date;
  isCurrent: boolean;
}

export interface AuthState {
  isAuthenticated: boolean;
  isLoading: boolean;
  isInitialized: boolean;
  user: User | null;
  tokens: AuthTokens | null;
  roles: Role[];
  permissions: Permission[];
  session: Session | null;
  error: AuthError | null;
}

export interface AuthError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}

export interface LoginCredentials {
  email: string;
  password: string;
  rememberMe?: boolean;
  mfaCode?: string;
}

export interface RegisterData {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  phone?: string;
}

export interface AuthStoreActions {
  // Authentication
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => Promise<void>;
  register: (data: RegisterData) => Promise<void>;

  // Token management
  refreshTokens: () => Promise<void>;
  setTokens: (tokens: AuthTokens) => void;
  clearTokens: () => void;

  // User management
  setUser: (user: User) => void;
  updateUser: (updates: Partial<User>) => void;
  clearUser: () => void;

  // Session management
  setSession: (session: Session) => void;
  clearSession: () => void;

  // Permissions
  setRoles: (roles: Role[]) => void;
  setPermissions: (permissions: Permission[]) => void;
  hasPermission: (resource: string, action: string) => boolean;
  hasRole: (roleName: string) => boolean;
  hasAnyRole: (roleNames: string[]) => boolean;
  hasAllRoles: (roleNames: string[]) => boolean;

  // State management
  initialize: () => Promise<void>;
  reset: () => void;
  setError: (error: AuthError | null) => void;
  setLoading: (isLoading: boolean) => void;
}

// ============================================================================
// INITIAL STATE
// ============================================================================

/** Storage key for the persisted token pair. */
const TOKEN_KEY = 'auth_tokens';

/**
 * Whether web storage is usable.
 *
 * It is absent during SSR and throws in a browser with site data blocked, and
 * the store has to keep working in both: a private-window user should be able
 * to sign in for the session, not see the app fail to start.
 */
function hasStorage(): boolean {
  try {
    return typeof localStorage !== 'undefined' && typeof sessionStorage !== 'undefined';
  } catch {
    return false;
  }
}

const initialState: AuthState = {
  isAuthenticated: false,
  isLoading: false,
  isInitialized: false,
  user: null,
  tokens: null,
  roles: [],
  permissions: [],
  session: null,
  error: null,
};

// ============================================================================
// STORE CREATION
// ============================================================================

function createAuthStore() {
  const store = writable<AuthState>(initialState);
  const { subscribe, set, update } = store;

  // Scheduled pre-expiry token refresh.
  let refreshTimer: ReturnType<typeof setTimeout> | null = null;

  // ============================================================================
  // DERIVED STORES
  // ============================================================================

  const user: Readable<User | null> = derived(store, ($s) => $s.user);
  const isAuthenticated: Readable<boolean> = derived(store, ($s) => $s.isAuthenticated);
  const isLoading: Readable<boolean> = derived(store, ($s) => $s.isLoading);
  const roles: Readable<Role[]> = derived(store, ($s) => $s.roles);
  const permissions: Readable<Permission[]> = derived(store, ($s) => $s.permissions);

  // ============================================================================
  // ACTIONS
  // ============================================================================

  async function login(credentials: LoginCredentials): Promise<void> {
    update((s) => ({ ...s, isLoading: true, error: null }));

    try {
      const res = await fetch(`${authBaseUrl}/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: credentials.email,
          password: credentials.password,
        }),
      });

      if (!res.ok) {
        throw new Error(await messageFor(res, 'Login failed'));
      }

      const body = (await res.json()) as {
        token: AuthServiceToken;
        user: AuthServiceUser;
      };

      const tokens = toTokens(body.token);
      const user = toUser(body.user);

      update((s) => ({
        ...s,
        isAuthenticated: true,
        isLoading: false,
        user,
        tokens,
        // auth-service issues a single role per user rather than a role list
        // with embedded permissions. Representing it as a one-element list
        // keeps hasRole/hasAnyRole working against real data instead of
        // against an empty array that answers "no" to everything.
        roles: [{ id: user.role ?? '', name: user.role ?? '', displayName: user.role ?? '', permissions: [] }],
        error: null,
      }));

      persistTokens(tokens, credentials.rememberMe ?? false);
      startTokenRefresh();
    } catch (error) {
      const authError: AuthError = {
        code: 'LOGIN_FAILED',
        message: error instanceof Error ? error.message : 'Login failed',
      };
      update((s) => ({ ...s, isLoading: false, error: authError }));
      throw error;
    }
  }

  async function logout(): Promise<void> {
    update((s) => ({ ...s, isLoading: true }));

    try {
      const token = get(store).tokens?.accessToken;
      if (token) {
        // Revokes the session server-side so the refresh token cannot be
        // replayed. Best-effort: a failure here must not leave the browser
        // logged in, which is why the local teardown is in `finally`.
        await fetch(`${authBaseUrl}/logout`, {
          method: 'POST',
          headers: { Authorization: `Bearer ${token}` },
        });
      }
    } catch {
      // Network down; the local half still has to happen.
    } finally {
      clearPersistedTokens();
      stopTokenRefresh();
      set(initialState);
    }
  }

  /**
   * Self-registration, which this platform does not have.
   *
   * auth-service serves login, refresh, me and logout — there is no signup
   * route, because accounts are created by a tenant administrator against a
   * tenant that already exists. This used to resolve successfully without
   * calling anything, so a registration form would clear, congratulate the
   * user, and leave them with no account.
   */
  async function register(_data: RegisterData): Promise<void> {
    const authError: AuthError = {
      code: 'REGISTER_UNSUPPORTED',
      message: 'Accounts are created by a tenant administrator, not by signing up.',
    };
    update((s) => ({ ...s, isLoading: false, error: authError }));
    throw new Error(authError.message);
  }

  async function refreshTokens(): Promise<void> {
    const state = get(store);
    if (!state.tokens?.refreshToken) return;

    try {
      const res = await fetch(`${authBaseUrl}/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refresh_token: state.tokens.refreshToken }),
      });

      if (!res.ok) {
        throw new Error(await messageFor(res, 'Token refresh failed'));
      }

      // auth-service rotates the refresh token on every use: the old one is
      // revoked as part of the exchange, so keeping it would log the user out
      // at the next refresh.
      const body = (await res.json()) as { token: AuthServiceToken };
      const newTokens = toTokens(body.token);

      update((s) => ({ ...s, tokens: newTokens }));
      persistTokens(newTokens, localStorage.getItem(TOKEN_KEY) !== null);
      startTokenRefresh();
    } catch {
      // The refresh token is gone or rejected; there is no way back to an
      // authenticated state from here, so end the session rather than leave
      // the UI looking signed in with credentials that no longer work.
      await logout();
    }
  }

  function setTokens(tokens: AuthTokens): void {
    update((s) => ({ ...s, tokens }));
  }

  function clearTokens(): void {
    update((s) => ({ ...s, tokens: null }));
    clearPersistedTokens();
  }

  function setUser(user: User): void {
    update((s) => ({ ...s, user, isAuthenticated: true }));
  }

  function updateUser(updates: Partial<User>): void {
    update((s) => ({
      ...s,
      user: s.user ? { ...s.user, ...updates } : null,
    }));
  }

  function clearUser(): void {
    update((s) => ({ ...s, user: null, isAuthenticated: false }));
  }

  function setSession(session: Session): void {
    update((s) => ({ ...s, session }));
  }

  function clearSession(): void {
    update((s) => ({ ...s, session: null }));
  }

  function setRoles(roles: Role[]): void {
    // Extract all permissions from roles
    const allPermissions = roles.flatMap((r) => r.permissions);
    update((s) => ({ ...s, roles, permissions: allPermissions }));
  }

  function setPermissions(permissions: Permission[]): void {
    update((s) => ({ ...s, permissions }));
  }

  function hasPermission(resource: string, action: string): boolean {
    const state = get(store);
    return state.permissions.some(
      (p) => p.resource === resource && p.action === action
    );
  }

  function hasRole(roleName: string): boolean {
    const state = get(store);
    return state.roles.some((r) => r.name === roleName);
  }

  function hasAnyRole(roleNames: string[]): boolean {
    const state = get(store);
    return roleNames.some((name) => state.roles.some((r) => r.name === name));
  }

  function hasAllRoles(roleNames: string[]): boolean {
    const state = get(store);
    return roleNames.every((name) => state.roles.some((r) => r.name === name));
  }

  /**
   * Restores a session from stored tokens on app start.
   *
   * Always ends with `isInitialized: true`, however it goes: a guard that
   * waits for initialization would otherwise hang forever on a failure, which
   * looks to the user like the app never loads rather than like they are
   * signed out.
   */
  async function initialize(): Promise<void> {
    update((s) => ({ ...s, isLoading: true }));

    try {
      const stored = readPersistedTokens();

      if (stored) {
        update((s) => ({ ...s, tokens: stored }));

        if (stored.expiresAt <= new Date()) {
          // Access token has expired. Refreshing is the only way to recover,
          // and it logs out on its own if the refresh token is dead too.
          await refreshTokens();
        }

        // Fetch the user with whatever access token we now hold. This is also
        // what proves the token is genuinely still valid — an unexpired
        // `expiresAt` says nothing about a session the server has revoked.
        const token = get(store).tokens?.accessToken;
        if (token) {
          const res = await fetch(`${authBaseUrl}/me`, {
            headers: { Authorization: `Bearer ${token}` },
          });

          if (res.ok) {
            const user = toUser((await res.json()) as AuthServiceUser);
            update((s) => ({
              ...s,
              isAuthenticated: true,
              user,
              roles: [
                {
                  id: user.role ?? '',
                  name: user.role ?? '',
                  displayName: user.role ?? '',
                  permissions: [],
                },
              ],
            }));
            startTokenRefresh();
          } else {
            // The server does not recognise this token. Drop it rather than
            // keep retrying with a credential that will never work.
            clearPersistedTokens();
            update((s) => ({ ...s, tokens: null, isAuthenticated: false, user: null }));
          }
        }
      }

      update((s) => ({ ...s, isLoading: false, isInitialized: true }));
    } catch {
      clearPersistedTokens();
      update((s) => ({
        ...s,
        tokens: null,
        isAuthenticated: false,
        user: null,
        isLoading: false,
        isInitialized: true,
      }));
    }
  }

  function reset(): void {
    stopTokenRefresh();
    set(initialState);
  }

  function setError(error: AuthError | null): void {
    update((s) => ({ ...s, error }));
  }

  function setLoading(isLoading: boolean): void {
    update((s) => ({ ...s, isLoading }));
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  /**
   * Schedules a single refresh five minutes before the access token expires.
   *
   * A `setTimeout` rather than a `setInterval`, because the rotation gives a
   * new expiry each time and a fixed interval drifts away from it. Each
   * successful refresh arms the next one.
   */
  function startTokenRefresh(): void {
    const state = get(store);
    if (!state.tokens) return;
    if (typeof setTimeout !== 'function') return;

    const expiresIn = state.tokens.expiresAt.getTime() - Date.now();
    const refreshIn = Math.max(expiresIn - 5 * 60 * 1000, 60 * 1000);

    stopTokenRefresh();
    refreshTimer = setTimeout(() => {
      void refreshTokens();
    }, refreshIn);
  }

  /**
   * Tokens live in `localStorage` when "remember me" was ticked and in
   * `sessionStorage` otherwise, which is the difference the tick box promises.
   * Both are written through the same pair of helpers so a refresh cannot
   * quietly move a session from one to the other.
   */
  function persistTokens(tokens: AuthTokens, remember: boolean): void {
    if (!hasStorage()) return;
    const json = JSON.stringify(tokens);
    if (remember) {
      localStorage.setItem(TOKEN_KEY, json);
      sessionStorage.removeItem(TOKEN_KEY);
    } else {
      sessionStorage.setItem(TOKEN_KEY, json);
      localStorage.removeItem(TOKEN_KEY);
    }
  }

  function readPersistedTokens(): AuthTokens | null {
    if (!hasStorage()) return null;
    const raw = localStorage.getItem(TOKEN_KEY) ?? sessionStorage.getItem(TOKEN_KEY);
    if (!raw) return null;
    try {
      const parsed = JSON.parse(raw) as AuthTokens;
      // JSON has no Date, so `expiresAt` comes back as a string and every
      // comparison against it silently succeeds until it is rebuilt.
      return { ...parsed, expiresAt: new Date(parsed.expiresAt) };
    } catch {
      return null;
    }
  }

  function clearPersistedTokens(): void {
    if (!hasStorage()) return;
    localStorage.removeItem(TOKEN_KEY);
    sessionStorage.removeItem(TOKEN_KEY);
  }

  function stopTokenRefresh(): void {
    if (refreshTimer) {
      clearTimeout(refreshTimer);
      refreshTimer = null;
    }
  }

  // ============================================================================
  // RETURN
  // ============================================================================

  return {
    subscribe,
    // Derived stores
    user,
    isAuthenticated,
    isLoading,
    roles,
    permissions,
    // Actions
    login,
    logout,
    register,
    refreshTokens,
    setTokens,
    clearTokens,
    setUser,
    updateUser,
    clearUser,
    setSession,
    clearSession,
    setRoles,
    setPermissions,
    hasPermission,
    hasRole,
    hasAnyRole,
    hasAllRoles,
    initialize,
    reset,
    setError,
    setLoading,
  };
}

// ============================================================================
// EXPORT
// ============================================================================

export const authStore = createAuthStore();
