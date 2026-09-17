// @samavāya/proto — Generated TypeScript protobuf types and ConnectRPC service descriptors
//
// Generated files are in src/gen/ — do NOT edit manually.
// Regenerate with: pnpm generate:clean
//
// Usage with ConnectRPC:
//
//   import { createClient } from '@connectrpc/connect';
//   import { CropService } from '@samavāya/proto';
//   import { agTransport } from '@samavāya/agriculture/api';
//
//   const client = createClient(CropService, agTransport);
//   const res = await client.listCrops({ tenantId: '...', pageSize: 20 });

// ─── Shared Types ────────────────────────────────────────────────────────────

export {
  TenantContextSchema,
  type TenantContext,
} from './gen/context_pb.js';

export {
  BaseResponseSchema,
  type BaseResponse,
  type Status,
  CanonicalReason,
} from './gen/response_pb.js';

export {
  MoneySchema,
  type Money,
} from './gen/money_pb.js';

export {
  PaginationSchema,
  type Pagination,
  PaginationRequestSchema,
  type PaginationRequest,
  PaginationResponseSchema,
  type PaginationResponse,
} from './gen/pagination_pb.js';

export * from './gen/enum_pb.js';
export * from './gen/filter_pb.js';
export * from './gen/geo_pb.js';
export * from './gen/query_pb.js';

// ─── Agriculture Service Descriptors ─────────────────────────────────────────

export { CropService } from './gen/crop_pb.js';
export { FarmService } from './gen/farm_pb.js';

// Enum descriptors, not just the enums themselves.
//
// A form's select options are the proto's JSON names ('FARM_TYPE_CROP') while
// the message carries a number, and `enumFromJson`/`enumToJson` need the
// descriptor to convert between them. Exporting it means a page converts
// through the generated schema rather than a hand-written lookup table that
// drifts the first time the proto gains a value.
export {
  FarmTypeSchema,
  ClimateZoneSchema,
  FarmStatusSchema,
  // Aliased, because field_pb declares a *different* SoilType. They are not
  // variations on a spelling: farm has CHALKY, LATERITE, BLACK, RED and
  // ALLUVIAL; field has CHALK, CLAY_LOAM and SANDY_LOAM. Converting a field's
  // soil type through the farm descriptor would map the wrong number to the
  // wrong name with no error anywhere.
  SoilTypeSchema as FarmSoilTypeSchema,
} from './gen/farm_pb.js';

export {
  FieldTypeSchema,
  IrrigationTypeSchema,
  AspectDirectionSchema,
  FieldStatusSchema,
  SoilTypeSchema as FieldSoilTypeSchema,
} from './gen/field_pb.js';

export { CropCategorySchema } from './gen/crop_pb.js';

export { SensorStatusSchema, SensorProtocolSchema } from './gen/sensor_pb.js';

export {
  ScheduleTypeSchema,
  FrequencySchema,
  IrrigationStatusSchema,
} from './gen/irrigation_pb.js';
export { FieldService } from './gen/field_pb.js';
export { SoilService } from './gen/soil_pb.js';
export { SensorService } from './gen/sensor_pb.js';
export { IrrigationService } from './gen/irrigation_pb.js';
export { SatelliteService } from './gen/satellite_pb.js';
export { PestPredictionService } from './gen/pest_pb.js';
export { PlantDiagnosisService } from './gen/diagnosis_pb.js';
export { YieldService } from './gen/yield_pb.js';
export { TraceabilityService } from './gen/traceability_pb.js';

// ─── Satellite Sub-Service Descriptors ──────────────────────────────────────

export { SatelliteIngestionService } from './gen/ingestion_pb.js';
export { SatelliteProcessingService } from './gen/processing_pb.js';
export { SatelliteAnalyticsService } from './gen/analytics_pb.js';
export { SatelliteTileService } from './gen/tile_pb.js';
export { VegetationIndexService } from './gen/vegetation_index_pb.js';

// ─── Advisory Assistant Descriptors ─────────────────────────────────────────
//
// The service descriptor is AdvisoryService in package agriculture.advisory.v1.
// agronomy-service also has a service called AdvisoryService, in its own
// package, which is why this one is exported under the name the UI uses for it
// rather than by its bare service name.

export { AdvisoryService as AgronomyAssistantService } from './gen/assistant_pb.js';

export {
  Locale as AdvisoryLocale,
  CitationKind,
  AnswerKind,
  GroundednessVerdict,
  DocumentKind,
} from './gen/assistant_pb.js';

export type {
  Citation as AdvisoryCitation,
  ToolCall as AdvisoryToolCall,
  UnsupportedClaim,
  Evaluation as AdvisoryEvaluation,
  Usage as AdvisoryUsage,
  Exchange as AdvisoryExchange,
  Conversation as AdvisoryConversation,
  ReferenceDocument,
  TenantBudget,
  AskRequest,
  AskResponse,
} from './gen/assistant_pb.js';

// ─── Alert, Analytics & Prescription Service Descriptors ────────────────────

export { AlertService } from './gen/alert_pb.js';
export { FieldAnalyticsService } from './gen/field_analytics_pb.js';
export { PrescriptionService } from './gen/prescription_pb.js';

// ─── Agriculture Message Types (re-exports for convenience) ──────────────────

export type {
  Crop,
  CropVariety,
  GrowthStage,
  CropRequirements,
  CropRecommendation,
  CreateCropRequest,
  CreateCropResponse,
  GetCropRequest,
  GetCropResponse,
  ListCropsRequest,
  ListCropsResponse,
  UpdateCropRequest,
  UpdateCropResponse,
  DeleteCropRequest,
  DeleteCropResponse,
} from './gen/crop_pb.js';

