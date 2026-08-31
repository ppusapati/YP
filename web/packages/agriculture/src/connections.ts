/**
 * Form-to-Form and Database-to-Database Connections
 * Defines the relationship graph between agriculture service forms and entities
 */

export interface FormConnection {
  sourceForm: string;
  targetForm: string;
  trigger: 'onSave' | 'onLink' | 'onSelect';
  fieldMapping: Record<string, string>; // source field -> target field
  description: string;
}

export interface DatabaseConnection {
  sourceService: string;
  sourceEntity: string;
  targetService: string;
  targetEntity: string;
  foreignKey: string;
  relationship: 'one-to-one' | 'one-to-many' | 'many-to-many';
  description: string;
}

// ─── Form Connections ────────────────────────────────────────────────────────

export const formConnections: FormConnection[] = [
  // Farm -> Field
  {
    sourceForm: 'createFarm',
    targetForm: 'createField',
    trigger: 'onSave',
    fieldMapping: { id: 'farm_id' },
    description: 'After creating a farm, navigate to create fields for it',
  },
  // Farm -> Farm Boundary
  {
    sourceForm: 'createFarm',
    targetForm: 'farmBoundary',
    trigger: 'onSave',
    fieldMapping: { id: 'farm_id' },
    description: 'After creating a farm, set its geographic boundary',
  },
  // Farm -> Farm Owner
  {
    sourceForm: 'createFarm',
    targetForm: 'farmOwner',
    trigger: 'onSave',
    fieldMapping: { id: 'farm_id' },
    description: 'After creating a farm, add owners',
  },
  // Field -> Crop Assignment
  {
    sourceForm: 'createField',
    targetForm: 'assignCrop',
    trigger: 'onSave',
    fieldMapping: { id: 'field_id' },
    description: 'After creating a field, assign crops to it',
  },
  // Field -> Field Segment
  {
    sourceForm: 'createField',
    targetForm: 'fieldSegment',
    trigger: 'onSave',
    fieldMapping: { id: 'field_id' },
    description: 'After creating a field, define segments within it',
  },
  // Field -> Soil Sample
  {
    sourceForm: 'createField',
    targetForm: 'createSoilSample',
    trigger: 'onSave',
    fieldMapping: { id: 'field_id', farm_id: 'farm_id' },
    description: 'After creating a field, collect soil samples from it',
  },
  // Field -> Register Sensor
  {
    sourceForm: 'createField',
    targetForm: 'registerSensor',
    trigger: 'onSave',
    fieldMapping: { id: 'field_id' },
    description: 'After creating a field, register sensors for it',
  },
  // Field -> Irrigation Schedule
  {
    sourceForm: 'createField',
    targetForm: 'irrigationSchedule',
    trigger: 'onSave',
    fieldMapping: { id: 'field_id' },
    description: 'After creating a field, set up irrigation schedules',
  },
  // Field -> Irrigation Zone
  {
    sourceForm: 'createField',
    targetForm: 'irrigationZone',
    trigger: 'onSave',
    fieldMapping: { id: 'field_id' },
    description: 'After creating a field, define irrigation zones',
  },
  // Soil Sample -> Soil Analysis
  {
    sourceForm: 'createSoilSample',
    targetForm: 'analyzeSoil',
    trigger: 'onSave',
    fieldMapping: { id: 'sample_id' },
    description: 'After collecting a soil sample, trigger analysis',
  },
  // Crop -> Crop Variety
  {
    sourceForm: 'createCrop',
    targetForm: 'cropVariety',
    trigger: 'onSave',
    fieldMapping: { id: 'crop_id' },
    description: 'After creating a crop, add varieties for it',
  },
  // Crop -> Crop Requirements
  {
    sourceForm: 'createCrop',
    targetForm: 'cropRequirements',
    trigger: 'onSave',
    fieldMapping: { id: 'crop_id' },
    description: 'After creating a crop, define its growth requirements',
  },
  // Sensor -> Alert Rule
  {
    sourceForm: 'registerSensor',
    targetForm: 'alertRule',
    trigger: 'onSave',
    fieldMapping: { id: 'sensor_id' },
    description: 'After registering a sensor, create alert rules for it',
  },
  // Sensor -> Calibrate Sensor
  {
    sourceForm: 'registerSensor',
    targetForm: 'calibrateSensor',
    trigger: 'onLink',
    fieldMapping: { id: 'sensor_id' },
    description: 'Link to calibrate a registered sensor',
  },
  // Irrigation Zone -> Irrigation Schedule
  {
    sourceForm: 'irrigationZone',
    targetForm: 'irrigationSchedule',
    trigger: 'onSave',
    fieldMapping: { id: 'zone_id', field_id: 'field_id' },
    description: 'After creating an irrigation zone, create a schedule for it',
  },
  // Irrigation Controller -> Irrigation Zone
  {
    sourceForm: 'irrigationController',
    targetForm: 'irrigationZone',
    trigger: 'onSave',
    fieldMapping: { id: 'controller_id' },
    description: 'After registering a controller, assign it to a zone',
  },
  // Pest Prediction -> Treatment Plan
  {
    sourceForm: 'pestPredictionRequest',
    targetForm: 'treatmentPlan',
    trigger: 'onSave',
    fieldMapping: { id: 'prediction_id' },
    description: 'After receiving a pest prediction, create a treatment plan',
  },
  // Crop Assignment -> Yield Record
  {
    sourceForm: 'assignCrop',
    targetForm: 'yieldRecord',
    trigger: 'onLink',
    fieldMapping: { field_id: 'field_id', crop_id: 'crop_id' },
    description: 'Link crop assignment to record yield for that field/crop',
  },
  // Crop Assignment -> Yield Forecast
  {
    sourceForm: 'assignCrop',
    targetForm: 'yieldForecastRequest',
    trigger: 'onLink',
    fieldMapping: { field_id: 'field_id', crop_id: 'crop_id' },
    description: 'Link crop assignment to request yield forecast',
  },
  // Crop Assignment -> Pest Prediction
  {
    sourceForm: 'assignCrop',
    targetForm: 'pestPredictionRequest',
    trigger: 'onLink',
    fieldMapping: { field_id: 'field_id', crop_id: 'crop_id' },
    description: 'Link crop assignment to request pest prediction',
  },
  // Crop Assignment -> Traceability Record
  {
    sourceForm: 'assignCrop',
    targetForm: 'traceabilityRecord',
    trigger: 'onLink',
    fieldMapping: { field_id: 'field_id', crop_id: 'crop_id', farm_id: 'farm_id' },
    description: 'Link crop assignment to create a traceability record',
  },
  // Yield Record -> Traceability Record
  {
    sourceForm: 'yieldRecord',
    targetForm: 'traceabilityRecord',
    trigger: 'onSave',
    fieldMapping: { field_id: 'field_id', crop_id: 'crop_id', harvest_date: 'harvest_date' },
    description: 'After recording yield, create a traceability record',
  },
  // Traceability Record -> Certification
  {
    sourceForm: 'traceabilityRecord',
    targetForm: 'certification',
    trigger: 'onSave',
    fieldMapping: { id: 'record_id' },
    description: 'After creating a traceability record, add certifications',
  },
  // Traceability Record -> Supply Event
  {
    sourceForm: 'traceabilityRecord',
    targetForm: 'supplyEvent',
    trigger: 'onSave',
    fieldMapping: { id: 'record_id' },
    description: 'After creating a traceability record, log supply chain events',
  },
  // Ownership Transfer
  {
    sourceForm: 'farmOwner',
    targetForm: 'ownershipTransfer',
    trigger: 'onLink',
    fieldMapping: { farm_id: 'farm_id', user_id: 'from_user_id' },
    description: 'Link an existing owner to initiate ownership transfer',
  },
];

