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
  AlertService,
  FieldAnalyticsService,
  PrescriptionService,
  AgronomyAssistantService,
  WeatherService,
  CommerceService,
  TaskService,
  MarketService,
  DeviceService,
  FinanceService,
  PlanningService,
  SoilLabService,
  SustainabilityService,
  InspectionService,
  AgronomyAdvisoryService,
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

/** Alert management, rules, field risk scoring, alert history */
export const alertClient: Client<typeof AlertService> =
  createClient(AlertService, createServiceTransport('alert'));

/** Field-level historical analytics, yield trends, season comparisons, rotation analysis */
export const fieldAnalyticsClient: Client<typeof FieldAnalyticsService> =
  createClient(FieldAnalyticsService, createServiceTransport('field-analytics'));

/** Prescription maps, variable-rate application, zone management */
export const prescriptionClient: Client<typeof PrescriptionService> =
  createClient(PrescriptionService, createServiceTransport('prescription'));

/**
 * The agronomy assistant: grounded answers with citations, the review queue
 * and the reference corpus.
 *
 * Exported as AgronomyAssistantService because agronomy-service also declares
 * a service called AdvisoryService, in a different proto package. Two
 * descriptors with the same bare name in one import list is a mistake waiting
 * to be made silently.
 */
export const advisoryClient: Client<typeof AgronomyAssistantService> =
  createClient(AgronomyAssistantService, createServiceTransport('advisory'));

// ─── The eleven that had no client ──────────────────────────────────────────
//
// Each of these services is built, deployed, routed by the gateway and has a
// generated descriptor. None of them had a line here, so from the web app they
// did not exist — including the two E-023 services whose whole point is that a
// farmer can see a price and place an order.
//
// Nothing in the build could have said so. An absent client is not an error;
// it is a page nobody wrote. scripts/check-proto-barrel.py now fails when a
// generated module is not re-exported, which is the step before this one.

/** Field weather, forecasts, and derived agromet metrics (GDD, ET0, chill hours) */
export const weatherClient: Client<typeof WeatherService> =
  createClient(WeatherService, createServiceTransport('weather'));

/** Marketplace listings, orders, and settlement */
export const commerceClient: Client<typeof CommerceService> =
  createClient(CommerceService, createServiceTransport('commerce'));

/** Field tasks, assignment, and completion */
export const taskClient: Client<typeof TaskService> =
  createClient(TaskService, createServiceTransport('task'));

/** Mandi prices, price history, and market advisories */
export const marketClient: Client<typeof MarketService> =
  createClient(MarketService, createServiceTransport('market'));

/** Farm equipment and IoT device registry, telemetry, and commands */
export const deviceClient: Client<typeof DeviceService> =
  createClient(DeviceService, createServiceTransport('device'));

/** Farm finance — costs, revenue, margins, and season profitability */
export const financeClient: Client<typeof FinanceService> =
  createClient(FinanceService, createServiceTransport('finance'));

/** Season planning, crop calendars, and rotation plans */
export const planningClient: Client<typeof PlanningService> =
  createClient(PlanningService, createServiceTransport('planning'));

/** Soil laboratory orders, sample tracking, and lab results */
export const soilLabClient: Client<typeof SoilLabService> =
  createClient(SoilLabService, createServiceTransport('soil-lab'));

/** Sustainability — carbon, water footprint, certifications, practice logs */
export const sustainabilityClient: Client<typeof SustainabilityService> =
  createClient(SustainabilityService, createServiceTransport('sustainability'));

/** Field inspections — drafts, edits and submission */
export const inspectionClient: Client<typeof InspectionService> =
  createClient(InspectionService, createServiceTransport('agronomy'));

/**
 * Crop advisories kept by agronomy-service.
 *
 * Not `advisoryClient` above, which is the assistant that answers questions.
 * Two services named AdvisoryService in two proto packages; the names here say
 * which is which so a call site cannot pick the wrong one by accident.
 */
export const agronomyAdvisoryClient: Client<typeof AgronomyAdvisoryService> =
  createClient(AgronomyAdvisoryService, createServiceTransport('agronomy'));
