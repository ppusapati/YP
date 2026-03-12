/**
 * Agriculture Service Layer — ConnectRPC Clients
 *
 * Typed service clients generated from proto definitions, using ConnectRPC
 * transport to communicate with Go backend microservices.
 */
import { createClient, type Client } from '@connectrpc/connect';
import { createServiceTransport } from '../api/transport';

import {
  CropService,
  FarmService,
  FieldService,
  SoilService,
  SensorService,
  IrrigationService,
  SatelliteService,
  PestPredictionService,
  PlantDiagnosisService,
  YieldService,
  TraceabilityService,
} from '@samavāya/proto';

// ─── ConnectRPC Service Clients ──────────────────────────────────────────────

/** Crop CRUD + varieties, growth stages, requirements, recommendations */
export const cropClient: Client<typeof CropService> =
  createClient(CropService, createServiceTransport('crop'));

/** Farm CRUD + boundaries, ownership */
export const farmClient: Client<typeof FarmService> =
  createClient(FarmService, createServiceTransport('farm'));

/** Field CRUD + boundaries, crop assignment, segmentation, crop history */
export const fieldClient: Client<typeof FieldService> =
  createClient(FieldService, createServiceTransport('field'));

/** Soil sample CRUD + analysis, health scores, nutrient levels, reports */
export const soilClient: Client<typeof SoilService> =
  createClient(SoilService, createServiceTransport('soil'));

/** Sensor registration, readings, alerts, networks, calibration */
export const sensorClient: Client<typeof SensorService> =
  createClient(SensorService, createServiceTransport('sensor'));

/** Irrigation schedules, zones, controllers, decisions, water usage */
export const irrigationClient: Client<typeof IrrigationService> =
  createClient(IrrigationService, createServiceTransport('irrigation'));

/** Satellite imagery, vegetation indices, crop stress, temporal analysis */
export const satelliteClient: Client<typeof SatelliteService> =
  createClient(SatelliteService, createServiceTransport('satellite'));

/** Pest risk prediction, observations, species, treatment plans, alerts */
export const pestClient: Client<typeof PestPredictionService> =
  createClient(PestPredictionService, createServiceTransport('pest'));

/** Plant diagnosis, disease info, nutrient deficiency, pest damage detection */
export const diagnosisClient: Client<typeof PlantDiagnosisService> =
  createClient(PlantDiagnosisService, createServiceTransport('diagnosis'));

/** Yield prediction, records, harvest plans, crop performance */
export const yieldClient: Client<typeof YieldService> =
  createClient(YieldService, createServiceTransport('yield'));

/** Traceability records, certifications, batches, QR codes, compliance */
export const traceabilityClient: Client<typeof TraceabilityService> =
  createClient(TraceabilityService, createServiceTransport('traceability'));
