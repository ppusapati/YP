# samavāya ERP Frontend Architecture

## 1. System Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              samavāya ERP FRONTEND                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                        PRESENTATION LAYER                            │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │    │
│  │  │  Pages   │ │  Views   │ │  Layouts │ │  Modals  │ │  Widgets │  │    │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘  │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                    │                                         │
│  ┌─────────────────────────────────▼───────────────────────────────────┐    │
│  │                        UI COMPONENT LIBRARY                          │    │
│  │  @samavāya/ui (47+ components)                                        │    │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │    │
│  │  │  Forms  │ │ Tables  │ │  Nav    │ │Feedback │ │ Display │       │    │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                    │                                         │
│  ┌─────────────────────────────────▼───────────────────────────────────┐    │
│  │                         STATE MANAGEMENT                             │    │
│  │  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐            │    │
│  │  │ Global Stores │  │ Module Stores │  │Component State│            │    │
│  │  │ (Auth, Theme) │  │ (Per Feature) │  │   (Local)     │            │    │
│  │  └───────────────┘  └───────────────┘  └───────────────┘            │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                    │                                         │
│  ┌─────────────────────────────────▼───────────────────────────────────┐    │
│  │                          API CLIENT LAYER                            │    │
│  │  ┌─────────────────────────────────────────────────────────────┐    │    │
│  │  │                    ConnectRPC Client                         │    │    │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │    │    │
│  │  │  │Auth Int. │ │Tenant Int│ │Error Int.│ │Retry Int.│       │    │    │
│  │  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │    │    │
│  │  └─────────────────────────────────────────────────────────────┘    │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                    │                                         │
└────────────────────────────────────┼────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKEND MICROSERVICES                              │
│                    (Golang + ConnectRPC + PostgreSQL)                        │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐        │
│  │Identity│ │Finance │ │  HR    │ │ Sales  │ │Inventory│ │  ...   │        │
│  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘ └────────┘        │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Monorepo Structure

```
samavāya-web/
├── apps/
│   └── web/                          # Main SvelteKit Application
│       ├── src/
│       │   ├── routes/               # SvelteKit file-based routing
│       │   │   ├── (app)/            # Authenticated app routes
│       │   │   │   ├── +layout.svelte
│       │   │   │   ├── dashboard/
│       │   │   │   └── [module]/     # Dynamic module routes
│       │   │   ├── (auth)/           # Authentication routes
│       │   │   │   ├── login/
│       │   │   │   ├── register/
│       │   │   │   └── forgot-password/
│       │   │   └── +layout.svelte
│       │   │
│       │   ├── lib/
│       │   │   ├── api/              # API client & generated code
│       │   │   │   ├── client.ts     # ConnectRPC client setup
│       │   │   │   ├── interceptors/ # Request/response interceptors
│       │   │   │   └── generated/    # Protobuf generated types
│       │   │   │
│       │   │   ├── stores/           # Global Svelte stores
│       │   │   │   ├── auth.ts
│       │   │   │   ├── tenant.ts
│       │   │   │   ├── theme.ts
│       │   │   │   └── notification.ts
│       │   │   │
│       │   │   ├── modules/          # Feature modules
│       │   │   │   ├── identity/
│       │   │   │   ├── finance/
│       │   │   │   ├── hr/
│       │   │   │   ├── sales/
│       │   │   │   ├── inventory/
│       │   │   │   ├── manufacturing/
│       │   │   │   └── ... (20 modules)
│       │   │   │
│       │   │   └── shared/           # Shared app utilities
│       │   │       ├── guards/       # Route guards
│       │   │       ├── hooks/        # Svelte lifecycle hooks
│       │   │       └── constants/    # App constants
│       │   │
│       │   ├── app.html
│       │   ├── app.css
│       │   └── hooks.server.ts       # SvelteKit server hooks
│       │
│       ├── static/                   # Static assets
│       ├── svelte.config.js
│       ├── vite.config.ts
│       └── package.json
│
├── packages/
│   ├── ui/                           # Component Library (existing)
│   │   ├── src/
│   │   │   ├── forms/
│   │   │   ├── tables/
│   │   │   ├── navigation/
│   │   │   ├── feedback/
│   │   │   ├── display/
│   │   │   ├── layout/
│   │   │   ├── actions/
│   │   │   ├── types/
│   │   │   └── utils/
│   │   └── package.json
│   │
│   ├── design-tokens/                # Design System (existing)
│   │   ├── tokens/
│   │   └── package.json
│   │
│   ├── utility/                      # Utilities (existing)
│   │   ├── src/
│   │   │   ├── validation/
│   │   │   ├── formatting/
│   │   │   ├── date/
│   │   │   ├── file/
│   │   │   ├── string/
│   │   │   └── number/
│   │   └── package.json
│   │
│   ├── configs/                      # Shared Configs (existing)
│   │   └── package.json
│   │
│   └── proto/                        # Protobuf Definitions (NEW)
│       ├── src/
│       │   └── generated/            # Generated TS types from .proto
│       ├── buf.gen.yaml
│       └── package.json
│
├── turbo.json
├── package.json
└── pnpm-workspace.yaml
```

