# Proto Generation Gaps — Fix & Complete All 54 Missing Protos

**Created:** 2026-03-03
**Status:** IN PROGRESS
**Goal:** 100% proto generation coverage across business/, core/, extension/

## Current State
- **Generated:** 415/469 service protos (88.5%)
- **Missing:** 54 protos across 7 root causes
- **Service factories:** 115 base factories exist, ~295 vertical factories needed

---

## ROOT CAUSES & FIXES (7 categories)

### CAUSE 1: `IGNORE_IF_UNPOPULATED` not in cached protovalidate (2 files)
**Fix:** Update local buf/validate cache OR replace `IGNORE_IF_UNPOPULATED` with `IGNORE_ALWAYS` or remove the annotation.

| # | File | Issue |
|---|------|-------|
| 1 | `core/identity/auth/proto/auth.proto` | 21 occurrences of `IGNORE_IF_UNPOPULATED` + 2 duplicate `.enum` annotations (lines 460-461, 737-738) |
| 2 | `core/identity/entity/proto/entity.proto` | 2 duplicate `.enum` annotations (lines 213-214, 233-234) |

**Note:** `apigateway.proto` has neither issue — need to re-test it separately.

### CAUSE 2: Wrong import path prefix — missing `business/` or `core/` (22 files)
**Fix:** Add the correct top-level prefix to import paths.

