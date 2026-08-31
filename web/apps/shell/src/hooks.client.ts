// import { initializeApi } from '@samavāya/api';
import { initApiProviders } from '@samavāya/stores';

/**
 * Client-side initialization
 */

// Wire up stores as API providers (breaks cyclic dep: api ↔ stores)
initApiProviders();

// Initialize API client
try {
  // initializeApi({
  //   baseUrl: import.meta.env.VITE_API_URL || 'http://localhost:8080',
  //   timeout: 30000,
  //   credentials: 'include',
  //   debug: import.meta.env.DEV,
  //   withAuth: true,
  //   withTenant: true,
  //   withErrorHandling: true,
  //   withRetry: true,
  //   withLogging: import.meta.env.DEV,
  // });
} catch (error) {
  console.error('[hooks.client] Failed to initialize API:', error);
}
