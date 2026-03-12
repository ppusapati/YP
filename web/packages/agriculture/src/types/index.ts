/**
 * Agriculture Domain Types
 *
 * Re-exported from generated proto types (@samavāya/proto).
 * Import from here or directly from @samavāya/proto.
 */
export type {
  // Farm Service
  Farm,
  FarmLocation,
  FarmBoundary,
  FarmOwner,
  CreateFarmRequest,
  ListFarmsRequest,
  ListFarmsResponse,

  // Crop Service
  Crop,
  CropVariety,
  GrowthStage,
  CropRequirements,
  CropRecommendation,
  CreateCropRequest,
  ListCropsRequest,
  ListCropsResponse,

  // Field Service
  Field,
  FieldBoundary,
  FieldCropAssignment,
  FieldSegment,
  CreateFieldRequest,
  ListFieldsRequest,
  ListFieldsResponse,

  // Soil Service
  SoilSample,
  SoilAnalysis,
  SoilHealthScore,
  SoilNutrient,

  // Sensor Service
  Sensor,
  SensorReading,
  SensorAlert,
  SensorNetwork,
  SensorCalibration,

  // Irrigation Service
  IrrigationSchedule,
  IrrigationZone,
  WaterController,
  IrrigationEvent,
  IrrigationDecision,

  // Satellite Service
  SatelliteImage,
  VegetationIndex,

  // Pest Prediction Service
  PestSpecies,
  PestPrediction,
  PestAlert,
  PestObservation,
  PestTreatment,

  // Plant Diagnosis Service
  DiagnosisRequest,
  DiagnosisResult,

  // Yield Service
  YieldPrediction,
  YieldRecord,
  HarvestPlan,

  // Traceability Service
  TraceabilityRecord,
  Certification,
  BatchRecord,
} from '@samavāya/proto';

// Enums
export {
  FarmType,
  FarmStatus,
  FarmSoilType,
  ClimateZone,
  CropCategory,
  FieldStatus,
  FieldType,
  FieldSoilType,
  IrrigationType,
  SoilTexture,
  AnalysisStatus,
  NutrientLevel,
  HealthCategory,
  SensorType,
  SensorStatus,
  SensorProtocol,
  ReadingQuality,
  AlertSeverity,
  ScheduleType,
  ControllerType,
  ControllerStatus,
  IrrigationStatus,
  RiskLevel,
  TreatmentType,
} from '@samavāya/proto';

// ─── Common Types ────────────────────────────────────────────────────────────

export interface ListParams {
  page?: number;
  page_size?: number;
  sort_by?: string;
  sort_order?: 'asc' | 'desc';
  search?: string;
  filters?: Record<string, unknown>;
}
