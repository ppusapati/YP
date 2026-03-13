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
} from './gen/packages/proto/context_pb.js';

export {
  BaseResponseSchema,
  type BaseResponse,
  type Status,
  CanonicalReason,
} from './gen/packages/proto/response_pb.js';

export {
  MoneySchema,
  type Money,
} from './gen/packages/proto/money_pb.js';

export {
  PaginationSchema,
  type Pagination,
  PaginationRequestSchema,
  type PaginationRequest,
  PaginationResponseSchema,
  type PaginationResponse,
} from './gen/packages/proto/pagination_pb.js';

export * from './gen/packages/proto/enum_pb.js';
export * from './gen/packages/proto/filter_pb.js';
export * from './gen/packages/proto/geo_pb.js';
export * from './gen/packages/proto/query_pb.js';

// ─── Agriculture Service Descriptors ─────────────────────────────────────────

export { CropService } from './gen/crop-service/proto/crop_pb.js';
export { FarmService } from './gen/farm-service/proto/farm_pb.js';
export { FieldService } from './gen/field-service/proto/field_pb.js';
export { SoilService } from './gen/soil-service/proto/soil_pb.js';
export { SensorService } from './gen/sensor-service/proto/sensor_pb.js';
export { IrrigationService } from './gen/irrigation-service/proto/irrigation_pb.js';
export { SatelliteService } from './gen/satellite-service/proto/satellite_pb.js';
export { PestPredictionService } from './gen/pest-prediction-service/proto/pest_pb.js';
export { PlantDiagnosisService } from './gen/plant-diagnosis-service/proto/diagnosis_pb.js';
export { YieldService } from './gen/yield-service/proto/yield_pb.js';
export { TraceabilityService } from './gen/traceability-service/proto/traceability_pb.js';

// ─── Satellite Sub-Service Descriptors ──────────────────────────────────────

export { SatelliteIngestionService } from './gen/satellite-ingestion-service/proto/ingestion_pb.js';
export { SatelliteProcessingService } from './gen/satellite-processing-service/proto/processing_pb.js';
export { SatelliteAnalyticsService } from './gen/satellite-analytics-service/proto/analytics_pb.js';
export { SatelliteTileService } from './gen/satellite-tile-service/proto/tile_pb.js';
export { VegetationIndexService } from './gen/vegetation-index-service/proto/vegetation_index_pb.js';

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
} from './gen/crop-service/proto/crop_pb.js';

export { CropCategory } from './gen/crop-service/proto/crop_pb.js';

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
} from './gen/farm-service/proto/farm_pb.js';

export {
  FarmType,
  FarmStatus,
  SoilType as FarmSoilType,
  ClimateZone,
} from './gen/farm-service/proto/farm_pb.js';

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
} from './gen/field-service/proto/field_pb.js';

export {
  FieldStatus,
  FieldType,
  SoilType as FieldSoilType,
  IrrigationType,
} from './gen/field-service/proto/field_pb.js';

export type {
  SoilSample,
  SoilAnalysis,
  SoilHealthScore,
  SoilNutrient,
} from './gen/soil-service/proto/soil_pb.js';

export {
  SoilTexture,
  AnalysisStatus,
  NutrientLevel,
  HealthCategory,
} from './gen/soil-service/proto/soil_pb.js';

export type {
  Sensor,
  SensorReading,
  SensorAlert,
  SensorNetwork,
  SensorCalibration,
} from './gen/sensor-service/proto/sensor_pb.js';

export {
  SensorType,
  SensorStatus,
  SensorProtocol,
  ReadingQuality,
  AlertSeverity,
} from './gen/sensor-service/proto/sensor_pb.js';

export type {
  IrrigationSchedule,
  IrrigationZone,
  WaterController,
  IrrigationEvent,
  IrrigationDecision,
} from './gen/irrigation-service/proto/irrigation_pb.js';

export {
  ScheduleType,
  ControllerType,
  ControllerStatus,
  IrrigationStatus,
} from './gen/irrigation-service/proto/irrigation_pb.js';

export type {
  SatelliteImage,
  VegetationIndex,
} from './gen/satellite-service/proto/satellite_pb.js';

export type {
  PestSpecies,
  PestPrediction,
  PestAlert,
  PestObservation,
  PestTreatment,
} from './gen/pest-prediction-service/proto/pest_pb.js';

export {
  RiskLevel,
  TreatmentType,
} from './gen/pest-prediction-service/proto/pest_pb.js';

export type {
  DiagnosisRequest,
  DiagnosisResult,
} from './gen/plant-diagnosis-service/proto/diagnosis_pb.js';

export type {
  YieldPrediction,
  YieldRecord,
  HarvestPlan,
} from './gen/yield-service/proto/yield_pb.js';

export type {
  TraceabilityRecord,
  Certification,
  BatchRecord,
} from './gen/traceability-service/proto/traceability_pb.js';

// ─── Satellite Sub-Service Types ─────────────────────────────────────────────

export type {
  IngestionTask,
} from './gen/satellite-ingestion-service/proto/ingestion_pb.js';

export {
  SatelliteProvider as IngestionSatelliteProvider,
  IngestionStatus,
  SpectralBand as IngestionSpectralBand,
} from './gen/satellite-ingestion-service/proto/ingestion_pb.js';

export type {
  ProcessingJob,
} from './gen/satellite-processing-service/proto/processing_pb.js';

export {
  ProcessingStatus as SatProcessingStatus,
  ProcessingLevel,
  CorrectionAlgorithm,
} from './gen/satellite-processing-service/proto/processing_pb.js';

export type {
  StressAlert,
  TemporalAnalysis as SatTemporalAnalysis,
} from './gen/satellite-analytics-service/proto/analytics_pb.js';

export {
  StressType,
  SeverityLevel,
  AnalysisType,
} from './gen/satellite-analytics-service/proto/analytics_pb.js';

export type {
  Tileset,
} from './gen/satellite-tile-service/proto/tile_pb.js';

export {
  TileFormat,
  TilesetStatus,
  TileLayer,
} from './gen/satellite-tile-service/proto/tile_pb.js';

export type {
  VegetationIndex as VegIndex,
  ComputeTask,
  NDVITimeSeries,
  TimeSeriesPoint,
} from './gen/vegetation-index-service/proto/vegetation_index_pb.js';

export {
  VegetationIndexType,
  ComputeStatus,
} from './gen/vegetation-index-service/proto/vegetation_index_pb.js';