// ─── Database Connections ────────────────────────────────────────────────────

export const databaseConnections: DatabaseConnection[] = [
  // Farm -> Field
  {
    sourceService: 'farm-service',
    sourceEntity: 'Farm',
    targetService: 'field-service',
    targetEntity: 'Field',
    foreignKey: 'farm_id',
    relationship: 'one-to-many',
    description: 'A farm has many fields',
  },
  // Farm -> FarmOwner
  {
    sourceService: 'farm-service',
    sourceEntity: 'Farm',
    targetService: 'farm-service',
    targetEntity: 'FarmOwner',
    foreignKey: 'farm_id',
    relationship: 'one-to-many',
    description: 'A farm has many owners',
  },
  // Farm -> SoilSample
  {
    sourceService: 'farm-service',
    sourceEntity: 'Farm',
    targetService: 'soil-service',
    targetEntity: 'SoilSample',
    foreignKey: 'farm_id',
    relationship: 'one-to-many',
    description: 'A farm has many soil samples',
  },
  // Farm -> TraceabilityRecord
  {
    sourceService: 'farm-service',
    sourceEntity: 'Farm',
    targetService: 'traceability-service',
    targetEntity: 'TraceabilityRecord',
    foreignKey: 'farm_id',
    relationship: 'one-to-many',
    description: 'A farm has many traceability records',
  },
  // Field -> FieldCropAssignment
  {
    sourceService: 'field-service',
    sourceEntity: 'Field',
    targetService: 'crop-service',
    targetEntity: 'FieldCropAssignment',
    foreignKey: 'field_id',
    relationship: 'one-to-many',
    description: 'A field has many crop assignments',
  },
  // Field -> FieldSegment
  {
    sourceService: 'field-service',
    sourceEntity: 'Field',
    targetService: 'field-service',
    targetEntity: 'FieldSegment',
    foreignKey: 'field_id',
    relationship: 'one-to-many',
    description: 'A field has many segments',
  },
  // Field -> SoilSample
  {
    sourceService: 'field-service',
    sourceEntity: 'Field',
    targetService: 'soil-service',
    targetEntity: 'SoilSample',
    foreignKey: 'field_id',
    relationship: 'one-to-many',
    description: 'A field has many soil samples',
  },
  // Field -> Sensor
  {
    sourceService: 'field-service',
    sourceEntity: 'Field',
    targetService: 'sensor-service',
    targetEntity: 'Sensor',
    foreignKey: 'field_id',
    relationship: 'one-to-many',
    description: 'A field has many sensors',
  },
  // Field -> IrrigationSchedule
  {
    sourceService: 'field-service',
    sourceEntity: 'Field',
    targetService: 'irrigation-service',
    targetEntity: 'IrrigationSchedule',
    foreignKey: 'field_id',
    relationship: 'one-to-many',
    description: 'A field has many irrigation schedules',
  },
  // Field -> IrrigationZone
  {
    sourceService: 'field-service',
    sourceEntity: 'Field',
    targetService: 'irrigation-service',
    targetEntity: 'IrrigationZone',
    foreignKey: 'field_id',
    relationship: 'one-to-many',
    description: 'A field has many irrigation zones',
  },
  // Field -> PestPrediction
  {
    sourceService: 'field-service',
    sourceEntity: 'Field',
    targetService: 'pest-service',
    targetEntity: 'PestPrediction',
    foreignKey: 'field_id',
    relationship: 'one-to-many',
    description: 'A field has many pest predictions',
  },
  // Field -> YieldRecord
  {
    sourceService: 'field-service',
    sourceEntity: 'Field',
    targetService: 'yield-service',
    targetEntity: 'YieldRecord',
    foreignKey: 'field_id',
    relationship: 'one-to-many',
    description: 'A field has many yield records',
  },
  // Field -> TraceabilityRecord
  {
    sourceService: 'field-service',
    sourceEntity: 'Field',
    targetService: 'traceability-service',
    targetEntity: 'TraceabilityRecord',
    foreignKey: 'field_id',
    relationship: 'one-to-many',
    description: 'A field has many traceability records',
  },
  // Field -> SatelliteImage
  {
    sourceService: 'field-service',
    sourceEntity: 'Field',
    targetService: 'satellite-service',
    targetEntity: 'SatelliteImage',
    foreignKey: 'field_id',
    relationship: 'one-to-many',
    description: 'A field has many satellite images',
  },
  // Crop -> FieldCropAssignment
  {
    sourceService: 'crop-service',
    sourceEntity: 'Crop',
    targetService: 'field-service',
    targetEntity: 'FieldCropAssignment',
    foreignKey: 'crop_id',
    relationship: 'one-to-many',
    description: 'A crop can be assigned to many fields',
  },
  // Crop -> CropVariety
  {
    sourceService: 'crop-service',
    sourceEntity: 'Crop',
    targetService: 'crop-service',
    targetEntity: 'CropVariety',
    foreignKey: 'crop_id',
    relationship: 'one-to-many',
    description: 'A crop has many varieties',
  },
  // Crop -> CropRequirements
  {
    sourceService: 'crop-service',
    sourceEntity: 'Crop',
    targetService: 'crop-service',
    targetEntity: 'CropRequirements',
    foreignKey: 'crop_id',
    relationship: 'one-to-one',
    description: 'A crop has one set of requirements',
  },
  // Crop -> PestPrediction
  {
    sourceService: 'crop-service',
    sourceEntity: 'Crop',
    targetService: 'pest-service',
    targetEntity: 'PestPrediction',
    foreignKey: 'crop_id',
    relationship: 'one-to-many',
    description: 'A crop has many pest predictions',
  },
  // Crop -> YieldRecord
  {
    sourceService: 'crop-service',
    sourceEntity: 'Crop',
    targetService: 'yield-service',
    targetEntity: 'YieldRecord',
    foreignKey: 'crop_id',
    relationship: 'one-to-many',
    description: 'A crop has many yield records',
  },
  // Crop -> TraceabilityRecord
  {
    sourceService: 'crop-service',
    sourceEntity: 'Crop',
    targetService: 'traceability-service',
    targetEntity: 'TraceabilityRecord',
    foreignKey: 'crop_id',
    relationship: 'one-to-many',
    description: 'A crop has many traceability records',
  },
  // SoilSample -> SoilAnalysis
  {
    sourceService: 'soil-service',
    sourceEntity: 'SoilSample',
    targetService: 'soil-service',
    targetEntity: 'SoilAnalysis',
    foreignKey: 'sample_id',
    relationship: 'one-to-many',
    description: 'A soil sample has many analyses',
  },
  // Sensor -> AlertRule
  {
    sourceService: 'sensor-service',
    sourceEntity: 'Sensor',
    targetService: 'sensor-service',
    targetEntity: 'AlertRule',
    foreignKey: 'sensor_id',
    relationship: 'one-to-many',
    description: 'A sensor has many alert rules',
  },
  // Sensor -> SensorCalibration
  {
    sourceService: 'sensor-service',
    sourceEntity: 'Sensor',
    targetService: 'sensor-service',
    targetEntity: 'SensorCalibration',
    foreignKey: 'sensor_id',
    relationship: 'one-to-many',
    description: 'A sensor has many calibration records',
  },
  // Sensor -> SensorReading
  {
    sourceService: 'sensor-service',
    sourceEntity: 'Sensor',
    targetService: 'sensor-service',
    targetEntity: 'SensorReading',
    foreignKey: 'sensor_id',
    relationship: 'one-to-many',
    description: 'A sensor produces many readings',
  },
  // IrrigationZone -> IrrigationSchedule
  {
    sourceService: 'irrigation-service',
    sourceEntity: 'IrrigationZone',
    targetService: 'irrigation-service',
    targetEntity: 'IrrigationSchedule',
    foreignKey: 'zone_id',
    relationship: 'one-to-many',
    description: 'An irrigation zone has many schedules',
  },
  // IrrigationController -> IrrigationZone
  {
    sourceService: 'irrigation-service',
    sourceEntity: 'IrrigationController',
    targetService: 'irrigation-service',
    targetEntity: 'IrrigationZone',
    foreignKey: 'controller_id',
    relationship: 'one-to-many',
    description: 'A controller manages many irrigation zones',
  },
  // PestPrediction -> TreatmentPlan
  {
    sourceService: 'pest-service',
    sourceEntity: 'PestPrediction',
    targetService: 'pest-service',
    targetEntity: 'TreatmentPlan',
    foreignKey: 'prediction_id',
    relationship: 'one-to-many',
    description: 'A pest prediction has many treatment plans',
  },
  // TraceabilityRecord -> Certification
  {
    sourceService: 'traceability-service',
    sourceEntity: 'TraceabilityRecord',
    targetService: 'traceability-service',
    targetEntity: 'Certification',
    foreignKey: 'record_id',
    relationship: 'one-to-many',
    description: 'A traceability record has many certifications',
  },
  // TraceabilityRecord -> SupplyChainEvent
  {
    sourceService: 'traceability-service',
    sourceEntity: 'TraceabilityRecord',
    targetService: 'traceability-service',
    targetEntity: 'SupplyChainEvent',
    foreignKey: 'record_id',
    relationship: 'one-to-many',
    description: 'A traceability record has many supply chain events',
  },
];
