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

// Pest Prediction Service
export { pestPredictionRequestSchema, treatmentPlanSchema } from './pest.schema';

// Plant Diagnosis Service
export { diagnosisRequestFormSchema } from './diagnosis.schema';

// Yield Service
export { yieldRecordSchema, yieldForecastRequestSchema } from './yield.schema';

// Traceability Service
export { traceabilityRecordSchema, certificationSchema, supplyEventSchema } from './traceability.schema';

// Report schemas
export * from './reports/index';