---

## 3. Module Architecture (Feature Module Pattern)

Each business module follows a consistent structure:

```
modules/finance/
├── index.ts                    # Module exports
├── finance.store.ts            # Module-level state
├── finance.api.ts              # API calls for this module
├── finance.types.ts            # Module-specific types
│
├── components/                 # Module-specific components
│   ├── JournalEntry/
│   │   ├── JournalEntry.svelte
│   │   ├── JournalEntry.types.ts
│   │   └── index.ts
│   ├── TrialBalance/
│   ├── InvoiceForm/
│   └── ...
│
├── views/                      # Full-page views
│   ├── GeneralLedger.svelte
│   ├── AccountsReceivable.svelte
│   ├── AccountsPayable.svelte
│   └── ...
│
└── services/                   # Service-specific logic
    ├── general-ledger/
    │   ├── index.ts
    │   ├── gl.api.ts
    │   ├── gl.store.ts
    │   └── gl.types.ts
    ├── journal/
    ├── transaction/
    └── ...
```

---

## 4. State Management Architecture

### 4.1 Three-Tier State Model

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           STATE HIERARCHY                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   TIER 1: GLOBAL STORES (Cross-application state)                       │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │  • authStore: User session, tokens, permissions                  │   │
│   │  • tenantStore: Current tenant, tenant settings                  │   │
│   │  • themeStore: Theme preference, color mode                      │   │
│   │  • notificationStore: Toasts, alerts, system messages            │   │
│   │  • settingsStore: App preferences, feature flags                 │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                     │
│   TIER 2: MODULE STORES (Feature-specific state)                        │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │  • financeStore: Active accounts, periods, preferences           │   │
│   │  • inventoryStore: Warehouses, stock alerts, filters             │   │
│   │  • salesStore: Active quotes, pipeline, territories              │   │
│   │  • hrStore: Current employee context, leave balances             │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                     │
│   TIER 3: COMPONENT STATE (Local/ephemeral state)                       │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │  • Form state (inputs, validation, dirty flags)                  │   │
│   │  • UI state (open/closed, selected tabs, scroll position)        │   │
│   │  • Filter/sort state (table configurations)                      │   │
│   │  • Modal state (visibility, current step)                        │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Store Implementation Pattern

