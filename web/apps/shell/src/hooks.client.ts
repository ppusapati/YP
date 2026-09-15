import { authStore } from '@samavāya/stores';

/**
 * Client-side initialization.
 *
 * This file previously called `initApiProviders()` from a `@samavāya/api`
 * package that does not exist in this repository, and wrapped a commented-out
 * `initializeApi(...)` in a try/catch — so it did nothing, and the catch made
 * the nothing look deliberate. The ConnectRPC clients in
 * `@samavāya/agriculture/services` build their own transports and need no
 * global setup.
 *
 * What does need to happen on start is restoring the session: the access token
 * lives in web storage, and without reading it back the user is signed out on
 * every reload. `initialize()` always resolves — it reports failure through
 * the store's state rather than by rejecting — so there is nothing to catch.
 */
void authStore.initialize();
