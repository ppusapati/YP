/// Protobuf generated models and ConnectRPC service stubs for the
/// YieldPoint platform.
///
/// This barrel re-exports every generated message into one flat namespace,
/// which guarantees collisions: services are free to define a message of the
/// same name and 21 names already do. The `hide` clauses below keep the library
/// importable, and the hidden type is still reachable by importing its own
/// generated file directly.
///
/// Until those clauses existed this file did not compile at all, and it
/// accounted for 321 of the mobile monorepo's analyzer errors — everything
/// importing `package:flutter_proto/flutter_proto.dart` inherited them. The
/// datasources work because they import the specific generated file instead.
///
/// The rule applied: the service whose name matches the concept keeps the flat
/// export — alerts to alert-service, treatment plans to plant-diagnosis,
/// VegetationIndex to vegetation-index. Where neither owns it, the first in
/// this list keeps it, which is arbitrary and stated rather than silent.
///
/// The clauses are derived from the generated sources rather than written by
/// hand; regenerate them when a proto adds a name that collides.
library flutter_proto;

// Generated protobuf messages
export 'src/generated/advisory.pb.dart';
export 'src/generated/alert.pb.dart';
export 'src/generated/analytics.pb.dart'
    hide AcknowledgeAlertRequest, AcknowledgeAlertResponse, TemporalAnalysis;
// The agronomy assistant (advisory-service). Two names are withheld from the
// flat namespace:
//
//   AdvisoryServiceApi — agronomy-service's advisory.pb.dart already exports a
//   class of this name, and it is exported first, so it keeps it under the rule
//   above.
//
//   Locale — Flutter's own Locale comes in with material.dart, and a screen
//   importing both would get an ambiguous name with no obvious cause. The
//   advisory enum is reachable by importing the generated file directly, which
//   is what the advisory screen does.
export 'src/generated/assistant.pb.dart'
    hide AdvisoryServiceApi, Locale;
export 'src/generated/crop.pb.dart'
    hide GrowthStage;
export 'src/generated/diagnosis.pb.dart';
export 'src/generated/farm.pb.dart'
    hide SoilType;
export 'src/generated/field.pb.dart';
export 'src/generated/field_analytics.pb.dart';
export 'src/generated/ingestion.pb.dart';
export 'src/generated/inspection.pb.dart';
export 'src/generated/irrigation.pb.dart';
export 'src/generated/pest.pb.dart'
    hide AcknowledgeAlertRequest, AcknowledgeAlertResponse, AlertStatus, GetTreatmentPlanRequest, GetTreatmentPlanResponse, GrowthStage, ListAlertsRequest, ListAlertsResponse;
export 'src/generated/prescription.pb.dart';
export 'src/generated/processing.pb.dart';
export 'src/generated/satellite.pb.dart'
    hide ListAlertsRequest, ListAlertsResponse, ProcessingStatus, SatelliteProvider, SpectralBand, StressType, VegetationIndex;
export 'src/generated/sensor.pb.dart'
    hide AcknowledgeAlertRequest, AcknowledgeAlertResponse, AlertSeverity, ListAlertsRequest, ListAlertsResponse;
export 'src/generated/soil.pb.dart'
    hide NutrientDeficiency;
export 'src/generated/task.pb.dart';
export 'src/generated/tile.pb.dart';
export 'src/generated/traceability.pb.dart';
export 'src/generated/vegetation_index.pb.dart';
export 'src/generated/yield.pb.dart'
    hide GetPredictionRequest, GetPredictionResponse, ListPredictionsRequest, ListPredictionsResponse;

// Service clients
export 'src/services/base_service.dart';
export 'src/services/advisory_service.dart';
export 'src/services/analytics_service.dart';
export 'src/services/crop_service.dart';
export 'src/services/diagnosis_service.dart';
export 'src/services/farm_service.dart';
export 'src/services/field_service.dart';
export 'src/services/ingestion_service.dart';
export 'src/services/irrigation_service.dart';
export 'src/services/pest_service.dart';
export 'src/services/processing_service.dart';
export 'src/services/satellite_service.dart';
export 'src/services/sensor_service.dart';
export 'src/services/soil_service.dart';
export 'src/services/task_service.dart';
export 'src/services/tile_service.dart';
export 'src/services/traceability_service.dart';
export 'src/services/vegetation_index_service.dart';
export 'src/services/yield_service.dart';