```typescript
// stores/auth.ts
import { writable, derived } from 'svelte/store';
import type { User, Permission } from '$lib/api/generated/identity';

interface AuthState {
  user: User | null;
  accessToken: string | null;
  refreshToken: string | null;
  permissions: Permission[];
  isLoading: boolean;
  error: string | null;
}

const initialState: AuthState = {
  user: null,
  accessToken: null,
  refreshToken: null,
  permissions: [],
  isLoading: false,
  error: null,
};

function createAuthStore() {
  const { subscribe, set, update } = writable<AuthState>(initialState);

  return {
    subscribe,

    login: async (credentials: LoginRequest) => {
      update(state => ({ ...state, isLoading: true, error: null }));
      try {
        const response = await authApi.login(credentials);
        update(state => ({
          ...state,
          user: response.user,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          permissions: response.permissions,
          isLoading: false,
        }));
      } catch (error) {
        update(state => ({ ...state, error: error.message, isLoading: false }));
      }
    },

    logout: () => set(initialState),

    hasPermission: (permission: string) => {
      // Derived check logic
    },
  };
}

export const authStore = createAuthStore();

// Derived stores
export const isAuthenticated = derived(authStore, $auth => !!$auth.user);
export const currentUser = derived(authStore, $auth => $auth.user);
export const userPermissions = derived(authStore, $auth => $auth.permissions);
```

---

## 5. API Client Architecture

### 5.1 ConnectRPC Client Setup

```typescript
// lib/api/client.ts
import { createConnectTransport } from '@connectrpc/connect-web';
import { createClient } from '@connectrpc/connect';
import { authInterceptor } from './interceptors/auth';
import { tenantInterceptor } from './interceptors/tenant';
import { errorInterceptor } from './interceptors/error';
import { retryInterceptor } from './interceptors/retry';

const transport = createConnectTransport({
  baseUrl: import.meta.env.VITE_API_BASE_URL,
  interceptors: [
    authInterceptor,
    tenantInterceptor,
    errorInterceptor,
    retryInterceptor,
  ],
});

// Service clients
export const authClient = createClient(AuthService, transport);
export const userClient = createClient(UserService, transport);
export const financeClient = createClient(FinanceService, transport);
// ... more service clients
```

### 5.2 Interceptor Pattern

```typescript
// lib/api/interceptors/auth.ts
import type { Interceptor } from '@connectrpc/connect';
import { authStore } from '$lib/stores/auth';
import { get } from 'svelte/store';

export const authInterceptor: Interceptor = (next) => async (req) => {
  const { accessToken } = get(authStore);

  if (accessToken) {
    req.header.set('Authorization', `Bearer ${accessToken}`);
  }

  try {
    return await next(req);
  } catch (error) {
    if (error.code === 'UNAUTHENTICATED') {
      authStore.logout();
      goto('/login');
    }
    throw error;
  }
};

// lib/api/interceptors/tenant.ts
export const tenantInterceptor: Interceptor = (next) => async (req) => {
  const { currentTenant } = get(tenantStore);

  if (currentTenant) {
    req.header.set('X-Tenant-ID', currentTenant.id);
  }

  return next(req);
};
```

### 5.3 Protobuf Code Generation Pipeline

```yaml
# packages/proto/buf.gen.yaml
version: v2
managed:
  enabled: true
plugins:
  - plugin: es
    out: src/generated
    opt: target=ts
  - plugin: connect-es
    out: src/generated
    opt: target=ts
```

```json
// packages/proto/package.json
{
  "scripts": {
    "generate": "buf generate ../../../backend/proto",
    "build": "tsc"
  }
}
```

---

## 6. Routing Architecture

### 6.1 Route Structure

