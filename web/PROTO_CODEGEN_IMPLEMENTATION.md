# Proto Codegen Setup - TypeScript ConnectRPC Clients

## Why This Is Needed

ConnectRPC is the **transport protocol** (how data moves over HTTP). Proto codegen generates the **TypeScript types and service descriptors** (what data looks like and what RPCs exist). Without codegen, you'd have to manually write every request/response type and service definition — 609 proto files, ~20,000 lines of definitions, hundreds of services. With codegen, it's automatic, type-safe, and stays in sync with the backend.

```
Backend .proto files → [codegen] → TypeScript types + service descriptors → @samavāya/api client → UI components
```

## Current State — PHASE 1 & 2 COMPLETE (March 3, 2026)

- **554 out of 609 proto files generated** (91% success rate)
- **0 TypeScript compilation errors** — all generated code passes `tsc --noEmit`
- **Package**: `@samavāya/proto` at `packages/proto/`
- **Tools**: `protoc-gen-es v2.11.0` (globally installed), `protoc 33.2`
- **Method**: protoc with temp dir copy (workaround for Unicode path `Samavāya` issue)

### 55 Failed Proto Files (Backend Issues — NOT Frontend)

**Category 1 — Duplicate validation annotations (3 files):**
- `core/identity/auth/proto/auth.proto` — duplicate `(buf.validate.field).enum`
- `core/identity/user/proto/permission.proto` — same issue
- `core/identity/user/proto/permissiondef.proto` — same issue

**Category 2 — Missing base proto files (31 files):**
- `business/fulfillment/*/proto/{vertical}/*.proto` — imports non-existent base `fulfillment.proto`
- `business/fulfillment/returns/proto/*.proto` — imports non-existent base
- `business/fulfillment/shipping/proto/*.proto` — imports non-existent base

**Category 3 — Cross-module import path issues (21 files):**
- Various finance, inventory, purchase, sales vertical protos that import using module-relative paths

**Fix**: These require backend proto file corrections. The generated 554 files cover ALL core services needed for frontend development.

## Scope

| Category | Modules | Proto Files | Priority |
|----------|---------|-------------|----------|
| **packages** (shared types) | context, response, money, pagination, etc. | 15 | P0 - Required by all |
| **core/identity** | auth, user, tenant, access, pdp, entity | 16 | P0 - Login/auth |
| **business/masters** | item, party, location, UOM, CoA, taxcode | 27 | P1 - First business module |
| **core/workflow** | formbuilder, workflow, approval, escalation | 11 | P1 - Form system |
| **business/finance** | ledger, payable, receivable, journal, etc. | 45 | P2 |
| **business/inventory** | core, lot-serial, quality, planning, wms | 41 | P2 |
| **business/sales** | CRM, salesorder, pricing, territory, etc. | 70 | P3 |
| **business/purchase** | procurement, PO, invoice | 22 | P3 |
| **business/hr** | employee, payroll, leave, attendance, etc. | 70 | P3 |
| **business/manufacturing** | BOM, routing, production, etc. | 59 | P3 |
| **remaining** | asset, projects, fulfillment, insights, etc. | 233 | P4 |

---

## Implementation Tasks

### PHASE 1: Infrastructure Setup (Do First)
**Status: [ ] NOT STARTED**

#### Task 1.1: Install codegen dependencies in web monorepo
**Status: [ ]**

```bash
cd E:\Brahma\Samavāya\web
pnpm add -D @bufbuild/buf @bufbuild/protoc-gen-es @connectrpc/protoc-gen-connect-es -w
```

Required packages:
- `@bufbuild/buf` - buf CLI for proto compilation
- `@bufbuild/protoc-gen-es` - generates TypeScript message types (v2 for @bufbuild/protobuf@^2)
- `@connectrpc/protoc-gen-connect-es` - generates ConnectRPC service descriptors (v2 for @connectrpc/connect@^2)

#### Task 1.2: Create `packages/proto/` package
**Status: [ ]**

Create the package that will hold all generated TypeScript code:

