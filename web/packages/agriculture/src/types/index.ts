/**
 * Agriculture Domain Types
 *
 * TypeScript interfaces for all agriculture backend entities,
 * mapped from the Go protobuf service definitions.
 */

// ─── Farm Service ────────────────────────────────────────────────────────────

export interface Farm {
  id: string;
  tenant_id: string;
  name: string;
  code: string;
  description: string;
  farm_type: string;
  total_area: number;
  area_unit: string;
  address: string;
  city: string;
  state: string;
  country: string;
  postal_code: string;
  latitude: number;
  longitude: number;
  altitude: number;
  climate_zone: string;
  soil_type: string;
  water_source: string;
  owner_name: string;
  owner_contact: string;
  manager_name: string;
  manager_contact: string;
  establishment_date: string;
  status: string;
  tags: string[];
  metadata: Record<string, string>;
  created_at: string;
  updated_at: string;
}

// ─── Crop Service ────────────────────────────────────────────────────────────

export interface Crop {
  id: string;
  tenant_id: string;
  name: string;
  scientific_name: string;
  code: string;
  category: string;
  crop_type: string;
  season: string;
  growth_duration_days: number;
  optimal_temp_min: number;
  optimal_temp_max: number;
  optimal_humidity_min: number;
  optimal_humidity_max: number;
  water_requirement_mm: number;
  soil_ph_min: number;
  soil_ph_max: number;
  description: string;
  image_url: string;
  status: string;
  tags: string[];
  created_at: string;
  updated_at: string;
}

export interface CropVariety {
  id: string;
  crop_id: string;
  name: string;
  code: string;
  description: string;
  maturity_days: number;
  yield_potential: number;
  yield_unit: string;
  disease_resistance: string[];
  special_traits: string[];
  status: string;
  created_at: string;
  updated_at: string;
}

// ─── Field Service ───────────────────────────────────────────────────────────

export interface Field {
  id: string;
  tenant_id: string;
  farm_id: string;
  name: string;
  code: string;
  area: number;
  area_unit: string;
  soil_type: string;
  irrigation_type: string;
  current_crop_id: string;
  current_crop_name: string;
  status: string;
  latitude: number;
  longitude: number;
  elevation: number;
  slope: number;
  aspect: string;
  drainage_class: string;
  land_use_type: string;
  tags: string[];
  metadata: Record<string, string>;
  created_at: string;
  updated_at: string;
}

// ─── Soil Service ────────────────────────────────────────────────────────────

export interface SoilSample {
  id: string;
  tenant_id: string;
  field_id: string;
  sample_date: string;
  sample_depth_cm: number;
  latitude: number;
  longitude: number;
  ph: number;
  organic_matter_pct: number;
  nitrogen_ppm: number;
  phosphorus_ppm: number;
  potassium_ppm: number;
  calcium_ppm: number;
  magnesium_ppm: number;
  sulfur_ppm: number;
  iron_ppm: number;
  zinc_ppm: number;
  manganese_ppm: number;
  copper_ppm: number;
  boron_ppm: number;
  texture_class: string;
  sand_pct: number;
  silt_pct: number;
  clay_pct: number;
  cec: number;
  moisture_pct: number;
  electrical_conductivity: number;
  lab_name: string;
  lab_report_id: string;
  notes: string;
  status: string;
  created_at: string;
  updated_at: string;
}

// ─── Irrigation Service ─────────────────────────────────────────────────────

export interface IrrigationSchedule {
  id: string;
  tenant_id: string;
  field_id: string;
  zone_id: string;
  schedule_name: string;
  schedule_type: string;
  start_time: string;
  duration_minutes: number;
  interval_hours: number;
  water_volume_liters: number;
  flow_rate_lph: number;
  days_of_week: string[];
  start_date: string;
  end_date: string;
  is_active: boolean;
  priority: number;
  trigger_condition: string;
  moisture_threshold: number;
  temperature_threshold: number;
  notes: string;
  status: string;
  created_at: string;
  updated_at: string;
}