```
routes/
├── +layout.svelte              # Root layout
├── +page.svelte                # Landing/redirect
│
├── (auth)/                     # Auth group (no sidebar)
│   ├── +layout.svelte
│   ├── login/+page.svelte
│   ├── register/+page.svelte
│   └── forgot-password/+page.svelte
│
├── (app)/                      # App group (with sidebar)
│   ├── +layout.svelte          # AppShell with nav
│   ├── +layout.server.ts       # Auth guard
│   │
│   ├── dashboard/+page.svelte
│   │
│   ├── identity/
│   │   ├── users/
│   │   │   ├── +page.svelte    # User list
│   │   │   ├── [id]/+page.svelte # User detail
│   │   │   └── new/+page.svelte
│   │   ├── roles/
│   │   └── tenants/
│   │
│   ├── finance/
│   │   ├── general-ledger/
│   │   ├── journal/
│   │   ├── accounts-receivable/
│   │   └── ...
│   │
│   ├── hr/
│   │   ├── employees/
│   │   ├── leave/
│   │   ├── attendance/
│   │   └── ...
│   │
│   └── ... (all modules)
│
└── api/                        # API routes (if needed)
    └── [...path]/+server.ts
```

### 6.2 Route Guards

```typescript
// routes/(app)/+layout.server.ts
import { redirect } from '@sveltejs/kit';
import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ cookies, url }) => {
  const token = cookies.get('access_token');

  if (!token) {
    throw redirect(303, `/login?redirect=${url.pathname}`);
  }

  // Validate token and get user
  try {
    const user = await validateToken(token);
    return { user };
  } catch {
    cookies.delete('access_token');
    throw redirect(303, '/login');
  }
};
```

---

## 7. Component Architecture

### 7.1 Component Hierarchy

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        COMPONENT HIERARCHY                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  LEVEL 1: PRIMITIVE COMPONENTS (@samavāya/ui)                            │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Button, Input, Select, Checkbox, Table, Modal, Toast, etc.     │    │
│  │  • Framework agnostic logic                                      │    │
│  │  • Design token based styling                                    │    │
│  │  • Full accessibility support                                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                    │                                     │
│  LEVEL 2: COMPOSITE COMPONENTS                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  SearchableSelect, DataTable, FormSection, FilterPanel, etc.    │    │
│  │  • Combines multiple primitives                                  │    │
│  │  • Business logic agnostic                                       │    │
│  │  • Reusable across modules                                       │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                    │                                     │
│  LEVEL 3: FEATURE COMPONENTS (per module)                               │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  JournalEntryForm, InvoiceLineItems, EmployeeCard, etc.         │    │
│  │  • Module-specific business logic                                │    │
│  │  • API integration                                               │    │
│  │  • Domain-aware validation                                       │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                    │                                     │
│  LEVEL 4: PAGE COMPONENTS (Views)                                       │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  GeneralLedgerView, EmployeeListView, SalesOrderView, etc.      │    │
│  │  • Full page layouts                                             │    │
│  │  • Route-level data loading                                      │    │
│  │  • Page-level state management                                   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 7.2 Component Design Principles

```typescript
// Feature Component Example
// modules/finance/components/JournalEntry/JournalEntry.svelte

<script lang="ts">
  import { Input, Select, Button, DataGrid } from '@samavāya/ui';
  import { createEventDispatcher } from 'svelte';
  import { journalApi } from '../../finance.api';
  import type { JournalEntryProps, JournalLine } from './JournalEntry.types';

  export let entry: JournalEntryProps['entry'] = null;
  export let mode: 'create' | 'edit' | 'view' = 'create';

  const dispatch = createEventDispatcher<{
    save: { entry: JournalEntry };
    cancel: void;
  }>();

  let lines: JournalLine[] = entry?.lines ?? [];
  let isBalanced = $: calculateBalance(lines) === 0;

  async function handleSave() {
    if (!isBalanced) return;
    const saved = await journalApi.save({ ...entry, lines });
    dispatch('save', { entry: saved });
  }
</script>

<div class="journal-entry">
  <FormSection title="Journal Entry">
    <Input label="Reference" bind:value={entry.reference} />
    <DatePicker label="Date" bind:value={entry.date} />
    <!-- ... more fields -->
  </FormSection>

  <FormSection title="Line Items">
    <DataGrid
      data={lines}
      columns={lineColumns}
      editable={mode !== 'view'}
      on:change={handleLineChange}
    />
  </FormSection>

  <div class="actions">
    <Button variant="secondary" on:click={() => dispatch('cancel')}>
      Cancel
    </Button>
    <Button variant="primary" on:click={handleSave} disabled={!isBalanced}>
      Save Entry
    </Button>
  </div>
</div>
```