export { CropCategory } from './gen/crop_pb.js';

export type {
  Farm,
  FarmLocation,
  FarmBoundary,
  FarmOwner,
  CreateFarmRequest,
  CreateFarmResponse,
  GetFarmRequest,
  GetFarmResponse,
  ListFarmsRequest,
  ListFarmsResponse,
  UpdateFarmRequest,
  UpdateFarmResponse,
  DeleteFarmRequest,
  DeleteFarmResponse,
} from './gen/farm_pb.js';

export {
  FarmType,
  FarmStatus,
  SoilType as FarmSoilType,
  ClimateZone,
} from './gen/farm_pb.js';

export type {
  Field,
  FieldBoundary,
  FieldCropAssignment,
  FieldSegment,
  CreateFieldRequest,
  CreateFieldResponse,
  GetFieldRequest,
  GetFieldResponse,
  ListFieldsRequest,
  ListFieldsResponse,
  UpdateFieldRequest,
  UpdateFieldResponse,
  DeleteFieldRequest,
  DeleteFieldResponse,
} from './gen/field_pb.js';

export {
  FieldStatus,
  FieldType,
  SoilType as FieldSoilType,
  IrrigationType,
} from './gen/field_pb.js';

export type {
  SoilSample,
  SoilAnalysis,
  SoilHealthScore,
  SoilNutrient,
} from './gen/soil_pb.js';

export {
  SoilTexture,
  AnalysisStatus,
  NutrientLevel,
  HealthCategory,
} from './gen/soil_pb.js';

export type {
  Sensor,
  SensorReading,
  SensorAlert,
  SensorNetwork,
  SensorCalibration,
} from './gen/sensor_pb.js';

export {
  SensorType,
  SensorStatus,
  SensorProtocol,
  ReadingQuality,
  // Two services define an AlertSeverity and both were re-exported here under
  // the same name, which is a duplicate export rather than a merge: consumers
  // got whichever the bundler resolved to, silently. alert-service owns alerts,
  // so it keeps the plain name and the sensor one is qualified.
  AlertSeverity as SensorAlertSeverity,
} from './gen/sensor_pb.js';

export type {
  IrrigationSchedule,
  IrrigationZone,
  WaterController,
  IrrigationEvent,
  IrrigationDecision,
} from './gen/irrigation_pb.js';

export {
  ScheduleType,
  ControllerType,
  ControllerStatus,
  IrrigationStatus,
} from './gen/irrigation_pb.js';

export type {
  SatelliteImage,
  VegetationIndex,
} from './gen/satellite_pb.js';

export type {
  PestSpecies,
  PestPrediction,
  PestAlert,
  PestObservation,
  PestTreatment,
} from './gen/pest_pb.js';

export {
  RiskLevel,
  TreatmentType,
} from './gen/pest_pb.js';

export type {
  DiagnosisRequest,
  DiagnosisResult,
  LabelReviewSample,
  LabelReview,
  TrainingLabel,
  Explanation,
  NutrientDeficiency,
  PestDamage,
  ReviewAgreement,
  LabelDisagreement,
} from './gen/diagnosis_pb.js';

export { LabelReviewDecision } from './gen/diagnosis_pb.js';

export type {
  YieldPrediction,
  YieldRecord,
  HarvestPlan,
} from './gen/yield_pb.js';

export type {
  TraceabilityRecord,
  Certification,
  BatchRecord,
} from './gen/traceability_pb.js';

// ─── Satellite Sub-Service Types ─────────────────────────────────────────────

export type {
  IngestionTask,
} from './gen/ingestion_pb.js';

export {
  SatelliteProvider as IngestionSatelliteProvider,
  IngestionStatus,
  SpectralBand as IngestionSpectralBand,
} from './gen/ingestion_pb.js';

export type {
  ProcessingJob,
} from './gen/processing_pb.js';

export {
  ProcessingStatus as SatProcessingStatus,
  ProcessingLevel,
  CorrectionAlgorithm,
} from './gen/processing_pb.js';

export type {
  StressAlert,
  TemporalAnalysis as SatTemporalAnalysis,
} from './gen/analytics_pb.js';

export {
  StressType,
  SeverityLevel,
  AnalysisType,
} from './gen/analytics_pb.js';

export type {
  Tileset,
} from './gen/tile_pb.js';

export {
  TileFormat,
  TilesetStatus,
  TileLayer,
} from './gen/tile_pb.js';

export type {
  VegetationIndex as VegIndex,
  ComputeTask,
  NDVITimeSeries,
  TimeSeriesPoint,
} from './gen/vegetation_index_pb.js';

export {
  VegetationIndexType,
  ComputeStatus,
} from './gen/vegetation_index_pb.js';

// ─── Alert Service Types ────────────────────────────────────────────────────

export type {
  Alert,
  AlertRule,
  FieldRiskScore,
} from './gen/alert_pb.js';

export {
  AlertSeverity,
  AlertStatus,
} from './gen/alert_pb.js';

// ─── Field Analytics Service Types ──────────────────────────────────────────

export type {
  FieldAnalyticsSummary,
  YieldTrendPoint,
  SeasonComparison,
  RotationAnalysis,
  HistoricalMetrics,
  CrossFieldTrendPoint,
} from './gen/field_analytics_pb.js';

// ─── Prescription Service Types ─────────────────────────────────────────────

export type {
  PrescriptionBundle,
  PrescriptionMap,
  ZoneSummary,
} from './gen/prescription_pb.js';

export {
  PrescriptionType,
} from './gen/prescription_pb.js';
