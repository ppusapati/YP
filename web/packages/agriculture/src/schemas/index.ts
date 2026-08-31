/**
 * Agriculture Form Schemas — All services
 */

// Farm Service
export { createFarmSchema, farmBoundarySchema, farmOwnerSchema, ownershipTransferSchema } from './farm.schema';

// Field Service
export { createFieldSchema, assignCropSchema, fieldSegmentSchema } from './field.schema';

// Crop Service
export { createCropSchema, cropVarietySchema, cropRequirementsSchema } from './crop.schema';

// Soil Service
export { createSoilSampleSchema, analyzeSoilSchema } from './soil.schema';

// Sensor Service
export { registerSensorSchema, alertRuleSchema, calibrateSensorSchema } from './sensor.schema';

// Irrigation Service
export { irrigationScheduleSchema, irrigationZoneSchema, irrigationControllerSchema } from './irrigation.schema';

// Satellite Service
export { satelliteImageFormSchema } from './satellite.schema';

// Satellite Tile Service
export { generateTilesetFormSchema } from './tile.schema';

// Vegetation Index Service
export { computeIndicesFormSchema, ndviTimeSeriesFormSchema } from './vegetation-index.schema';

// Pest Prediction Service
export { pestPredictionRequestSchema, treatmentPlanSchema } from './pest.schema';

// Plant Diagnosis Service
export { diagnosisRequestFormSchema } from './diagnosis.schema';

// Yield Service
export { yieldRecordSchema, yieldForecastRequestSchema } from './yield.schema';

// Traceability Service
export { traceabilityRecordSchema, certificationSchema, supplyEventSchema } from './traceability.schema';

// Ingestion Service
export { requestIngestionFormSchema } from './ingestion.schema';

// Processing Service
export { submitProcessingJobFormSchema } from './processing.schema';

// Satellite Analytics Service
export { detectStressFormSchema, runTemporalAnalysisFormSchema } from './analytics.schema';

// Report schemas
export * from './reports/index';