---

## 8. Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           DATA FLOW DIAGRAM                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌──────────────┐                                                       │
│   │   User       │                                                       │
│   │   Action     │                                                       │
│   └──────┬───────┘                                                       │
│          │                                                               │
│          ▼                                                               │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐              │
│   │  Component   │───▶│   Store      │───▶│   API Call   │              │
│   │  Event       │    │   Action     │    │   (async)    │              │
│   └──────────────┘    └──────────────┘    └──────┬───────┘              │
│                                                   │                      │
│                                                   ▼                      │
│                                           ┌──────────────┐              │
│                                           │  ConnectRPC  │              │
│                                           │  Transport   │              │
│                                           └──────┬───────┘              │
│                                                   │                      │
│         ┌─────────────────────────────────────────┘                     │
│         │                                                                │
│         ▼                                                               │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐              │
│   │   Backend    │───▶│   Response   │───▶│   Store      │              │
│   │   Service    │    │   Data       │    │   Update     │              │
│   └──────────────┘    └──────────────┘    └──────┬───────┘              │
│                                                   │                      │
│                                                   ▼                      │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐              │
│   │  UI Update   │◀───│  Svelte      │◀───│   Store      │              │
│   │  (Reactive)  │    │  Reactivity  │    │   Subscribe  │              │
│   └──────────────┘    └──────────────┘    └──────────────┘              │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 9. Security Architecture

### 9.1 Authentication Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        AUTHENTICATION FLOW                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   LOGIN FLOW:                                                            │
│   ┌────────┐    ┌────────┐    ┌────────┐    ┌────────┐                 │
│   │  User  │───▶│ Login  │───▶│  Auth  │───▶│ Store  │                 │
│   │ Input  │    │  Page  │    │Service │    │Tokens  │                 │
│   └────────┘    └────────┘    └────────┘    └───┬────┘                 │
│                                                  │                       │
│                                                  ▼                       │
│                                           ┌──────────┐                  │
│                                           │ Redirect │                  │
│                                           │ to App   │                  │
│                                           └──────────┘                  │
│                                                                          │
│   TOKEN REFRESH FLOW:                                                    │
│   ┌────────┐    ┌────────┐    ┌────────┐    ┌────────┐                 │
│   │ Token  │───▶│Intercept│──▶│ Refresh│───▶│  New   │                 │
│   │Expired │    │  401   │    │ Token  │    │ Token  │                 │
│   └────────┘    └────────┘    └────────┘    └────────┘                 │
│                                                                          │
│   PERMISSION CHECK:                                                      │
│   ┌────────────────────────────────────────────────────────────────┐    │
│   │  Component renders → Check permission → Show/Hide/Disable      │    │
│   │  Route guard → Check permission → Allow/Redirect               │    │
│   └────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 9.2 Permission-Based Access Control

```typescript
// lib/shared/guards/permission.ts
import { derived } from 'svelte/store';
import { authStore } from '$lib/stores/auth';

export function hasPermission(permission: string) {
  return derived(authStore, $auth =>
    $auth.permissions.some(p => p.code === permission)
  );
}

export function hasAnyPermission(permissions: string[]) {
  return derived(authStore, $auth =>
    permissions.some(perm =>
      $auth.permissions.some(p => p.code === perm)
    )
  );
}

// Usage in component
<script>
  import { hasPermission } from '$lib/shared/guards/permission';

  const canEdit = hasPermission('finance.journal.edit');
</script>

{#if $canEdit}
  <Button on:click={handleEdit}>Edit</Button>
{/if}
```

---

## 10. Performance Architecture

### 10.1 Code Splitting Strategy