export interface IrrigationZone {
  id: string;
  tenant_id: string;
  field_id: string;
  name: string;
  code: string;
  area: number;
  area_unit: string;
  irrigation_method: string;
  controller_id: string;
  valve_number: number;
  emitter_count: number;
  emitter_flow_rate: number;
  status: string;
  created_at: string;
  updated_at: string;
}

// ─── Sensor Service ──────────────────────────────────────────────────────────

export interface Sensor {
  id: string;
  tenant_id: string;
  field_id: string;
  name: string;
  code: string;
  sensor_type: string;
  manufacturer: string;
  model: string;
  serial_number: string;
  firmware_version: string;
  latitude: number;
  longitude: number;
  installation_date: string;
  last_reading_at: string;
  battery_level: number;
  signal_strength: number;
  reading_interval_seconds: number;
  unit_of_measurement: string;
  min_value: number;
  max_value: number;
  calibration_date: string;
  network_id: string;
  status: string;
  tags: string[];
  created_at: string;
  updated_at: string;
}

export interface SensorReading {
  id: string;
  sensor_id: string;
  timestamp: string;
  value: number;
  unit: string;
  quality: string;
  battery_level: number;
  signal_strength: number;
}

export interface SensorAlert {
  id: string;
  sensor_id: string;
  alert_type: string;
  severity: string;
  message: string;
  value: number;
  threshold: number;
  triggered_at: string;
  acknowledged_at: string;
  resolved_at: string;
  status: string;
}

// ─── Satellite Service ───────────────────────────────────────────────────────

export interface SatelliteImage {
  id: string;
  tenant_id: string;
  field_id: string;
  capture_date: string;
  satellite_name: string;
  image_type: string;
  resolution_meters: number;
  cloud_cover_pct: number;
  image_url: string;
  thumbnail_url: string;
  bbox_north: number;
  bbox_south: number;
  bbox_east: number;
  bbox_west: number;
  ndvi_mean: number;
  ndwi_mean: number;
  evi_mean: number;
  status: string;
  created_at: string;
  updated_at: string;
}

export interface VegetationIndex {
  id: string;
  image_id: string;
  field_id: string;
  index_type: string;
  calculation_date: string;
  mean_value: number;
  min_value: number;
  max_value: number;
  std_deviation: number;
  histogram_url: string;
  heatmap_url: string;
  status: string;
}

// ─── Pest Prediction Service ─────────────────────────────────────────────────

export interface PestPrediction {
  id: string;
  tenant_id: string;
  field_id: string;
  crop_id: string;
  pest_species_id: string;
  pest_name: string;
  prediction_date: string;
  risk_level: string;
  probability: number;
  confidence: number;
  predicted_onset_date: string;
  predicted_peak_date: string;
  affected_area_pct: number;
  weather_factors: string;
  recommended_actions: string[];
  model_version: string;
  status: string;
  created_at: string;
  updated_at: string;
}

export interface PestObservation {
  id: string;
  tenant_id: string;
  field_id: string;
  pest_species_id: string;
  pest_name: string;
  observation_date: string;
  severity: string;
  affected_area_pct: number;
  lifecycle_stage: string;
  population_density: number;
  damage_type: string;
  image_urls: string[];
  latitude: number;
  longitude: number;
  observer_name: string;
  notes: string;
  status: string;
  created_at: string;
  updated_at: string;
}

// ─── Plant Diagnosis Service ─────────────────────────────────────────────────

export interface DiagnosisRequest {
  id: string;
  tenant_id: string;
  field_id: string;
  crop_id: string;
  crop_name: string;
  symptom_description: string;
  affected_plant_part: string;
  severity: string;
  onset_date: string;
  spread_rate: string;
  image_urls: string[];
  latitude: number;
  longitude: number;
  temperature: number;
  humidity: number;
  submitted_by: string;
  status: string;
  created_at: string;
  updated_at: string;
}