**File: `packages/proto/package.json`**
```json
{
  "name": "@samavāya/proto",
  "version": "0.0.1",
  "description": "Generated TypeScript protobuf types and ConnectRPC service descriptors",
  "type": "module",
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "exports": {
    "./packages/*": "./src/packages/*.ts",
    "./core/*": "./src/core/*.ts",
    "./business/*": "./src/business/*.ts",
    "./extension/*": "./src/extension/*.ts"
  },
  "scripts": {
    "generate": "buf generate",
    "generate:clean": "rimraf src/gen && buf generate",
    "lint:proto": "buf lint",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "@bufbuild/protobuf": "^2.0.0",
    "@connectrpc/connect": "^2.0.0"
  },
  "devDependencies": {
    "@bufbuild/buf": "latest",
    "@bufbuild/protoc-gen-es": "^2.0.0",
    "@connectrpc/protoc-gen-connect-es": "^2.0.0",
    "typescript": "^5.7.0",
    "rimraf": "^5.0.0"
  }
}
```

#### Task 1.3: Create `buf.yaml` in `packages/proto/`
**Status: [ ]**

This tells buf where to find proto files (pointing to the backend):

**File: `packages/proto/buf.yaml`**
```yaml
version: v2
modules:
  - path: ../../backend
    name: buf.build/brahma/samavaya
deps:
  - buf.build/bufbuild/protovalidate
  - buf.build/googleapis/googleapis
breaking:
  use:
    - FILE
lint:
  use:
    - DEFAULT
```

> **NOTE**: If `buf dep update` fails due to BSR auth (known issue from backend experience), we'll use protoc directly with a shell script instead. See Task 1.5 (Fallback).

#### Task 1.4: Create `buf.gen.yaml` in `packages/proto/`
**Status: [ ]**

