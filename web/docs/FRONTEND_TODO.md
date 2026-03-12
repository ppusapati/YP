# samavāya ERP Frontend - Comprehensive Todo List

## Project Overview
- **Backend Stack:** Golang, Protobuf, PostgreSQL, ConnectRPC
- **Frontend Stack:** Svelte 4, SvelteKit, TypeScript, UnoCSS, Turborepo
- **Structure:** Monorepo with modules mirroring backend microservices

---

## Phase 1: Foundation & Infrastructure

### 1.1 Core Setup
- [ ] Create SvelteKit application in `apps/web/`
- [ ] Configure routing structure
- [ ] Setup ConnectRPC client with code generation from protobuf
- [ ] Configure authentication interceptors
- [ ] Setup tenant context interceptors
- [ ] Configure error handling interceptors
- [ ] Setup environment configuration (dev, staging, prod)

### 1.2 State Management
- [ ] Create global store architecture
- [ ] Implement auth store (user, tokens, permissions)
- [ ] Implement tenant store (current tenant, settings)
- [ ] Implement notification store (toasts, alerts)
- [ ] Implement theme store (light/dark mode)
- [ ] Create store factory for module-level stores

### 1.3 API Client Layer
- [ ] Setup ConnectRPC code generation pipeline
- [ ] Create base API client with interceptors
- [ ] Implement request/response type definitions
- [ ] Setup API error handling utilities
- [ ] Create API hooks/utilities for Svelte components

---

## Phase 2: Module Implementation

### 2.1 Identity Module (`modules/identity/`)
| Service | Features | Priority |
|---------|----------|----------|
| **auth** | Login, logout, password reset, MFA, session management | P0 |
| **access** | Role management, permission assignment, access control UI | P0 |
| **user** | User CRUD, profile management, user search/filter | P0 |
| **tenant** | Tenant switcher, tenant settings, tenant onboarding | P0 |
| **pdp** | Policy decision point UI, policy testing | P1 |
| **entity** | Entity type management, entity relationships | P1 |

**Components Needed:**
- [ ] LoginForm, RegisterForm, ForgotPasswordForm
- [ ] UserList, UserForm, UserProfile
- [ ] RoleList, RoleForm, PermissionMatrix
- [ ] TenantSwitcher, TenantSettings
- [ ] AccessDenied, SessionExpired pages

---

### 2.2 Workflow Module (`modules/workflow/`)
| Service | Features | Priority |
|---------|----------|----------|
| **workflow** | Workflow designer, workflow list, workflow execution | P1 |
| **approval** | Approval inbox, approval history, bulk approve/reject | P0 |
| **formbuilder** | Drag-drop form builder, form preview, field types | P1 |
| **escalation** | Escalation rules, escalation matrix, notifications | P2 |

**Components Needed:**
- [ ] WorkflowDesigner (visual node editor)
- [ ] WorkflowList, WorkflowForm
- [ ] ApprovalInbox, ApprovalDetail, ApprovalHistory
- [ ] FormBuilder, FormPreview, FieldPalette
- [ ] EscalationRules, EscalationMatrix

---

### 2.3 Notifications Module (`modules/notifications/`)
| Service | Features | Priority |
|---------|----------|----------|
| **notification** | Notification center, notification preferences, real-time updates | P0 |
| **template** | Email/SMS/Push templates, template editor, variable mapping | P1 |

**Components Needed:**
- [ ] NotificationCenter, NotificationList, NotificationItem
- [ ] NotificationPreferences, ChannelSettings
- [ ] TemplateEditor, TemplatePreview, VariableMapper
- [ ] Real-time notification integration (WebSocket/SSE)

---

### 2.4 Audit Module (`modules/audit/`)
| Service | Features | Priority |
|---------|----------|----------|
| **audit** | Audit log viewer, audit search, audit export | P1 |
| **changelog** | Change history, diff viewer, rollback UI | P1 |
| **compliance** | Compliance dashboard, compliance reports | P2 |
| **gdpr** | Data subject requests, consent management, data export | P2 |
| **retention** | Retention policies, data lifecycle management | P2 |