| # | File | Wrong Import | Correct Import |
|---|------|-------------|----------------|
| 3 | `core/identity/user/proto/permission.proto` | `identity/user/proto/role.proto` | `core/identity/user/proto/role.proto` |
| 4 | ↑ same | `identity/user/proto/user.proto` | `core/identity/user/proto/user.proto` |
| 5 | `core/identity/user/proto/permissiondef.proto` | `identity/user/proto/role.proto` | `core/identity/user/proto/role.proto` |
| 6 | `core/workflow/formbuilder/proto/formbuilder.proto` | `workflow/formbuilder/proto/form_state_machine.proto` | `core/workflow/formbuilder/proto/form_state_machine.proto` |
| 7 | ↑ same | `platform/sla/proto/sla.proto` | `core/platform/sla/proto/sla.proto` |
| 8 | ↑ same | `workflow/escalation/proto/escalation.proto` | `core/workflow/escalation/proto/escalation.proto` |
| 9 | `business/finance/costcenter/proto/agriculture/costcenter_agriculture.proto` | `finance/costcenter/proto/costcenter.proto` | `business/finance/costcenter/proto/costcenter.proto` |
| 10 | `business/finance/costcenter/proto/mfgvertical/costcenter_mfgvertical.proto` | `finance/costcenter/proto/costcenter.proto` | `business/finance/costcenter/proto/costcenter.proto` |
| 11 | `business/finance/ledger/proto/balance.proto` | `finance/ledger/proto/common.proto` | `business/finance/ledger/proto/common.proto` |
| 12 | `business/finance/ledger/proto/period.proto` | `finance/ledger/proto/common.proto` | `business/finance/ledger/proto/common.proto` |
| 13 | `business/finance/reports/proto/reports.proto` | `finance/ledger/proto/common.proto` | `business/finance/ledger/proto/common.proto` |
| 14 | `business/purchase/procurement/proto/agriculture/procurement_agriculture.proto` | `purchase/procurement/proto/procurement.proto` | `business/purchase/procurement/proto/procurement.proto` |
| 15 | `business/purchase/procurement/proto/mfgvertical/procurement_mfgvertical.proto` | `purchase/procurement/proto/procurement.proto` | `business/purchase/procurement/proto/procurement.proto` |
| 16 | `business/purchase/procurement/proto/solar/procurement_solar.proto` | `purchase/procurement/proto/procurement.proto` | `business/purchase/procurement/proto/procurement.proto` |
| 17 | `business/purchase/purchaseinvoice/proto/agriculture/purchaseinvoice_agriculture.proto` | `purchase/purchaseinvoice/proto/purchaseinvoice.proto` | `business/purchase/purchaseinvoice/proto/purchaseinvoice.proto` |
| 18 | `business/purchase/purchaseinvoice/proto/mfgvertical/purchaseinvoice_mfgvertical.proto` | `purchase/purchaseinvoice/proto/purchaseinvoice.proto` | `business/purchase/purchaseinvoice/proto/purchaseinvoice.proto` |
| 19 | `business/purchase/purchaseinvoice/proto/solar/purchaseinvoice_solar.proto` | `purchase/purchaseinvoice/proto/purchaseinvoice.proto` | `business/purchase/purchaseinvoice/proto/purchaseinvoice.proto` |
| 20 | `business/purchase/purchaseorder/proto/agriculture/purchaseorder_agriculture.proto` | `purchase/purchaseorder/proto/purchaseorder.proto` | `business/purchase/purchaseorder/proto/purchaseorder.proto` |
| 21 | `business/purchase/purchaseorder/proto/mfgvertical/purchaseorder_mfgvertical.proto` | `purchase/purchaseorder/proto/purchaseorder.proto` | `business/purchase/purchaseorder/proto/purchaseorder.proto` |
| 22 | `business/purchase/purchaseorder/proto/solar/purchaseorder_solar.proto` | `purchase/purchaseorder/proto/purchaseorder.proto` | `business/purchase/purchaseorder/proto/purchaseorder.proto` |
| 23 | `business/fulfillment/returns/proto/agriculture/returns_agriculture.proto` | `fulfillment/returns/proto/returns.proto` | `business/fulfillment/returns/proto/returns.proto` |
| 24 | `business/fulfillment/returns/proto/construction/returns_construction.proto` | `fulfillment/returns/proto/returns.proto` | `business/fulfillment/returns/proto/returns.proto` |
| 25 | `business/fulfillment/returns/proto/mfgvertical/returns_mfgvertical.proto` | `fulfillment/returns/proto/returns.proto` | `business/fulfillment/returns/proto/returns.proto` |
| 26 | `business/fulfillment/returns/proto/solar/returns_solar.proto` | `fulfillment/returns/proto/returns.proto` | `business/fulfillment/returns/proto/returns.proto` |
| 27 | `business/fulfillment/returns/proto/water/returns_water.proto` | `fulfillment/returns/proto/returns.proto` | `business/fulfillment/returns/proto/returns.proto` |
| 28 | `business/fulfillment/shipping/proto/agriculture/shipping_agriculture.proto` | `fulfillment/shipping/proto/shipping.proto` | `business/fulfillment/shipping/proto/shipping.proto` |
| 29 | `business/fulfillment/shipping/proto/construction/shipping_construction.proto` | `fulfillment/shipping/proto/shipping.proto` | `business/fulfillment/shipping/proto/shipping.proto` |
| 30 | `business/fulfillment/shipping/proto/mfgvertical/shipping_mfgvertical.proto` | `fulfillment/shipping/proto/shipping.proto` | `business/fulfillment/shipping/proto/shipping.proto` |
| 31 | `business/fulfillment/shipping/proto/solar/shipping_solar.proto` | `fulfillment/shipping/proto/shipping.proto` | `business/fulfillment/shipping/proto/shipping.proto` |
| 32 | `business/fulfillment/shipping/proto/water/shipping_water.proto` | `fulfillment/shipping/proto/shipping.proto` | `business/fulfillment/shipping/proto/shipping.proto` |
| 33 | `business/fulfillment/fulfillment/proto/agriculture/fulfillment_agriculture.proto` | `fulfillment/fulfillment/proto/fulfillment.proto` | `business/fulfillment/fulfillment/proto/fulfillment.proto` (ALSO: base file doesn't exist — see CAUSE 3) |
| 34-37 | fulfillment/fulfillment construction/mfgvertical/solar/water | same pattern | same fix + CAUSE 3 |

### CAUSE 3: Missing base fulfillment.proto (1 missing file, 5 dependents)
**Fix:** Create `business/fulfillment/fulfillment/proto/fulfillment.proto` as an empty base proto with shared types that vertical protos import.

Files affected: All 5 vertical fulfillment protos (agriculture, construction, mfgvertical, solar, water)

### CAUSE 4: Wrong field_options package reference (2 base + 10 cascade)
**Fix:** Replace `(packages.api.v1.field_options.metadata)` with `(packages.api.v1.options.metadata)` in:

| # | File |
|---|------|
| 38 | `business/fulfillment/returns/proto/returns.proto` |
| 39 | `business/fulfillment/shipping/proto/shipping.proto` |

### CAUSE 5: Unicode `ā` in package name (4 files)
**Fix:** Replace `Samavāya` with `Samavaya` in the `package` declaration.

| # | File |
|---|------|
| 40 | `business/finance/journal/proto/constructionvertical/journal_constructionvertical.proto` |
| 41 | `business/finance/journal/proto/workvertical/journal_workvertical.proto` |
| 42 | `business/inventory/core/proto/constructionvertical/inventory_constructionvertical.proto` |
| 43 | `business/inventory/core/proto/workvertical/inventory_workvertical.proto` |

### CAUSE 6: Duplicate field number (1 file)
**Fix:** Change field number from `2` to `4` for `tasks` field.

| # | File | Line | Fix |
|---|------|------|-----|
| 44 | `business/sales/routeplanning/proto/water/routeplanning_water.proto` | 77 | `repeated MaintenanceTask tasks = 2;` → `repeated MaintenanceTask tasks = 4;` (also renumber work_date to 5) |

### CAUSE 7: `kosha.data.Timestamp` not defined (12 files)
**Fix:** Add `Timestamp` message to `packages/proto/data.proto` (currently only has DynamicValue + DynamicValueFilter). The extension/land protos import `packages/proto/data.proto` and use `kosha.data.Timestamp`. We need to add the type there.

All 12 extension/land protos:

| # | File |
|---|------|
| 45 | `extension/land/compliance/proto/compliance.proto` |
| 46 | `extension/land/due-diligence/proto/due_diligence.proto` |
| 47 | `extension/land/field-ops/proto/field_ops.proto` |
| 48 | `extension/land/gis-spatial/proto/gis_spatial.proto` |
| 49 | `extension/land/land-finance/proto/land_finance.proto` |
| 50 | `extension/land/land-insights/proto/land_insights.proto` |
| 51 | `extension/land/land-parcel/proto/land_parcel.proto` |
| 52 | `extension/land/land-workflow-orchestrator/proto/land_workflow.proto` |
| 53 | `extension/land/legal-case/proto/legal_case.proto` |
| 54 | `extension/land/negotiation/proto/negotiation.proto` |
| 55 | `extension/land/risk-scoring/proto/risk_scoring.proto` |
| 56 | `extension/land/stakeholder/proto/stakeholder.proto` |

---

## EXECUTION ORDER

1. **CAUSE 7** — Add `Timestamp` to `packages/proto/data.proto` (1 file change, unblocks 12)
2. **CAUSE 1** — Fix `IGNORE_IF_UNPOPULATED` + duplicate enum in auth.proto, entity.proto (2 files)
3. **CAUSE 2** — Fix import paths in 22 files (simple find/replace per file)
4. **CAUSE 3** — Create base fulfillment.proto (1 new file)
5. **CAUSE 4** — Fix field_options package in returns.proto, shipping.proto (2 files)
6. **CAUSE 5** — Fix Unicode in 4 package declarations
7. **CAUSE 6** — Fix duplicate field number in routeplanning_water.proto (1 file)
8. **Re-run** `generate.sh` and verify all 469 succeed
9. **Add** service factories for newly generated protos
10. **Typecheck** to confirm zero errors

## AFTER GENERATION: SERVICE FACTORIES NEEDED

### Missing core factories (11 services):
- GDPRService, RetentionService, I18nService
- BatchService, PrintService, QueueService, WebhookService, SystemSettingsService
- FormBuilder: ApprovalService, FormInstanceService, FormStateMachineService

### Extension factories (12 services):
- All land/ services need a new `extension.ts` factory file

### Vertical factories (~284 services):
- Agriculture, MfgVertical, Solar, Water, Construction variants for all business modules
- Currently only masters has vertical factories

---

## RESUME INSTRUCTIONS

If session ends, start here:
1. Check which CAUSE fixes have been applied (grep for the old patterns)
2. Continue with next unfixed CAUSE
3. After all fixes, run `cd e:/Brahma/Samavāya/web/packages/proto && bash generate.sh`
4. Check output count — should be ~555+54 = ~609 TypeScript files
5. Run `cd e:/Brahma/Samavāya/web/packages/api && pnpm exec tsc --noEmit`