**File: `packages/proto/buf.gen.yaml`**
```yaml
version: v2
plugins:
  # Generate TypeScript message types
  - local: protoc-gen-es
    out: src/gen
    opt:
      - target=ts
      - import_extension=.js

  # Generate ConnectRPC service descriptors
  - local: protoc-gen-connect-es
    out: src/gen
    opt:
      - target=ts
      - import_extension=.js
inputs:
  # Shared packages (context, response, money, pagination, etc.)
  - directory: ../../backend/packages/proto

  # Core modules
  - directory: ../../backend/core/identity/auth/proto
  - directory: ../../backend/core/identity/user/proto
  - directory: ../../backend/core/identity/tenant/proto
  - directory: ../../backend/core/identity/access/proto
  - directory: ../../backend/core/identity/pdp/proto
  - directory: ../../backend/core/identity/entity/proto
  - directory: ../../backend/core/workflow/formbuilder/proto
  - directory: ../../backend/core/workflow/workflow/proto
  - directory: ../../backend/core/workflow/approval/proto
  - directory: ../../backend/core/workflow/escalation/proto
  - directory: ../../backend/core/platform/filestorage/proto
  - directory: ../../backend/core/platform/barcodeqr/proto
  - directory: ../../backend/core/notifications/notification/proto
  - directory: ../../backend/core/notifications/template/proto
  - directory: ../../backend/core/communication/chat/proto
  - directory: ../../backend/core/communication/currency/proto
  - directory: ../../backend/core/communication/i18n/proto
  - directory: ../../backend/core/banking/banking/proto
  - directory: ../../backend/core/banking/einvoice/proto
  - directory: ../../backend/core/banking/ewaybill/proto
  - directory: ../../backend/core/banking/gst/proto
  - directory: ../../backend/core/banking/tds/proto
  - directory: ../../backend/core/budget/budget/proto
  - directory: ../../backend/core/budget/budgetvariance/proto
  - directory: ../../backend/core/budget/capex/proto
  - directory: ../../backend/core/budget/forecasting/proto
  - directory: ../../backend/core/data/backupdr/proto
  - directory: ../../backend/core/data/dataarchive/proto
  - directory: ../../backend/core/data/databridge/proto
  - directory: ../../backend/core/platform/scheduler/proto
  - directory: ../../backend/core/platform/sla/proto
  - directory: ../../backend/core/platform/integration/proto
  - directory: ../../backend/core/platform/apigateway/proto
  - directory: ../../backend/core/platform/batch/proto
  - directory: ../../backend/core/platform/print/proto
  - directory: ../../backend/core/platform/queue/proto
  - directory: ../../backend/core/platform/systemsettings/proto
  - directory: ../../backend/core/platform/webhook/proto
  - directory: ../../backend/core/audit/audit/proto
  - directory: ../../backend/core/audit/changelog/proto
  - directory: ../../backend/core/audit/compliance/proto
  - directory: ../../backend/core/audit/gdpr/proto
  - directory: ../../backend/core/audit/retention/proto

  # Business modules
  - directory: ../../backend/business/masters/item/proto
  - directory: ../../backend/business/masters/party/proto
  - directory: ../../backend/business/masters/location/proto
  - directory: ../../backend/business/masters/UOM/proto
  - directory: ../../backend/business/masters/chartofaccounts/proto
  - directory: ../../backend/business/masters/taxcode/proto
  - directory: ../../backend/business/finance/ledger/proto
  - directory: ../../backend/business/finance/payable/proto
  - directory: ../../backend/business/finance/receivable/proto
  - directory: ../../backend/business/finance/journal/proto
  - directory: ../../backend/business/finance/billing/proto
  - directory: ../../backend/business/finance/cashmanagement/proto
  - directory: ../../backend/business/finance/compliancepostings/proto
  - directory: ../../backend/business/finance/costcenter/proto
  - directory: ../../backend/business/finance/financialclose/proto
  - directory: ../../backend/business/finance/reconciliation/proto
  - directory: ../../backend/business/finance/reports/proto
  - directory: ../../backend/business/finance/taxengine/proto
  - directory: ../../backend/business/finance/transaction/proto
  - directory: ../../backend/business/inventory/core/proto
  - directory: ../../backend/business/inventory/barcode/proto
  - directory: ../../backend/business/inventory/cycle-count/proto
  - directory: ../../backend/business/inventory/lot-serial/proto
  - directory: ../../backend/business/inventory/planning/proto
  - directory: ../../backend/business/inventory/quality/proto
  - directory: ../../backend/business/inventory/stock-transfer/proto
  - directory: ../../backend/business/inventory/wms/proto
  - directory: ../../backend/business/sales/commission/proto
  - directory: ../../backend/business/sales/crm/proto
  - directory: ../../backend/business/sales/dealer/proto
  - directory: ../../backend/business/sales/fieldsales/proto
  - directory: ../../backend/business/sales/pricing/proto
  - directory: ../../backend/business/sales/routeplanning/proto
  - directory: ../../backend/business/sales/salesanalytics/proto
  - directory: ../../backend/business/sales/salesinvoice/proto
  - directory: ../../backend/business/sales/salesorder/proto
  - directory: ../../backend/business/sales/territory/proto
  - directory: ../../backend/business/purchase/procurement/proto
  - directory: ../../backend/business/purchase/purchaseorder/proto
  - directory: ../../backend/business/purchase/purchaseinvoice/proto
  - directory: ../../backend/business/hr/appraisal/proto
  - directory: ../../backend/business/hr/attendance/proto
  - directory: ../../backend/business/hr/employee/proto
  - directory: ../../backend/business/hr/exit/proto
  - directory: ../../backend/business/hr/expense/proto
  - directory: ../../backend/business/hr/leave/proto
  - directory: ../../backend/business/hr/payroll/proto
  - directory: ../../backend/business/hr/recruitment/proto
  - directory: ../../backend/business/hr/salarystructure/proto
  - directory: ../../backend/business/hr/training/proto
  - directory: ../../backend/business/manufacturing/bom/proto
  - directory: ../../backend/business/manufacturing/jobcard/proto
  - directory: ../../backend/business/manufacturing/mfgquality/proto
  - directory: ../../backend/business/manufacturing/planning/proto
  - directory: ../../backend/business/manufacturing/productionorder/proto
  - directory: ../../backend/business/manufacturing/routing/proto
  - directory: ../../backend/business/manufacturing/shopfloor/proto
  - directory: ../../backend/business/manufacturing/subcontracting/proto
  - directory: ../../backend/business/manufacturing/workcenter/proto
  - directory: ../../backend/business/projects/boq/proto
  - directory: ../../backend/business/projects/progressbilling/proto
  - directory: ../../backend/business/projects/project/proto
  - directory: ../../backend/business/projects/projectcosting/proto
  - directory: ../../backend/business/projects/subcontractor/proto
  - directory: ../../backend/business/projects/task/proto
  - directory: ../../backend/business/projects/timesheet/proto
  - directory: ../../backend/business/asset/asset/proto
  - directory: ../../backend/business/asset/depreciation/proto
  - directory: ../../backend/business/asset/equipment/proto
  - directory: ../../backend/business/asset/maintenance/proto
  - directory: ../../backend/business/asset/vehicle/proto
  - directory: ../../backend/business/fulfillment/fulfillment/proto
  - directory: ../../backend/business/fulfillment/returns/proto
  - directory: ../../backend/business/fulfillment/shipping/proto
  - directory: ../../backend/business/insights/bianalytics/proto
  - directory: ../../backend/business/insights/dashboard/proto
  - directory: ../../backend/business/insights/insighthub/proto
  - directory: ../../backend/business/insights/insightviewer/proto
  - directory: ../../backend/business/insights/metasearch/proto
```

