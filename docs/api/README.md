# YieldPoint API Documentation

API documentation for the YieldPoint agriculture platform, generated from protobuf service definitions.

All services use [ConnectRPC](https://connectrpc.com/) over HTTP. Every RPC is a `POST` request
with a JSON body sent to `/<package>.<Service>/<Method>`. Responses are JSON.

## Services

| # | Service | Port | Proto Package | Spec |
|---|---------|------|---------------|------|
| 1 | **Farm Service** | 8080 | `agriculture.farm.v1` | [farm-service.yaml](farm-service.yaml) |
| 2 | **Field Service** | 8081 | `agriculture.field.v1` | [field-service.yaml](field-service.yaml) |
| 3 | **Crop Service** | 8082 | `agriculture.crop.v1` | [crop-service.yaml](crop-service.yaml) |
| 4 | **Sensor Service** | 8083 | `agriculture.sensor.v1` | [sensor-service.yaml](sensor-service.yaml) |
| 5 | **Irrigation Service** | 8084 | `agriculture.irrigation.v1` | [irrigation-service.yaml](irrigation-service.yaml) |
| 6 | **Soil Service** | 8085 | `agriculture.soil.v1` | [soil-service.yaml](soil-service.yaml) |
| 7 | **Yield Service** | 8086 | `agriculture.yield.v1` | [yield-service.yaml](yield-service.yaml) |
| 8 | **Pest Prediction Service** | 8087 | `agriculture.pest.v1` | [pest-prediction-service.yaml](pest-prediction-service.yaml) |
| 9 | **Plant Diagnosis Service** | 8088 | `agriculture.diagnosis.v1` | [plant-diagnosis-service.yaml](plant-diagnosis-service.yaml) |
| 10 | **Satellite Analytics Service** | 8089 | `agriculture.satellite.analytics.v1` | [satellite-analytics-service.yaml](satellite-analytics-service.yaml) |
| 11 | **Traceability Service** | 8090 | `agriculture.traceability.v1` | [traceability-service.yaml](traceability-service.yaml) |
| 12 | **Commerce Service** | 8092 | `agriculture.commerce.v1` | [commerce-service.yaml](commerce-service.yaml) |

## Endpoint Reference

### Farm Service (port 8080)

| RPC | Endpoint | Description |
|-----|----------|-------------|
| CreateFarm | `POST /agriculture.farm.v1.FarmService/CreateFarm` | Create a new farm |
| GetFarm | `POST /agriculture.farm.v1.FarmService/GetFarm` | Get farm by ID |
| ListFarms | `POST /agriculture.farm.v1.FarmService/ListFarms` | List farms with filtering |
| UpdateFarm | `POST /agriculture.farm.v1.FarmService/UpdateFarm` | Update a farm |
| DeleteFarm | `POST /agriculture.farm.v1.FarmService/DeleteFarm` | Delete a farm |
| SetFarmBoundary | `POST /agriculture.farm.v1.FarmService/SetFarmBoundary` | Set farm boundary (GeoJSON) |
| GetFarmBoundary | `POST /agriculture.farm.v1.FarmService/GetFarmBoundary` | Get farm boundary |
| TransferOwnership | `POST /agriculture.farm.v1.FarmService/TransferOwnership` | Transfer farm ownership |
| CreateManagementUnit | `POST /agriculture.farm.v1.FarmService/CreateManagementUnit` | Create management unit |
| GetManagementUnit | `POST /agriculture.farm.v1.FarmService/GetManagementUnit` | Get management unit |
| ListManagementUnits | `POST /agriculture.farm.v1.FarmService/ListManagementUnits` | List management units |
| UpdateManagementUnit | `POST /agriculture.farm.v1.FarmService/UpdateManagementUnit` | Update management unit |
| DeleteManagementUnit | `POST /agriculture.farm.v1.FarmService/DeleteManagementUnit` | Delete management unit |
| AssignFieldsToUnit | `POST /agriculture.farm.v1.FarmService/AssignFieldsToUnit` | Assign fields to unit |
| RemoveFieldsFromUnit | `POST /agriculture.farm.v1.FarmService/RemoveFieldsFromUnit` | Remove fields from unit |

### Field Service (port 8081)

| RPC | Endpoint | Description |
|-----|----------|-------------|
| CreateField | `POST /agriculture.field.v1.FieldService/CreateField` | Create a field |
| GetField | `POST /agriculture.field.v1.FieldService/GetField` | Get field by ID |
| ListFields | `POST /agriculture.field.v1.FieldService/ListFields` | List fields with filtering |
| UpdateField | `POST /agriculture.field.v1.FieldService/UpdateField` | Update a field |
| DeleteField | `POST /agriculture.field.v1.FieldService/DeleteField` | Delete a field |
| SetFieldBoundary | `POST /agriculture.field.v1.FieldService/SetFieldBoundary` | Set field boundary |
| AssignCrop | `POST /agriculture.field.v1.FieldService/AssignCrop` | Assign crop to field |
| ListFieldsByFarm | `POST /agriculture.field.v1.FieldService/ListFieldsByFarm` | List fields by farm |
| SegmentField | `POST /agriculture.field.v1.FieldService/SegmentField` | Divide field into segments |
| GetFieldSegments | `POST /agriculture.field.v1.FieldService/GetFieldSegments` | Get field segments |
| GetCropHistory | `POST /agriculture.field.v1.FieldService/GetCropHistory` | Get crop assignment history |
| CreateCropCycle | `POST /agriculture.field.v1.FieldService/CreateCropCycle` | Create crop cycle |
| GetCropCycle | `POST /agriculture.field.v1.FieldService/GetCropCycle` | Get crop cycle |
| ListCropCycles | `POST /agriculture.field.v1.FieldService/ListCropCycles` | List crop cycles |
| UpdateCropCycle | `POST /agriculture.field.v1.FieldService/UpdateCropCycle` | Update crop cycle |
| LogActivityEvent | `POST /agriculture.field.v1.FieldService/LogActivityEvent` | Log activity event |
| ListActivityEvents | `POST /agriculture.field.v1.FieldService/ListActivityEvents` | List activity events |
| AddActivityEvidence | `POST /agriculture.field.v1.FieldService/AddActivityEvidence` | Add evidence to activity |
| ListActivityEvidence | `POST /agriculture.field.v1.FieldService/ListActivityEvidence` | List activity evidence |
| DeleteActivityEvidence | `POST /agriculture.field.v1.FieldService/DeleteActivityEvidence` | Delete evidence |

### Crop Service (port 8082)

| RPC | Endpoint | Description |
|-----|----------|-------------|
| CreateCrop | `POST /agriculture.crop.v1.CropService/CreateCrop` | Create crop in catalog |
| GetCrop | `POST /agriculture.crop.v1.CropService/GetCrop` | Get crop by ID |
| ListCrops | `POST /agriculture.crop.v1.CropService/ListCrops` | List crops |
| UpdateCrop | `POST /agriculture.crop.v1.CropService/UpdateCrop` | Update crop |
| DeleteCrop | `POST /agriculture.crop.v1.CropService/DeleteCrop` | Delete crop |
| AddVariety | `POST /agriculture.crop.v1.CropService/AddVariety` | Add variety to crop |
| ListVarieties | `POST /agriculture.crop.v1.CropService/ListVarieties` | List crop varieties |
| GetGrowthStages | `POST /agriculture.crop.v1.CropService/GetGrowthStages` | Get growth stages |
| GetCropRequirements | `POST /agriculture.crop.v1.CropService/GetCropRequirements` | Get growing requirements |
| GenerateRecommendation | `POST /agriculture.crop.v1.CropService/GenerateRecommendation` | AI recommendation |

### Sensor Service (port 8083)

| RPC | Endpoint | Description |
|-----|----------|-------------|
| RegisterSensor | `POST /agriculture.sensor.v1.SensorService/RegisterSensor` | Register IoT sensor |
| GetSensor | `POST /agriculture.sensor.v1.SensorService/GetSensor` | Get sensor by ID |
| ListSensors | `POST /agriculture.sensor.v1.SensorService/ListSensors` | List sensors |
| UpdateSensor | `POST /agriculture.sensor.v1.SensorService/UpdateSensor` | Update sensor |
| DecommissionSensor | `POST /agriculture.sensor.v1.SensorService/DecommissionSensor` | Decommission sensor |
| IngestReading | `POST /agriculture.sensor.v1.SensorService/IngestReading` | Ingest reading |
| BatchIngestReadings | `POST /agriculture.sensor.v1.SensorService/BatchIngestReadings` | Batch ingest |
| GetLatestReading | `POST /agriculture.sensor.v1.SensorService/GetLatestReading` | Get latest reading |
| GetReadingHistory | `POST /agriculture.sensor.v1.SensorService/GetReadingHistory` | Reading history |
| CreateAlert | `POST /agriculture.sensor.v1.SensorService/CreateAlert` | Create alert rule |
| ListAlerts | `POST /agriculture.sensor.v1.SensorService/ListAlerts` | List alerts |
| AcknowledgeAlert | `POST /agriculture.sensor.v1.SensorService/AcknowledgeAlert` | Acknowledge alert |
| GetSensorNetwork | `POST /agriculture.sensor.v1.SensorService/GetSensorNetwork` | Get sensor network |
| CalibrateSensor | `POST /agriculture.sensor.v1.SensorService/CalibrateSensor` | Calibrate sensor |

### Irrigation Service (port 8084)

| RPC | Endpoint | Description |
|-----|----------|-------------|
| CreateSchedule | `POST /agriculture.irrigation.v1.IrrigationService/CreateSchedule` | Create schedule |
| GetSchedule | `POST /agriculture.irrigation.v1.IrrigationService/GetSchedule` | Get schedule |
| ListSchedules | `POST /agriculture.irrigation.v1.IrrigationService/ListSchedules` | List schedules |
| UpdateSchedule | `POST /agriculture.irrigation.v1.IrrigationService/UpdateSchedule` | Update schedule |
| DeleteSchedule | `POST /agriculture.irrigation.v1.IrrigationService/DeleteSchedule` | Delete schedule |
| GenerateIrrigationDecision | `POST /agriculture.irrigation.v1.IrrigationService/GenerateIrrigationDecision` | AI irrigation decision |
| CreateZone | `POST /agriculture.irrigation.v1.IrrigationService/CreateZone` | Create zone |
| ListZones | `POST /agriculture.irrigation.v1.IrrigationService/ListZones` | List zones |
| RegisterController | `POST /agriculture.irrigation.v1.IrrigationService/RegisterController` | Register controller |
| ListControllers | `POST /agriculture.irrigation.v1.IrrigationService/ListControllers` | List controllers |
| TriggerIrrigation | `POST /agriculture.irrigation.v1.IrrigationService/TriggerIrrigation` | Trigger irrigation |
| StopIrrigation | `POST /agriculture.irrigation.v1.IrrigationService/StopIrrigation` | Stop irrigation |
| GetWaterUsage | `POST /agriculture.irrigation.v1.IrrigationService/GetWaterUsage` | Get water usage |
| GetIrrigationHistory | `POST /agriculture.irrigation.v1.IrrigationService/GetIrrigationHistory` | Irrigation history |

### Soil Service (port 8085)

| RPC | Endpoint | Description |
|-----|----------|-------------|
| CreateSoilSample | `POST /agriculture.soil.v1.SoilService/CreateSoilSample` | Create soil sample |
| GetSoilSample | `POST /agriculture.soil.v1.SoilService/GetSoilSample` | Get soil sample |
| ListSoilSamples | `POST /agriculture.soil.v1.SoilService/ListSoilSamples` | List soil samples |
| AnalyzeSoil | `POST /agriculture.soil.v1.SoilService/AnalyzeSoil` | Trigger soil analysis |
| ListSoilAnalyses | `POST /agriculture.soil.v1.SoilService/ListSoilAnalyses` | List analyses |
| GetSoilMap | `POST /agriculture.soil.v1.SoilService/GetSoilMap` | Get soil property map |
| GetSoilHealth | `POST /agriculture.soil.v1.SoilService/GetSoilHealth` | Get soil health score |
| GetNutrientLevels | `POST /agriculture.soil.v1.SoilService/GetNutrientLevels` | Get nutrient levels |
| GenerateSoilReport | `POST /agriculture.soil.v1.SoilService/GenerateSoilReport` | Generate soil report |

### Yield Service (port 8086)

| RPC | Endpoint | Description |
|-----|----------|-------------|
| PredictYield | `POST /agriculture.yield.v1.YieldService/PredictYield` | AI yield prediction |
| GetPrediction | `POST /agriculture.yield.v1.YieldService/GetPrediction` | Get prediction |
| ListPredictions | `POST /agriculture.yield.v1.YieldService/ListPredictions` | List predictions |
| RecordYield | `POST /agriculture.yield.v1.YieldService/RecordYield` | Record harvest yield |
| GetYieldHistory | `POST /agriculture.yield.v1.YieldService/GetYieldHistory` | Get yield history |
| CreateHarvestPlan | `POST /agriculture.yield.v1.YieldService/CreateHarvestPlan` | Create harvest plan |
| GetHarvestPlan | `POST /agriculture.yield.v1.YieldService/GetHarvestPlan` | Get harvest plan |
| ListHarvestPlans | `POST /agriculture.yield.v1.YieldService/ListHarvestPlans` | List harvest plans |
| GetCropPerformance | `POST /agriculture.yield.v1.YieldService/GetCropPerformance` | Crop performance analytics |
| CompareYields | `POST /agriculture.yield.v1.YieldService/CompareYields` | Compare yields across seasons |

### Pest Prediction Service (port 8087)

| RPC | Endpoint | Description |
|-----|----------|-------------|
| PredictPestRisk | `POST /agriculture.pest.v1.PestPredictionService/PredictPestRisk` | Predict pest risk |
| GetPrediction | `POST /agriculture.pest.v1.PestPredictionService/GetPrediction` | Get prediction |
| ListPredictions | `POST /agriculture.pest.v1.PestPredictionService/ListPredictions` | List predictions |
| ReportObservation | `POST /agriculture.pest.v1.PestPredictionService/ReportObservation` | Report observation |
| ListObservations | `POST /agriculture.pest.v1.PestPredictionService/ListObservations` | List observations |
| GetPestSpecies | `POST /agriculture.pest.v1.PestPredictionService/GetPestSpecies` | Get pest species |
| ListPestSpecies | `POST /agriculture.pest.v1.PestPredictionService/ListPestSpecies` | List pest species |
| GetTreatmentPlan | `POST /agriculture.pest.v1.PestPredictionService/GetTreatmentPlan` | Get treatment plan |
| GetRiskMap | `POST /agriculture.pest.v1.PestPredictionService/GetRiskMap` | Get risk map |
| ListAlerts | `POST /agriculture.pest.v1.PestPredictionService/ListAlerts` | List pest alerts |
| AcknowledgeAlert | `POST /agriculture.pest.v1.PestPredictionService/AcknowledgeAlert` | Acknowledge alert |

### Plant Diagnosis Service (port 8088)

| RPC | Endpoint | Description |
|-----|----------|-------------|
| SubmitDiagnosis | `POST /agriculture.diagnosis.v1.PlantDiagnosisService/SubmitDiagnosis` | Submit diagnosis with images |
| GetDiagnosis | `POST /agriculture.diagnosis.v1.PlantDiagnosisService/GetDiagnosis` | Get diagnosis |
| ListDiagnoses | `POST /agriculture.diagnosis.v1.PlantDiagnosisService/ListDiagnoses` | List diagnoses |
| GetDiseaseInfo | `POST /agriculture.diagnosis.v1.PlantDiagnosisService/GetDiseaseInfo` | Get disease info |
| ListDiseases | `POST /agriculture.diagnosis.v1.PlantDiagnosisService/ListDiseases` | List diseases |
| GetTreatmentPlan | `POST /agriculture.diagnosis.v1.PlantDiagnosisService/GetTreatmentPlan` | Get treatment plan |
| IdentifySpecies | `POST /agriculture.diagnosis.v1.PlantDiagnosisService/IdentifySpecies` | Identify species from images |
| DetectNutrientDeficiency | `POST /agriculture.diagnosis.v1.PlantDiagnosisService/DetectNutrientDeficiency` | Detect nutrient deficiency |
| DetectPestDamage | `POST /agriculture.diagnosis.v1.PlantDiagnosisService/DetectPestDamage` | Detect pest damage |

### Satellite Analytics Service (port 8089)

| RPC | Endpoint | Description |
|-----|----------|-------------|
| DetectStress | `POST /agriculture.satellite.analytics.v1.SatelliteAnalyticsService/DetectStress` | Detect crop stress |
| ListStressAlerts | `POST /agriculture.satellite.analytics.v1.SatelliteAnalyticsService/ListStressAlerts` | List stress alerts |
| AcknowledgeAlert | `POST /agriculture.satellite.analytics.v1.SatelliteAnalyticsService/AcknowledgeAlert` | Acknowledge alert |
| RunTemporalAnalysis | `POST /agriculture.satellite.analytics.v1.SatelliteAnalyticsService/RunTemporalAnalysis` | Run temporal analysis |
| GetFieldAnalyticsSummary | `POST /agriculture.satellite.analytics.v1.SatelliteAnalyticsService/GetFieldAnalyticsSummary` | Field analytics summary |

### Traceability Service (port 8090)

| RPC | Endpoint | Description |
|-----|----------|-------------|
| CreateRecord | `POST /agriculture.traceability.v1.TraceabilityService/CreateRecord` | Create traceability record |
| GetRecord | `POST /agriculture.traceability.v1.TraceabilityService/GetRecord` | Get record |
| ListRecords | `POST /agriculture.traceability.v1.TraceabilityService/ListRecords` | List records |
| UpdateRecord | `POST /agriculture.traceability.v1.TraceabilityService/UpdateRecord` | Update record |
| AddSupplyChainEvent | `POST /agriculture.traceability.v1.TraceabilityService/AddSupplyChainEvent` | Add supply chain event |
| GetSupplyChain | `POST /agriculture.traceability.v1.TraceabilityService/GetSupplyChain` | Get full supply chain |
| CreateCertification | `POST /agriculture.traceability.v1.TraceabilityService/CreateCertification` | Create certification |
| GetCertification | `POST /agriculture.traceability.v1.TraceabilityService/GetCertification` | Get certification |
| ListCertifications | `POST /agriculture.traceability.v1.TraceabilityService/ListCertifications` | List certifications |
| VerifyCertification | `POST /agriculture.traceability.v1.TraceabilityService/VerifyCertification` | Verify certification |
| RevokeCertification | `POST /agriculture.traceability.v1.TraceabilityService/RevokeCertification` | Revoke certification |
| CreateBatch | `POST /agriculture.traceability.v1.TraceabilityService/CreateBatch` | Create batch |
| GetBatch | `POST /agriculture.traceability.v1.TraceabilityService/GetBatch` | Get batch |
| ListBatches | `POST /agriculture.traceability.v1.TraceabilityService/ListBatches` | List batches |
| GenerateQRCode | `POST /agriculture.traceability.v1.TraceabilityService/GenerateQRCode` | Generate QR code |
| VerifyQRCode | `POST /agriculture.traceability.v1.TraceabilityService/VerifyQRCode` | Verify QR code |
| GenerateComplianceReport | `POST /agriculture.traceability.v1.TraceabilityService/GenerateComplianceReport` | Generate compliance report |
| GetComplianceReport | `POST /agriculture.traceability.v1.TraceabilityService/GetComplianceReport` | Get compliance report |
| ListComplianceReports | `POST /agriculture.traceability.v1.TraceabilityService/ListComplianceReports` | List compliance reports |
| CreateQualityCheckpoint | `POST /agriculture.traceability.v1.TraceabilityService/CreateQualityCheckpoint` | Create quality checkpoint |
| GetQualityCheckpoint | `POST /agriculture.traceability.v1.TraceabilityService/GetQualityCheckpoint` | Get quality checkpoint |
| ListQualityCheckpoints | `POST /agriculture.traceability.v1.TraceabilityService/ListQualityCheckpoints` | List quality checkpoints |

### Commerce Service (port 8092)

| RPC | Endpoint | Description |
|-----|----------|-------------|
| CreateListing | `POST /agriculture.commerce.v1.CommerceService/CreateListing` | Create listing |
| GetListing | `POST /agriculture.commerce.v1.CommerceService/GetListing` | Get listing |
| ListListings | `POST /agriculture.commerce.v1.CommerceService/ListListings` | List listings |
| UpdateListing | `POST /agriculture.commerce.v1.CommerceService/UpdateListing` | Update listing |
| CancelListing | `POST /agriculture.commerce.v1.CommerceService/CancelListing` | Cancel listing |
| PlaceOrder | `POST /agriculture.commerce.v1.CommerceService/PlaceOrder` | Place order |
| GetOrder | `POST /agriculture.commerce.v1.CommerceService/GetOrder` | Get order |
| ListOrders | `POST /agriculture.commerce.v1.CommerceService/ListOrders` | List orders |
| UpdateOrderStatus | `POST /agriculture.commerce.v1.CommerceService/UpdateOrderStatus` | Update order status |
| UpdatePaymentStatus | `POST /agriculture.commerce.v1.CommerceService/UpdatePaymentStatus` | Update payment status |

## Usage

### ConnectRPC (JSON)

```bash
curl -X POST http://localhost:8080/agriculture.farm.v1.FarmService/ListFarms \
  -H "Content-Type: application/json" \
  -d '{"pageSize": 10}'
```

### Regenerating docs

```bash
make api-docs
```

Or directly:

```bash
./scripts/generate-api-docs.sh
```

## Viewing the specs

You can load any of the `.yaml` files in:

- [Swagger Editor](https://editor.swagger.io/) (paste the YAML)
- [Redocly](https://redocly.github.io/redoc/) (point to a hosted file URL)
- Any OpenAPI-compatible tool