**Components Needed:**
- [ ] AuditLogViewer, AuditSearch, AuditExport
- [ ] ChangeHistory, DiffViewer
- [ ] ComplianceDashboard, ComplianceChecklist
- [ ] GDPRRequestList, ConsentManager
- [ ] RetentionPolicyEditor

---

### 2.5 Data Module (`modules/data/`)
| Service | Features | Priority |
|---------|----------|----------|
| **dataarchive** | Archive browser, archive restore, archive policies | P2 |
| **databridge** | Data import/export, ETL configuration, mapping UI | P1 |
| **backupdr** | Backup status, restore points, disaster recovery | P2 |

**Components Needed:**
- [ ] ArchiveBrowser, ArchiveRestore
- [ ] DataImportWizard, DataExportWizard
- [ ] MappingEditor, TransformationBuilder
- [ ] BackupDashboard, RestoreWizard

---

### 2.6 Insights Module (`modules/insights/`)
| Service | Features | Priority |
|---------|----------|----------|
| **metasearch** | Global search, advanced filters, saved searches | P0 |
| **insighthub** | Insights dashboard, KPI cards, trend analysis | P1 |
| **insightviewer** | Report viewer, chart interactions, drill-down | P1 |
| **bi-analytics** | BI dashboard builder, chart builder, data explorer | P1 |
| **dashboard** | Custom dashboards, widget library, layout editor | P1 |

**Components Needed:**
- [ ] GlobalSearch, SearchResults, AdvancedFilters
- [ ] InsightsDashboard, KPICard, TrendChart
- [ ] ReportViewer, ChartContainer, DrillDown
- [ ] DashboardBuilder, WidgetLibrary, LayoutEditor
- [ ] ChartBuilder (Line, Bar, Pie, Area, Scatter, etc.)

---

### 2.7 Platform Module (`modules/platform/`)
| Service | Features | Priority |
|---------|----------|----------|
| **scheduler** | Job scheduler, cron editor, job history | P1 |
| **batch** | Batch job management, batch execution, logs | P1 |
| **queue** | Queue monitoring, message inspection, dead letter | P2 |
| **file-storage** | File browser, upload manager, storage settings | P0 |
| **api-gateway** | API documentation, API keys, rate limits | P2 |
| **webhook** | Webhook manager, webhook logs, retry config | P1 |
| **sla** | SLA definitions, SLA monitoring, breach alerts | P2 |
| **print-service** | Print queue, print templates, printer config | P1 |
| **barcode-qr** | Barcode generator, QR generator, scanner integration | P1 |
| **system-settings** | System configuration, feature flags, defaults | P0 |

**Components Needed:**
- [ ] JobScheduler, CronEditor, JobHistory
- [ ] BatchJobList, BatchExecutionLog
- [ ] QueueMonitor, MessageInspector
- [ ] FileBrowser, FileUploader, StorageSettings
- [ ] APIDocViewer, APIKeyManager
- [ ] WebhookManager, WebhookLogs
- [ ] SLADashboard, SLAEditor
- [ ] PrintQueue, PrintTemplateEditor
- [ ] BarcodeGenerator, QRGenerator, ScannerInput
- [ ] SystemSettings, FeatureFlags

---

### 2.8 Masters Module (`modules/masters/`)
| Service | Features | Priority |
|---------|----------|----------|
| **party** | Customer/Vendor/Contact management, party search | P0 |
| **item** | Product/Service catalog, item variants, pricing | P0 |
| **location** | Location hierarchy, address management, geofencing | P0 |
| **chart-of-accounts** | COA tree, account groups, account mapping | P0 |
| **UOM** | Unit of measure, UOM conversions, UOM groups | P0 |
| **tax-code** | Tax codes, tax rates, tax rules | P0 |