```typescript
// vite.config.ts - Manual chunks for optimal splitting
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          // Core chunks
          'vendor': ['svelte', '@connectrpc/connect-web'],
          'ui': ['@samavāya/ui'],

          // Module chunks (lazy loaded)
          'finance': [
            './src/lib/modules/finance/index.ts'
          ],
          'hr': [
            './src/lib/modules/hr/index.ts'
          ],
          // ... other modules
        }
      }
    }
  }
});
```

### 10.2 Lazy Loading Pattern

```typescript
// routes/(app)/finance/+layout.ts
import type { LayoutLoad } from './$types';

export const load: LayoutLoad = async () => {
  // Dynamically import finance module
  const { financeStore, financeApi } = await import('$lib/modules/finance');

  return {
    financeStore,
    financeApi
  };
};
```

### 10.3 Data Caching Strategy

```typescript
// lib/api/cache.ts
import { writable, get } from 'svelte/store';

interface CacheEntry<T> {
  data: T;
  timestamp: number;
  ttl: number;
}

const cache = new Map<string, CacheEntry<any>>();

export function createCachedQuery<T>(
  key: string,
  fetcher: () => Promise<T>,
  ttl: number = 5 * 60 * 1000 // 5 minutes default
) {
  const store = writable<T | null>(null);

  async function fetch(force = false) {
    const cached = cache.get(key);

    if (!force && cached && Date.now() - cached.timestamp < cached.ttl) {
      store.set(cached.data);
      return cached.data;
    }

    const data = await fetcher();
    cache.set(key, { data, timestamp: Date.now(), ttl });
    store.set(data);
    return data;
  }

  function invalidate() {
    cache.delete(key);
  }

  return { subscribe: store.subscribe, fetch, invalidate };
}
```

---

## 11. Testing Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         TESTING PYRAMID                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│                           ┌─────────┐                                    │
│                           │   E2E   │  Playwright                        │
│                           │  Tests  │  Critical user flows               │
│                           └────┬────┘                                    │
│                        ────────┴────────                                 │
│                      ┌────────────────────┐                              │
│                      │   Integration      │  Testing Library             │
│                      │   Tests            │  Component + API             │
│                      └─────────┬──────────┘                              │
│                  ──────────────┴──────────────                           │
│                ┌────────────────────────────────┐                        │
│                │        Unit Tests              │  Vitest                │
│                │   Stores, Utils, Helpers       │  Fast, isolated        │
│                └────────────────────────────────┘                        │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Test Structure

```
tests/
├── unit/
│   ├── stores/
│   │   └── auth.test.ts
│   └── utils/
│       └── formatting.test.ts
├── integration/
│   ├── components/
│   │   └── JournalEntry.test.ts
│   └── pages/
│       └── Login.test.ts
└── e2e/
    ├── auth.spec.ts
    ├── finance.spec.ts
    └── ...
```

---

## 12. Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       DEPLOYMENT PIPELINE                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌────────┐    ┌────────┐    ┌────────┐    ┌────────┐                 │
│   │  Push  │───▶│  Build │───▶│  Test  │───▶│ Deploy │                 │
│   │  Code  │    │ + Lint │    │  Suite │    │  Stage │                 │
│   └────────┘    └────────┘    └────────┘    └───┬────┘                 │
│                                                  │                       │
│                                                  ▼                       │
│                                           ┌──────────┐                  │
│                                           │ Staging  │                  │
│                                           │   QA     │                  │
│                                           └────┬─────┘                  │
│                                                │                         │
│                                                ▼                         │
│                                           ┌──────────┐                  │
│                                           │Production│                  │
│                                           │  Deploy  │                  │
│                                           └──────────┘                  │
│                                                                          │
│   ENVIRONMENTS:                                                          │
│   ┌───────────────────────────────────────────────────────────────┐     │
│   │  Development: localhost:5173                                   │     │
│   │  Staging: staging.samavāya.app                                  │     │
│   │  Production: app.samavāya.app                                   │     │
│   └───────────────────────────────────────────────────────────────┘     │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 13. Design System Integration

