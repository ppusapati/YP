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
  SatelliteIngestionService,
  SatelliteProcessingService,
  SatelliteAnalyticsService,
  SatelliteTileService,
  VegetationIndexService,
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

/** Satellite data ingestion — download, validate, store imagery */
export const ingestionClient: Client<typeof SatelliteIngestionService> =
  createClient(SatelliteIngestionService, createServiceTransport('satellite-ingestion'));

/** Satellite image processing — atmospheric correction, cloud masking, orthorectification */
export const processingClient: Client<typeof SatelliteProcessingService> =
  createClient(SatelliteProcessingService, createServiceTransport('satellite-processing'));

/** Satellite analytics — stress detection, temporal analysis, field summaries */
export const analyticsClient: Client<typeof SatelliteAnalyticsService> =
  createClient(SatelliteAnalyticsService, createServiceTransport('satellite-analytics'));

/** Map tile generation and serving for satellite layers */
export const tileClient: Client<typeof SatelliteTileService> =
  createClient(SatelliteTileService, createServiceTransport('satellite-tile'));

/** Vegetation index computation — NDVI, NDWI, EVI, SAVI, time series */
export const vegetationIndexClient: Client<typeof VegetationIndexService> =
  createClient(VegetationIndexService, createServiceTransport('vegetation-index'));

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
