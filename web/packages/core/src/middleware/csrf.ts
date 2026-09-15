/**
 * CSRF Protection Middleware
 *
 * Implements the double-submit cookie pattern:
 * - Generates a random CSRF token and sets it as a cookie
 * - Requires the same token in a request header for state-changing methods
 * - Validates the Origin header against the request URL
 * - Skips validation for safe HTTP methods (GET, HEAD, OPTIONS)
 */

import type {
  Middleware,
  MiddlewareEvent,
  MiddlewareResult,
  CSRFConfig,
} from './types.js';

// ============================================================================
// Default Configuration
// ============================================================================

const DEFAULT_CONFIG: Required<CSRFConfig> = {
  cookieName: 'csrf-token',
  headerName: 'x-csrf-token',
  fieldName: '_csrf',
  methods: ['POST', 'PUT', 'PATCH', 'DELETE'],
  excludedRoutes: [],
};

/** Safe methods that do not require CSRF validation */
const SAFE_METHODS = new Set(['GET', 'HEAD', 'OPTIONS']);

// ============================================================================
// Helpers
// ============================================================================

/**
 * Generate a cryptographically random token as a hex string
 */
function generateToken(length = 32): string {
  const bytes = new Uint8Array(length);
  crypto.getRandomValues(bytes);
  return Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
}

/**
 * Check whether the request's Origin header matches the target URL origin
 */
function isOriginAllowed(request: Request, url: URL): boolean {
  const origin = request.headers.get('origin');

  // No Origin header present — typically same-origin navigation; allow it
  if (!origin) {
    return true;
  }

  // Compare against the application's own origin
  return origin === url.origin;
}

/**
 * Check whether a route is excluded from CSRF validation
 */
function isExcludedRoute(pathname: string, excludedRoutes: string[]): boolean {
  return excludedRoutes.some(
    (route) => pathname === route || pathname.startsWith(route + '/')
  );
}

/**
 * Constant-time string comparison to prevent timing attacks
 */
function safeCompare(a: string, b: string): boolean {
  if (a.length !== b.length) {
    return false;
  }

  let mismatch = 0;
  for (let i = 0; i < a.length; i++) {
    mismatch |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }

  return mismatch === 0;
}

// ============================================================================
// CSRF Guard Factory
// ============================================================================

/**
 * Create a CSRF protection middleware
 *
 * Uses the double-submit cookie pattern: a random token is stored in a cookie
 * and must be echoed back via a request header (or form field) on every
 * state-changing request. If the values do not match, the request is rejected
 * with a 403 status.
 *
 * @example
 * ```ts
 * import { compose, createCsrfGuard } from '@samavāya/core/middleware';
 *
 * const middleware = compose(
 *   createCsrfGuard({ excludedRoutes: ['/api/webhooks'] }),
 *   createAuthGuard()
 * );
 * ```
 */
export function createCsrfGuard(config: CSRFConfig = {}): Middleware {
  const cookieName = config.cookieName ?? DEFAULT_CONFIG.cookieName;
  const headerName = config.headerName ?? DEFAULT_CONFIG.headerName;
  const fieldName = config.fieldName ?? DEFAULT_CONFIG.fieldName;
  const protectedMethods = new Set(
    (config.methods ?? DEFAULT_CONFIG.methods).map((m) => m.toUpperCase())
  );
  const excludedRoutes = config.excludedRoutes ?? DEFAULT_CONFIG.excludedRoutes;

  return async (event: MiddlewareEvent): Promise<MiddlewareResult> => {
    const { url, request, cookies } = event;
    const method = request.method.toUpperCase();

    // ----------------------------------------------------------------
    // Always ensure a CSRF token cookie exists (needed by the client
    // to read the token and include it in future requests).
    // ----------------------------------------------------------------
    let cookieToken = cookies.get(cookieName);

    if (!cookieToken) {
      cookieToken = generateToken();
      cookies.set(cookieName, cookieToken, {
        path: '/',
        httpOnly: false, // client JS must be able to read the token
        sameSite: 'lax',
        secure: url.protocol === 'https:',
      });
    }

    // ----------------------------------------------------------------
    // Safe methods and excluded routes skip validation
    // ----------------------------------------------------------------
    if (SAFE_METHODS.has(method) || !protectedMethods.has(method)) {
      return { continue: true };
    }

    if (isExcludedRoute(url.pathname, excludedRoutes)) {
      return { continue: true };
    }

    // ----------------------------------------------------------------
    // Origin validation
    // ----------------------------------------------------------------
    if (!isOriginAllowed(request, url)) {
      console.warn(
        `[CSRF] Origin mismatch: expected ${url.origin}, got ${request.headers.get('origin')}`
      );
      return {
        continue: false,
        error: {
          status: 403,
          message: 'CSRF validation failed: origin mismatch',
        },
      };
    }

    // ----------------------------------------------------------------
    // Double-submit cookie validation
    // ----------------------------------------------------------------
    // The token can arrive as a header or, for traditional form posts, as a
    // body field. We check the header first since it is the most common path.
    const headerToken = request.headers.get(headerName);

    if (headerToken && cookieToken && safeCompare(headerToken, cookieToken)) {
      return { continue: true };
    }

    // If no header token was supplied the request is rejected. Checking the
    // form body would require consuming the request stream, so we leave form
    // field validation to application-level code that has already parsed the
    // body. The fieldName default is exposed for that purpose.
    if (!headerToken) {
      console.warn(`[CSRF] Missing ${headerName} header for ${method} ${url.pathname}`);
      return {
        continue: false,
        error: {
          status: 403,
          message: 'CSRF validation failed: missing token',
        },
      };
    }

    // Token was present but did not match
    console.warn(`[CSRF] Token mismatch for ${method} ${url.pathname}`);
    return {
      continue: false,
      error: {
        status: 403,
        message: 'CSRF validation failed: token mismatch',
      },
    };
  };
}

// ============================================================================
// Re-export alias
// ============================================================================

/**
 * Alias for {@link createCsrfGuard} for convenience
 */
export const csrfGuard = createCsrfGuard;