### 13.1 Token Usage

```typescript
// Using design tokens in components
import { colors, spacing, typography } from '@p9e.in/design-tokens';

// UnoCSS configuration uses tokens
// unocss.config.ts
export default defineConfig({
  theme: {
    colors: colors,
    spacing: spacing,
    fontFamily: typography.fontFamily,
    fontSize: typography.fontSize,
  }
});
```

### 13.2 Theme Switching

```typescript
// stores/theme.ts
import { writable } from 'svelte/store';

type Theme = 'light' | 'dark' | 'system';

function createThemeStore() {
  const { subscribe, set } = writable<Theme>('system');

  return {
    subscribe,
    setTheme: (theme: Theme) => {
      set(theme);
      document.documentElement.setAttribute('data-theme', theme);
      localStorage.setItem('theme', theme);
    },
    initialize: () => {
      const saved = localStorage.getItem('theme') as Theme;
      if (saved) set(saved);
    }
  };
}

export const themeStore = createThemeStore();
```

---

## 14. Error Handling Strategy

```typescript
// lib/shared/errors/handler.ts
import { notificationStore } from '$lib/stores/notification';

export function handleApiError(error: ConnectError) {
  switch (error.code) {
    case 'UNAUTHENTICATED':
      authStore.logout();
      goto('/login');
      break;

    case 'PERMISSION_DENIED':
      notificationStore.error('You do not have permission for this action');
      break;

    case 'NOT_FOUND':
      notificationStore.error('Resource not found');
      break;

    case 'INVALID_ARGUMENT':
      // Return validation errors to form
      return { validationErrors: parseValidationErrors(error) };

    default:
      notificationStore.error('An unexpected error occurred');
      console.error(error);
  }
}

// Global error boundary
// routes/+error.svelte
<script>
  import { page } from '$app/stores';
</script>

<div class="error-page">
  <h1>{$page.status}</h1>
  <p>{$page.error?.message}</p>
  <a href="/">Go Home</a>
</div>
```

---

## 15. Key Architectural Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Framework | Svelte 4 + SvelteKit | Excellent performance, less boilerplate, great DX |
| State | Svelte Stores | Native, simple, reactive, no external deps |
| API Protocol | ConnectRPC | Type-safe, matches backend, better than REST |
| Styling | UnoCSS + Design Tokens | Atomic CSS, consistent design, fast builds |
| Monorepo | Turborepo | Fast builds, smart caching, workspace deps |
| Testing | Vitest + Playwright | Fast unit tests, reliable E2E |
| Build | Vite | Fast HMR, optimized production builds |

---

## 16. Implementation Roadmap

```
Phase 1: Foundation (Weeks 1-2)
├── SvelteKit app setup
├── ConnectRPC client
├── Auth flow
└── Core stores

Phase 2: Core Modules (Weeks 3-6)
├── Identity module
├── Masters module
├── Finance module (basic)
└── Dashboard

Phase 3: Business Modules (Weeks 7-12)
├── Complete Finance
├── HR module
├── Sales module
├── Inventory module
└── Purchase module

Phase 4: Advanced Modules (Weeks 13-18)
├── Manufacturing
├── Projects
├── Workflow
└── Reporting

Phase 5: Polish (Weeks 19-20)
├── Performance optimization
├── E2E testing
├── Documentation
└── Production deployment
```

---

## Appendix: File Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Component | PascalCase | `JournalEntry.svelte` |
| Store | camelCase | `auth.store.ts` |
| API | camelCase | `finance.api.ts` |
| Types | camelCase | `journal.types.ts` |
| Utils | camelCase | `formatters.ts` |
| Routes | kebab-case | `general-ledger/` |
| Tests | `*.test.ts` | `auth.test.ts` |