**Components Needed:**
- [ ] PartyList, PartyForm, PartyDetail, PartySearch
- [ ] ItemList, ItemForm, ItemVariants, PricingEditor
- [ ] LocationTree, LocationForm, AddressEditor
- [ ] COATree, AccountForm, AccountGroupEditor
- [ ] UOMList, UOMForm, UOMConversionMatrix
- [ ] TaxCodeList, TaxCodeForm, TaxRuleEditor

---

### 2.9 Finance Module (`modules/finance/`)
| Service | Features | Priority |
|---------|----------|----------|
| **general-ledger** | GL entries, GL reports, trial balance | P0 |
| **journal** | Journal entry, journal templates, recurring journals | P0 |
| **transaction** | Transaction list, transaction detail, void/reverse | P0 |
| **accounts-receivable** | AR aging, customer statements, collections | P0 |
| **accounts-payable** | AP aging, vendor payments, payment scheduling | P0 |
| **billing** | Invoice generation, billing cycles, billing templates | P0 |
| **cash-management** | Cash position, cash forecast, bank accounts | P1 |
| **bank-reconciliation** | Bank statement import, auto-matching, reconciliation | P1 |
| **cost-center** | Cost center hierarchy, allocations, reports | P1 |
| **tax-engine** | Tax calculation, tax filing, tax reports | P1 |
| **financial-reports** | P&L, Balance Sheet, Cash Flow, custom reports | P0 |
| **financial-close** | Period close, year-end close, close checklist | P1 |
| **compliance-postings** | Compliance entries, statutory reports | P2 |

**Components Needed:**
- [ ] GLEntryList, GLReport, TrialBalance
- [ ] JournalEntry, JournalTemplate, RecurringJournalEditor
- [ ] TransactionList, TransactionDetail, VoidReverseDialog
- [ ] ARAgingReport, CustomerStatement, CollectionQueue
- [ ] APAgingReport, PaymentScheduler, VendorPayment
- [ ] InvoiceGenerator, BillingCycleEditor, InvoiceTemplate
- [ ] CashPositionDashboard, CashForecast, BankAccountManager
- [ ] BankReconciliation, StatementImporter, AutoMatcher
- [ ] CostCenterTree, AllocationEditor, CostReport
- [ ] TaxCalculator, TaxFilingWizard, TaxReport
- [ ] FinancialReportViewer, ReportBuilder
- [ ] PeriodCloseWizard, YearEndClose, CloseChecklist

---

### 2.10 HR Module (`modules/hr/`)
| Service | Features | Priority |
|---------|----------|----------|
| **employee** | Employee directory, employee profile, org chart | P0 |
| **leave** | Leave request, leave calendar, leave balance | P0 |
| **attendance** | Time tracking, attendance reports, overtime | P0 |
| **payroll** | Payroll processing, payslips, payroll reports | P1 |
| **salary-structure** | Salary components, salary templates, increments | P1 |
| **recruitment** | Job postings, applicant tracking, interview scheduling | P1 |
| **training** | Training calendar, course management, certifications | P2 |
| **appraisal** | Performance reviews, goal setting, 360 feedback | P2 |
| **expense** | Expense claims, expense approval, expense reports | P1 |
| **exit** | Exit process, exit interview, final settlement | P2 |

**Components Needed:**
- [ ] EmployeeDirectory, EmployeeProfile, OrgChart
- [ ] LeaveRequest, LeaveCalendar, LeaveBalance
- [ ] TimeTracker, AttendanceReport, OvertimeCalculator
- [ ] PayrollProcessor, PayslipViewer, PayrollReport
- [ ] SalaryStructureEditor, SalaryTemplate, IncrementWizard
- [ ] JobPostingEditor, ApplicantTracker, InterviewScheduler
- [ ] TrainingCalendar, CourseManager, CertificationTracker
- [ ] AppraisalForm, GoalSetter, FeedbackCollector
- [ ] ExpenseClaim, ExpenseApproval, ExpenseReport
- [ ] ExitWizard, ExitInterview, FinalSettlement

---

