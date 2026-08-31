/**
 * RPC Loader Configurations
 * Defines how dropdown fields are populated from gRPC service calls at runtime.
 * The FormRenderer component uses these configs to wire up data fetching for select fields.
 */

export interface RpcLoaderConfig {
  id: string;
  service: string;
  method: string;
  labelField: string;
  valueField: string;
  dependsOn?: string; // field name this loader depends on
  description: string;
}

export const rpcLoaders: Record<string, RpcLoaderConfig> = {
  farms: {
    id: 'farms',
    service: 'FarmService',
    method: 'ListFarms',
    labelField: 'name',
    valueField: 'id',
    description: 'Load farms for dropdown',
  },
  fields: {
    id: 'fields',
    service: 'FieldService',
    method: 'ListFields',
    labelField: 'name',
    valueField: 'id',
    dependsOn: 'farm_id',
    description: 'Load fields filtered by farm',
  },
  crops: {
    id: 'crops',
    service: 'CropService',
    method: 'ListCrops',
    labelField: 'name',
    valueField: 'id',
    description: 'Load crops for dropdown',
  },
  cropVarieties: {
    id: 'cropVarieties',
    service: 'CropService',
    method: 'ListVarieties',
    labelField: 'name',
    valueField: 'id',
    dependsOn: 'crop_id',
    description: 'Load varieties filtered by crop',
  },
  soilSamples: {
    id: 'soilSamples',
    service: 'SoilService',
    method: 'ListSoilSamples',
    labelField: 'id',
    valueField: 'id',
    dependsOn: 'field_id',
    description: 'Load soil samples for dropdown',
  },
  sensors: {
    id: 'sensors',
    service: 'SensorService',
    method: 'ListSensors',
    labelField: 'name',
    valueField: 'id',
    dependsOn: 'field_id',
    description: 'Load sensors for dropdown',
  },
  irrigationZones: {
    id: 'irrigationZones',
    service: 'IrrigationService',
    method: 'ListZones',
    labelField: 'name',
    valueField: 'id',
    dependsOn: 'field_id',
    description: 'Load irrigation zones',
  },
  controllers: {
    id: 'controllers',
    service: 'IrrigationService',
    method: 'ListControllers',
    labelField: 'name',
    valueField: 'id',
    description: 'Load irrigation controllers',
  },
};