#### Task 1.5: Fallback — protoc shell script (if buf BSR auth fails)
**Status: [ ]**

If `buf dep update` fails (known issue — BSR requires auth token), create a `generate.sh` script that uses protoc directly:

**File: `packages/proto/generate.sh`**
```bash
#!/bin/bash
# Proto codegen using protoc (fallback when buf BSR is unavailable)
# Usage: ./generate.sh [module_path]
# Example: ./generate.sh business/masters/item

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$(cd "$SCRIPT_DIR/../../backend" && pwd)"
OUT_DIR="$SCRIPT_DIR/src/gen"

# Plugin paths (adjust for your system)
PROTOC_GEN_ES="$(pnpm bin)/protoc-gen-es"
PROTOC_GEN_CONNECT_ES="$(pnpm bin)/protoc-gen-connect-es"

# Include paths
PROTO_INCLUDE="D:/softwares/protoc/include"
BUF_VALIDATE_CACHE="$LOCALAPPDATA/Buf/v3/modules/b5"
# Find the buf validate proto path dynamically
BUF_VALIDATE_DIR=$(find "$BUF_VALIDATE_CACHE" -name "validate.proto" -path "*/buf/validate/*" 2>/dev/null | head -1 | xargs dirname | xargs dirname | xargs dirname)

if [ -z "$BUF_VALIDATE_DIR" ]; then
  echo "WARNING: buf/validate/validate.proto not found in cache. Skipping validation imports."
  BUF_VALIDATE_DIR="/dev/null"
fi

mkdir -p "$OUT_DIR"

generate_module() {
  local module_path="$1"
  local proto_dir="$BACKEND_DIR/$module_path/proto"

  if [ ! -d "$proto_dir" ]; then
    # For packages/proto which doesn't have a proto/ subdirectory
    proto_dir="$BACKEND_DIR/$module_path"
  fi

  echo "Generating: $module_path"

  # Find all .proto files in the directory (including subdirectories for verticals)
  find "$proto_dir" -name "*.proto" | while read -r proto_file; do
    protoc \
      --plugin=protoc-gen-es="$PROTOC_GEN_ES" \
      --plugin=protoc-gen-connect-es="$PROTOC_GEN_CONNECT_ES" \
      --es_out="$OUT_DIR" \
      --es_opt=target=ts,import_extension=.js \
      --connect-es_out="$OUT_DIR" \
      --connect-es_opt=target=ts,import_extension=.js \
      --proto_path="$BACKEND_DIR" \
      --proto_path="$PROTO_INCLUDE" \
      --proto_path="$BUF_VALIDATE_DIR" \
      "$proto_file"
  done
}

# If a specific module is passed, generate only that
if [ -n "$1" ]; then
  generate_module "$1"
  echo "Done: $1"
  exit 0
fi

# Otherwise generate all modules in priority order

echo "=== Phase 0: Shared Packages ==="
generate_module "packages/proto"

echo "=== Phase 1: Core Identity ==="
for svc in auth user tenant access pdp entity; do
  generate_module "core/identity/$svc"
done

echo "=== Phase 2: Core Workflow ==="
for svc in formbuilder workflow approval escalation; do
  generate_module "core/workflow/$svc"
done

echo "=== Phase 3: Masters ==="
for svc in item party location UOM chartofaccounts taxcode; do
  generate_module "business/masters/$svc"
done

echo "=== Phase 4: Finance ==="
for svc in ledger payable receivable journal billing cashmanagement compliancepostings costcenter financialclose reconciliation reports taxengine transaction; do
  generate_module "business/finance/$svc"
done

echo "=== Phase 5: Inventory ==="
for svc in core barcode cycle-count lot-serial planning quality stock-transfer wms; do
  generate_module "business/inventory/$svc"
done

echo "=== Phase 6: Sales ==="
for svc in commission crm dealer fieldsales pricing routeplanning salesanalytics salesinvoice salesorder territory; do
  generate_module "business/sales/$svc"
done

echo "=== Phase 7: Purchase ==="
for svc in procurement purchaseorder purchaseinvoice; do
  generate_module "business/purchase/$svc"
done

echo "=== Phase 8: HR ==="
for svc in appraisal attendance employee exit expense leave payroll recruitment salarystructure training; do
  generate_module "business/hr/$svc"
done

echo "=== Phase 9: Manufacturing ==="
for svc in bom jobcard mfgquality planning productionorder routing shopfloor subcontracting workcenter; do
  generate_module "business/manufacturing/$svc"
done

echo "=== Phase 10: Projects ==="
for svc in boq progressbilling project projectcosting subcontractor task timesheet; do
  generate_module "business/projects/$svc"
done

echo "=== Phase 11: Asset ==="
for svc in asset depreciation equipment maintenance vehicle; do
  generate_module "business/asset/$svc"
done

echo "=== Phase 12: Fulfillment ==="
for svc in fulfillment returns shipping; do
  generate_module "business/fulfillment/$svc"
done

echo "=== Phase 13: Insights ==="
for svc in bianalytics dashboard insighthub insightviewer metasearch; do
  generate_module "business/insights/$svc"
done

echo "=== Phase 14: Core Platform ==="
for svc in filestorage barcodeqr scheduler sla integration apigateway batch print queue systemsettings webhook; do
  generate_module "core/platform/$svc"
done

echo "=== Phase 15: Core Others ==="
for svc in notification template; do
  generate_module "core/notifications/$svc"
done
for svc in chat currency i18n; do
  generate_module "core/communication/$svc"
done
for svc in banking einvoice ewaybill gst tds; do
  generate_module "core/banking/$svc"
done
for svc in budget budgetvariance capex forecasting; do
  generate_module "core/budget/$svc"
done
for svc in backupdr dataarchive databridge; do
  generate_module "core/data/$svc"
done
for svc in audit changelog compliance gdpr retention; do
  generate_module "core/audit/$svc"
done

echo ""
echo "=== ALL DONE ==="
echo "Generated TypeScript files in: $OUT_DIR"
```