### 2.11 Purchase Module (`modules/purchase/`)
| Service | Features | Priority |
|---------|----------|----------|
| **procurement** | Procurement planning, requisitions, RFQ | P0 |
| **purchase-order** | PO creation, PO approval, PO tracking | P0 |
| **purchase-invoice** | Invoice matching, invoice processing, discrepancies | P0 |

**Components Needed:**
- [ ] ProcurementPlanner, RequisitionForm, RFQManager
- [ ] POCreator, POApproval, POTracker
- [ ] InvoiceMatcher, InvoiceProcessor, DiscrepancyHandler

---

### 2.12 Inventory Module (`modules/inventory/`)
| Service | Features | Priority |
|---------|----------|----------|
| **inventory-core** | Stock levels, stock valuation, inventory reports | P0 |
| **wms** | Warehouse layout, bin management, putaway/pick | P1 |
| **stock-transfer** | Transfer orders, inter-warehouse transfers | P0 |
| **qc** | Quality inspection, QC parameters, QC reports | P1 |
| **lot-serial** | Lot tracking, serial tracking, traceability | P1 |
| **cycle-count** | Cycle count planning, count sheets, adjustments | P1 |
| **barcode** | Barcode scanning, mobile inventory operations | P1 |
| **demand-planning** | Demand forecast, reorder planning, safety stock | P2 |

**Components Needed:**
- [ ] StockLevelDashboard, StockValuation, InventoryReport
- [ ] WarehouseLayout, BinManager, PutawayPick
- [ ] TransferOrderCreator, TransferTracker
- [ ] QCInspection, QCParameters, QCReport
- [ ] LotTracker, SerialTracker, TraceabilityViewer
- [ ] CycleCountPlanner, CountSheet, AdjustmentForm
- [ ] BarcodeScannerUI, MobileInventoryOps
- [ ] DemandForecast, ReorderPlanner, SafetyStockCalc

---

### 2.13 Fulfillment Module (`modules/fulfillment/`)
| Service | Features | Priority |
|---------|----------|----------|
| **fulfillment** | Order fulfillment, pick/pack/ship, fulfillment status | P0 |
| **shipping** | Shipping labels, carrier integration, tracking | P0 |
| **returns** | Return requests, RMA processing, refunds | P1 |

**Components Needed:**
- [ ] FulfillmentQueue, PickPackShip, FulfillmentStatus
- [ ] ShippingLabelGenerator, CarrierSelector, TrackingViewer
- [ ] ReturnRequestForm, RMAProcessor, RefundHandler

---

### 2.14 Manufacturing Module (`modules/manufacturing/`)
| Service | Features | Priority |
|---------|----------|----------|
| **bom** | BOM editor, multi-level BOM, BOM comparison | P0 |
| **production-order** | Work orders, production scheduling, WIP tracking | P0 |
| **production-planning** | MRP, capacity planning, production calendar | P1 |
| **shop-floor** | Shop floor control, machine status, operator dashboard | P1 |
| **quality-production** | In-process QC, quality gates, defect tracking | P1 |
| **subcontracting** | Subcontract orders, material issue, job work | P1 |
| **work-center** | Work center setup, capacity, scheduling | P1 |
| **routing** | Routing definition, operation sequencing | P1 |
| **job-card** | Job card printing, operation recording, time tracking | P1 |

**Components Needed:**
- [ ] BOMEditor, MultiLevelBOM, BOMComparison
- [ ] WorkOrderCreator, ProductionScheduler, WIPTracker
- [ ] MRPCalculator, CapacityPlanner, ProductionCalendar
- [ ] ShopFloorDashboard, MachineStatus, OperatorUI
- [ ] InProcessQC, QualityGates, DefectTracker
- [ ] SubcontractOrder, MaterialIssue, JobWorkTracker
- [ ] WorkCenterSetup, CapacityEditor, ScheduleViewer
- [ ] RoutingEditor, OperationSequencer
- [ ] JobCardPrinter, OperationRecorder, TimeTracker

---