export interface DiagnosisResult {
  id: string;
  request_id: string;
  disease_name: string;
  disease_code: string;
  confidence: number;
  description: string;
  cause: string;
  symptoms: string[];
  treatment_recommendations: string[];
  prevention_measures: string[];
  chemical_treatments: string[];
  organic_treatments: string[];
  severity_assessment: string;
  estimated_yield_loss_pct: number;
  model_version: string;
  diagnosed_at: string;
}

// ─── Yield Service ───────────────────────────────────────────────────────────

export interface YieldPrediction {
  id: string;
  tenant_id: string;
  field_id: string;
  crop_id: string;
  crop_name: string;
  prediction_date: string;
  predicted_yield: number;
  yield_unit: string;
  confidence_lower: number;
  confidence_upper: number;
  confidence_level: number;
  factors: string[];
  weather_impact_pct: number;
  soil_impact_pct: number;
  pest_impact_pct: number;
  irrigation_impact_pct: number;
  model_version: string;
  status: string;
  created_at: string;
  updated_at: string;
}

export interface YieldRecord {
  id: string;
  tenant_id: string;
  field_id: string;
  crop_id: string;
  crop_name: string;
  harvest_date: string;
  actual_yield: number;
  yield_unit: string;
  area_harvested: number;
  area_unit: string;
  quality_grade: string;
  moisture_content_pct: number;
  storage_location: string;
  harvest_method: string;
  labor_hours: number;
  cost_per_unit: number;
  market_price_per_unit: number;
  notes: string;
  status: string;
  created_at: string;
  updated_at: string;
}

export interface HarvestPlan {
  id: string;
  tenant_id: string;
  field_id: string;
  crop_id: string;
  crop_name: string;
  planned_start_date: string;
  planned_end_date: string;
  estimated_yield: number;
  yield_unit: string;
  harvest_method: string;
  equipment_required: string[];
  labor_required: number;
  storage_plan: string;
  transportation_plan: string;
  quality_targets: string;
  priority: number;
  notes: string;
  status: string;
  created_at: string;
  updated_at: string;
}

// ─── Traceability Service ────────────────────────────────────────────────────

export interface TraceabilityRecord {
  id: string;
  tenant_id: string;
  batch_id: string;
  product_name: string;
  product_code: string;
  origin_farm_id: string;
  origin_farm_name: string;
  origin_field_id: string;
  harvest_date: string;
  processing_date: string;
  expiry_date: string;
  quantity: number;
  unit: string;
  quality_grade: string;
  certification_ids: string[];
  supply_chain_events: string[];
  current_location: string;
  current_holder: string;
  qr_code_url: string;
  blockchain_hash: string;
  status: string;
  tags: string[];
  created_at: string;
  updated_at: string;
}

export interface Certification {
  id: string;
  tenant_id: string;
  name: string;
  code: string;
  certifying_body: string;
  certification_type: string;
  scope: string;
  issue_date: string;
  expiry_date: string;
  certificate_number: string;
  certificate_url: string;
  status: string;
  created_at: string;
  updated_at: string;
}

export interface BatchRecord {
  id: string;
  tenant_id: string;
  batch_number: string;
  product_name: string;
  product_code: string;
  quantity: number;
  unit: string;
  production_date: string;
  expiry_date: string;
  source_farm_id: string;
  source_field_id: string;
  processing_facility: string;
  quality_check_status: string;
  quality_score: number;
  storage_conditions: string;
  notes: string;
  status: string;
  created_at: string;
  updated_at: string;
}

// ─── Common Types ────────────────────────────────────────────────────────────

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  page_size: number;
  total_pages: number;
}

export interface ListParams {
  page?: number;
  page_size?: number;
  sort_by?: string;
  sort_order?: 'asc' | 'desc';
  search?: string;
  filters?: Record<string, unknown>;
}