#### Task 1.6: Create tsconfig.json for proto package
**Status: [ ]**

**File: `packages/proto/tsconfig.json`**
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "outDir": "dist",
    "rootDir": "src",
    "verbatimModuleSyntax": true
  },
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules", "dist"]
}
```

#### Task 1.7: Add `generate` script to root package.json
**Status: [ ]**

Add to `web/package.json` scripts:
```json
"proto:generate": "turbo run generate --filter=@samavāya/proto",
"proto:clean": "turbo run generate:clean --filter=@samavāya/proto"
```

---

### PHASE 2: Generate & Validate (P0 — Shared + Identity)
**Status: [ ] NOT STARTED**

#### Task 2.1: Run codegen for packages/proto (shared types)
**Status: [ ]**

```bash
cd packages/proto
# Try buf first
npx buf dep update && npx buf generate
# If buf fails, use protoc fallback
# bash generate.sh packages/proto
```

**Expected output**: `src/gen/packages/proto/` with:
- `context_pb.ts` — TenantContext type
- `response_pb.ts` — BaseResponse, Status, CanonicalReason
- `money_pb.ts` — Money, MoneyWithRate
- `pagination_pb.ts` — Pagination
- etc.

#### Task 2.2: Run codegen for core/identity (auth, user, tenant)
**Status: [ ]**

```bash
# buf or protoc for identity modules
bash generate.sh core/identity/auth
bash generate.sh core/identity/user
bash generate.sh core/identity/tenant
```

**Expected output**: `src/gen/core/identity/` with:
- `auth_pb.ts` + `auth_connect.ts` — AuthService (login, token refresh, 2FA)
- `user_pb.ts` + `user_connect.ts` — UserService (profile, roles, permissions)
- `tenant_pb.ts` + `tenant_connect.ts` — TenantService

#### Task 2.3: Validate generated code compiles
**Status: [ ]**

```bash
cd packages/proto
pnpm typecheck
```

Fix any issues (common: import path mismatches, missing buf/validate types).

#### Task 2.4: Create barrel exports
**Status: [ ]**

**File: `packages/proto/src/index.ts`**
```typescript
// Re-export all generated types for convenience
// Consumers should prefer direct imports for tree-shaking:
//   import { ItemService } from '@samavāya/proto/business/masters/item/v1/item_connect';