### 2.15 Sales Module (`modules/sales/`)
| Service | Features | Priority |
|---------|----------|----------|
| **sales-order** | SO creation, SO approval, SO tracking | P0 |
| **sales-invoice** | Invoice generation, invoice sending, payments | P0 |
| **crm** | Lead management, opportunity pipeline, activities | P1 |
| **territory** | Territory mapping, territory assignment | P2 |
| **commission** | Commission rules, commission calculation, payouts | P2 |
| **pricing** | Price lists, pricing rules, discounts | P0 |
| **dealer** | Dealer management, dealer orders, dealer portal | P2 |
| **sales-analytics** | Sales dashboard, sales reports, forecasting | P1 |
| **route-planning** | Route optimization, visit scheduling | P2 |
| **field-sales** | Mobile sales app, offline sync | P2 |

**Components Needed:**
- [ ] SOCreator, SOApproval, SOTracker
- [ ] SalesInvoiceGenerator, PaymentRecorder
- [ ] LeadManager, OpportunityPipeline, ActivityTracker
- [ ] TerritoryMapper, TerritoryAssignment
- [ ] CommissionRuleEditor, CommissionCalculator, PayoutManager
- [ ] PriceListEditor, PricingRules, DiscountManager
- [ ] DealerManager, DealerOrderPortal
- [ ] SalesDashboard, SalesReport, SalesForecast
- [ ] RoutePlanner, VisitScheduler
- [ ] MobileSalesUI, OfflineSyncManager

---

### 2.16 Projects Module (`modules/projects/`)
| Service | Features | Priority |
|---------|----------|----------|
| **project** | Project list, project dashboard, project setup | P0 |
| **task** | Task board (Kanban), task list, task dependencies | P0 |
| **timesheet** | Time entry, timesheet approval, time reports | P0 |
| **project-costing** | Project budget, actual vs budget, cost tracking | P1 |
| **boq** | Bill of quantities, BOQ revisions, quantity tracking | P1 |
| **sub-contractor** | Subcontractor management, work orders, payments | P1 |
| **progress-billing** | Milestone billing, progress certificates, retention | P1 |

**Components Needed:**
- [ ] ProjectList, ProjectDashboard, ProjectSetup
- [ ] TaskBoard, TaskList, DependencyViewer
- [ ] TimeEntry, TimesheetApproval, TimeReport
- [ ] ProjectBudget, BudgetVsActual, CostTracker
- [ ] BOQEditor, BOQRevisions, QuantityTracker
- [ ] SubcontractorManager, WorkOrderCreator, PaymentTracker
- [ ] MilestoneBilling, ProgressCertificate, RetentionTracker

---

### 2.17 Budget Module (`modules/budget/`)
| Service | Features | Priority |
|---------|----------|----------|
| **budget** | Budget creation, budget approval, budget monitoring | P0 |
| **capex** | Capital budget, asset requests, ROI analysis | P1 |
| **budget-variance** | Variance analysis, variance reports, alerts | P1 |
| **Forecasting** | Financial forecasting, scenario modeling | P2 |

**Components Needed:**
- [ ] BudgetCreator, BudgetApproval, BudgetMonitor
- [ ] CapexBudget, AssetRequest, ROICalculator
- [ ] VarianceAnalysis, VarianceReport, VarianceAlerts
- [ ] ForecastModeler, ScenarioComparison

---

### 2.18 Banking Module (`modules/banking/`)
| Service | Features | Priority |
|---------|----------|----------|
| **gst** | GST filing, GSTR reports, GST reconciliation | P0 |
| **e-invoice** | E-invoice generation, IRN management, E-way bill | P0 |
| **e-way-bill** | E-way bill generation, consolidation | P0 |
| **tds** | TDS calculation, TDS returns, certificates | P1 |
| **banking** | Bank integration, payment processing, NEFT/RTGS | P1 |

**Components Needed:**
- [ ] GSTFiling, GSTRReport, GSTReconciliation
- [ ] EInvoiceGenerator, IRNManager, EwayBillLink
- [ ] EwayBillGenerator, EwayConsolidation
- [ ] TDSCalculator, TDSReturn, CertificateGenerator
- [ ] BankIntegration, PaymentProcessor, NEFTRTGSForm

