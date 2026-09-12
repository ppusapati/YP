import { describe, it, expect, vi } from 'vitest';
import { get } from 'svelte/store';
import {
  authStore,
  type User,
  type AuthTokens,
  type Role,
  type Permission,
} from '@samavāya/stores/global/auth.store';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function sampleUser(overrides?: Partial<User>): User {
  return {
    id: 'usr-1',
    email: 'alice@example.com',
    firstName: 'Alice',
    lastName: 'Doe',
    displayName: 'Alice Doe',
    ...overrides,
  };
}

function sampleTokens(overrides?: Partial<AuthTokens>): AuthTokens {
  return {
    accessToken: 'access-xyz',
    refreshToken: 'refresh-xyz',
    expiresAt: new Date(Date.now() + 3_600_000),
    tokenType: 'Bearer',
    ...overrides,
  };
}

function sampleRole(overrides?: Partial<Role>): Role {
  return {
    id: 'role-admin',
    name: 'admin',
    displayName: 'Administrator',
    permissions: [
      { resource: 'farms', action: 'read' },
      { resource: 'farms', action: 'write' },
    ],
    ...overrides,
  };
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

describe('authStore', () => {
  // Reset the store to its initial state before every test.
  beforeEach(() => {
    authStore.reset();
  });

  // -----------------------------------------------------------------------
  // Login / setUser
  // -----------------------------------------------------------------------

  describe('login (setUser + setTokens)', () => {
    it('updates auth state to authenticated when a user is set', () => {
      authStore.setUser(sampleUser());
      authStore.setTokens(sampleTokens());

      const state = get(authStore);

      expect(state.isAuthenticated).toBe(true);
      expect(state.user).toEqual(expect.objectContaining({ email: 'alice@example.com' }));
      expect(state.tokens?.accessToken).toBe('access-xyz');
    });

    it('exposes the user via the derived store', () => {
      authStore.setUser(sampleUser({ firstName: 'Bob' }));
      expect(get(authStore.user)?.firstName).toBe('Bob');
    });

    it('exposes isAuthenticated via the derived store', () => {
      expect(get(authStore.isAuthenticated)).toBe(false);
      authStore.setUser(sampleUser());
      expect(get(authStore.isAuthenticated)).toBe(true);
    });
  });

  // -----------------------------------------------------------------------
  // Logout / reset
  // -----------------------------------------------------------------------

  describe('logout (reset)', () => {
    it('clears all auth state back to the initial values', () => {
      authStore.setUser(sampleUser());
      authStore.setTokens(sampleTokens());
      authStore.setRoles([sampleRole()]);

      authStore.reset();

      const state = get(authStore);
      expect(state.isAuthenticated).toBe(false);
      expect(state.user).toBeNull();
      expect(state.tokens).toBeNull();
      expect(state.roles).toEqual([]);
      expect(state.permissions).toEqual([]);
    });

    it('clearTokens removes tokens from state and storage', () => {
      authStore.setTokens(sampleTokens());
      localStorage.setItem('auth_tokens', 'dummy');

      authStore.clearTokens();

      expect(get(authStore).tokens).toBeNull();
      expect(localStorage.getItem('auth_tokens')).toBeNull();
    });
  });

  // -----------------------------------------------------------------------
  // Token refresh (unit-level: setTokens replacement)
  // -----------------------------------------------------------------------

  describe('token refresh (setTokens)', () => {
    it('replaces existing tokens with new ones', () => {
      authStore.setTokens(sampleTokens({ accessToken: 'old' }));
      expect(get(authStore).tokens?.accessToken).toBe('old');

      authStore.setTokens(sampleTokens({ accessToken: 'new' }));
      expect(get(authStore).tokens?.accessToken).toBe('new');
    });
  });

  // -----------------------------------------------------------------------
  // Role-based access
  // -----------------------------------------------------------------------

  describe('role-based access checks', () => {
    beforeEach(() => {
      authStore.setRoles([
        sampleRole({ id: 'role-admin', name: 'admin' }),
        sampleRole({
          id: 'role-viewer',
          name: 'viewer',
          permissions: [{ resource: 'reports', action: 'read' }],
        }),
      ]);
    });

    it('hasRole returns true for a role the user holds', () => {
      expect(authStore.hasRole('admin')).toBe(true);
      expect(authStore.hasRole('viewer')).toBe(true);
    });

    it('hasRole returns false for a role the user does not hold', () => {
      expect(authStore.hasRole('superadmin')).toBe(false);
    });

    it('hasAnyRole matches if at least one role is held', () => {
      expect(authStore.hasAnyRole(['admin', 'superadmin'])).toBe(true);
    });

    it('hasAllRoles fails if any role is missing', () => {
      expect(authStore.hasAllRoles(['admin', 'viewer'])).toBe(true);
      expect(authStore.hasAllRoles(['admin', 'superadmin'])).toBe(false);
    });

    it('hasPermission checks resource + action pairs', () => {
      expect(authStore.hasPermission('farms', 'read')).toBe(true);
      expect(authStore.hasPermission('farms', 'write')).toBe(true);
      expect(authStore.hasPermission('reports', 'read')).toBe(true);
      expect(authStore.hasPermission('reports', 'write')).toBe(false);
    });

    it('setPermissions overrides permissions independently of roles', () => {
      const custom: Permission[] = [{ resource: 'billing', action: 'manage' }];
      authStore.setPermissions(custom);

      expect(authStore.hasPermission('billing', 'manage')).toBe(true);
      // The old role-derived permissions should be replaced.
      expect(authStore.hasPermission('farms', 'read')).toBe(false);
    });
  });

  // -----------------------------------------------------------------------
  // Error handling
  // -----------------------------------------------------------------------

  describe('error handling', () => {
    it('setError stores the error in state', () => {
      authStore.setError({ code: 'TEST', message: 'something broke' });
      expect(get(authStore).error?.code).toBe('TEST');
    });

    it('setError(null) clears the error', () => {
      authStore.setError({ code: 'TEST', message: 'x' });
      authStore.setError(null);
      expect(get(authStore).error).toBeNull();
    });
  });

  // -----------------------------------------------------------------------
  // Loading state
  // -----------------------------------------------------------------------

  describe('loading state', () => {
    it('setLoading toggles the isLoading flag', () => {
      authStore.setLoading(true);
      expect(get(authStore.isLoading)).toBe(true);

      authStore.setLoading(false);
      expect(get(authStore.isLoading)).toBe(false);
    });
  });
});