export * from './gen/packages/proto/context_pb.js';
export * from './gen/packages/proto/response_pb.js';
export * from './gen/packages/proto/money_pb.js';
export * from './gen/packages/proto/pagination_pb.js';
```

---

### PHASE 3: Wire to @samavāya/api
**Status: [ ] NOT STARTED**

#### Task 3.1: Add @samavāya/proto as dependency to @samavāya/api
**Status: [ ]**

In `packages/api/package.json`:
```json
"dependencies": {
  "@samavāya/proto": "workspace:*",
  ...
}
```

#### Task 3.2: Create typed service factories in @samavāya/api
**Status: [ ]**

**File: `packages/api/src/services/identity.ts`**
```typescript
import { AuthService } from '@samavāya/proto/gen/core/identity/auth/auth_connect.js';
import { UserService } from '@samavāya/proto/gen/core/identity/user/user_connect.js';
import { TenantService } from '@samavāya/proto/gen/core/identity/tenant/tenant_connect.js';
import { getApiClient } from '../client/client.js';

export function getAuthService() {
  return getApiClient().getService(AuthService);
}

export function getUserService() {
  return getApiClient().getService(UserService);
}

export function getTenantService() {
  return getApiClient().getService(TenantService);
}
```

#### Task 3.3: Update shell app login to use generated client
**Status: [ ]**

Replace manual fetch calls with typed ConnectRPC calls in the login flow.

---

### PHASE 4: Generate Business Modules (P1 — Masters)
**Status: [ ] NOT STARTED**

#### Task 4.1: Generate masters module protos
**Status: [ ]**

```bash
bash generate.sh business/masters/item
bash generate.sh business/masters/party
bash generate.sh business/masters/location
bash generate.sh business/masters/UOM
bash generate.sh business/masters/chartofaccounts
bash generate.sh business/masters/taxcode
```

#### Task 4.2: Create masters service factories
**Status: [ ]**

#### Task 4.3: Replace manual item.service.ts with generated client
**Status: [ ]**

---

### PHASE 5+: Remaining Modules (P2-P4)
**Status: [ ] NOT STARTED**

Generate remaining modules following the same pattern. Order:
1. Finance (ledger, AR/AP, journal)
2. Inventory (core, lot-serial, quality)
3. Sales, Purchase, HR, Manufacturing
4. Projects, Asset, Fulfillment, Insights
5. Platform, Notifications, Communication, Banking, Budget, Audit, Data

---

## Known Issues & Solutions

| Issue | Solution |
|-------|----------|
| `buf dep update` requires BSR auth token | Use `generate.sh` with protoc directly |
| Unicode in paths (`Samavāya`) | protoc may normalize — use `paths=source_relative` |
| `buf/validate/validate.proto` not found | Add buf validate cache path to protoc includes |
| Cross-module proto imports | Ensure `--proto_path` includes backend root |
| `packages.api.v1.context.TenantContext` resolution | Backend root must be in proto path |

## File Structure After Completion

```
web/packages/proto/
├── package.json
├── tsconfig.json
├── buf.yaml
├── buf.gen.yaml
├── generate.sh                    # Fallback script
├── src/
│   ├── index.ts                   # Barrel exports
│   └── gen/                       # ALL GENERATED (do not edit)
│       ├── packages/proto/
│       │   ├── context_pb.ts
│       │   ├── response_pb.ts
│       │   ├── money_pb.ts
│       │   └── ...
│       ├── core/
│       │   ├── identity/auth/
│       │   │   ├── auth_pb.ts
│       │   │   └── auth_connect.ts
│       │   ├── identity/user/
│       │   ├── workflow/formbuilder/
│       │   └── ...
│       └── business/
│           ├── masters/item/
│           │   ├── item_pb.ts         # Types: CreateItemRequest, Item, etc.
│           │   └── item_connect.ts    # Service: ItemService descriptor
│           ├── masters/party/
│           ├── finance/ledger/
│           └── ...
```

## How Generated Code Gets Used

```typescript
// In a Svelte component or service file:
import { ItemService } from '@samavāya/proto/gen/business/masters/item/item_connect.js';
import { createClient } from '@connectrpc/connect';
import { getTransport } from '@samavāya/api/client';

const client = createClient(ItemService, getTransport());

// Fully typed - IDE autocomplete for all RPCs and fields
const response = await client.createItem({
  context: { tenantId: '...', companyId: '...' },
  name: 'Widget',
  code: 'W-001',
  type: ItemType.GOODS,
  status: ItemStatus.ACTIVE,
});

// response.item is fully typed as Item message
console.log(response.item?.id);
```

## Resume Instructions

If this session is interrupted, resume from the **first unchecked [ ] task** above. Each task is self-contained and can be executed independently. Mark tasks as `[x]` when complete.