---

### 2.19 Communication Module (`modules/communication/`)
| Service | Features | Priority |
|---------|----------|----------|
| **Chat** | Internal chat, group chat, file sharing | P2 |
| **i18n** | Language settings, translation management | P1 |
| **currency** | Currency rates, multi-currency support | P0 |

**Components Needed:**
- [ ] ChatInterface, GroupChat, FileSharing
- [ ] LanguageSelector, TranslationManager
- [ ] CurrencyRates, CurrencyConverter, MultiCurrencySettings

---

### 2.20 Asset Module (`modules/asset/`)
| Service | Features | Priority |
|---------|----------|----------|
| **Asset** | Asset register, asset lifecycle, asset reports | P1 |
| **vehicle** | Vehicle management, vehicle tracking, fuel logs | P2 |
| **depreciation** | Depreciation schedules, depreciation methods | P1 |
| **equipment** | Equipment management, equipment allocation | P2 |
| **maintenance** | Maintenance schedules, work orders, AMC tracking | P1 |

**Components Needed:**
- [ ] AssetRegister, AssetLifecycle, AssetReport
- [ ] VehicleManager, VehicleTracker, FuelLogEntry
- [ ] DepreciationSchedule, DepreciationMethodEditor
- [ ] EquipmentManager, EquipmentAllocation
- [ ] MaintenanceScheduler, MaintenanceWorkOrder, AMCTracker

---

## Phase 3: Cross-Cutting Features

### 3.1 Document Management
- [ ] Document upload/download
- [ ] Document preview (PDF, images, Office docs)
- [ ] Document versioning
- [ ] Document templates
- [ ] Document tagging and search

### 3.2 Print & Export
- [ ] Print layouts for all documents
- [ ] PDF generation
- [ ] Excel/CSV export
- [ ] Bulk print queue
- [ ] Custom print templates

### 3.3 Mobile Responsiveness
- [ ] Responsive layouts for all modules
- [ ] Touch-friendly interactions
- [ ] Mobile navigation patterns
- [ ] Offline capability (PWA)

### 3.4 Accessibility
- [ ] ARIA compliance for all components
- [ ] Keyboard navigation
- [ ] Screen reader support
- [ ] High contrast theme
- [ ] Focus management

### 3.5 Performance
- [ ] Code splitting per module
- [ ] Lazy loading routes
- [ ] Virtual scrolling for large lists
- [ ] Image optimization
- [ ] Caching strategies

---

## Phase 4: Testing & Documentation

### 4.1 Testing
- [ ] Unit tests for utility functions
- [ ] Component tests for UI library
- [ ] Integration tests for API calls
- [ ] E2E tests for critical flows
- [ ] Visual regression tests

### 4.2 Documentation
- [ ] Storybook for component library
- [ ] API documentation
- [ ] User guides per module
- [ ] Developer documentation
- [ ] Deployment guides

---

## Priority Legend
- **P0**: Critical - Core functionality, must have for MVP
- **P1**: High - Important features, needed soon after MVP
- **P2**: Medium - Nice to have, can be deferred

---

## Estimated Component Count by Module

| Module | Estimated Components |
|--------|---------------------|
| Identity | 15 |
| Workflow | 12 |
| Notifications | 8 |
| Audit | 10 |
| Data | 8 |
| Insights | 15 |
| Platform | 20 |
| Masters | 15 |
| Finance | 25 |
| HR | 20 |
| Purchase | 8 |
| Inventory | 18 |
| Fulfillment | 8 |
| Manufacturing | 20 |
| Sales | 18 |
| Projects | 15 |
| Budget | 8 |
| Banking | 10 |
| Communication | 6 |
| Asset | 12 |
| **Total** | **~260 components** |

---

## Next Steps
1. Complete SvelteKit app setup
2. Setup ConnectRPC client generation
3. Implement Identity module (authentication first)
4. Implement Masters module (foundational data)
5. Implement Finance module (core business logic)
6. Continue with remaining modules by priority
