/**
 * Farm Service Form Schemas
 * Based on agriculture.farm.v1 protobuf definitions
 */
import type { FormSchema } from '@samavāya/core';

/** Form for creating a new farm (CreateFarmRequest) */
export const createFarmSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'name', label: 'Farm Name', required: true, placeholder: 'Enter farm name' },
    { type: 'textarea', name: 'description', label: 'Description', rows: 3, placeholder: 'Describe the farm' },
    { type: 'number', name: 'total_area_hectares', label: 'Total Area (hectares)', min: 0, step: 0.01, suffix: 'ha' },
    { type: 'select', name: 'farm_type', label: 'Farm Type', options: [
      { label: 'Crop', value: 'FARM_TYPE_CROP' },
      { label: 'Livestock', value: 'FARM_TYPE_LIVESTOCK' },
      { label: 'Mixed', value: 'FARM_TYPE_MIXED' },
      { label: 'Aquaculture', value: 'FARM_TYPE_AQUACULTURE' },
    ] },
    { type: 'select', name: 'soil_type', label: 'Soil Type', options: [
      { label: 'Clay', value: 'SOIL_TYPE_CLAY' },
      { label: 'Sandy', value: 'SOIL_TYPE_SANDY' },
      { label: 'Loamy', value: 'SOIL_TYPE_LOAMY' },
      { label: 'Silt', value: 'SOIL_TYPE_SILT' },
      { label: 'Peat', value: 'SOIL_TYPE_PEAT' },
      { label: 'Chalky', value: 'SOIL_TYPE_CHALKY' },
      { label: 'Laterite', value: 'SOIL_TYPE_LATERITE' },
      { label: 'Black', value: 'SOIL_TYPE_BLACK' },
      { label: 'Red', value: 'SOIL_TYPE_RED' },
      { label: 'Alluvial', value: 'SOIL_TYPE_ALLUVIAL' },
    ] },
    { type: 'select', name: 'climate_zone', label: 'Climate Zone', options: [
      { label: 'Tropical', value: 'CLIMATE_ZONE_TROPICAL' },
      { label: 'Subtropical', value: 'CLIMATE_ZONE_SUBTROPICAL' },
      { label: 'Arid', value: 'CLIMATE_ZONE_ARID' },
      { label: 'Semi-arid', value: 'CLIMATE_ZONE_SEMIARID' },
      { label: 'Temperate', value: 'CLIMATE_ZONE_TEMPERATE' },
      { label: 'Continental', value: 'CLIMATE_ZONE_CONTINENTAL' },
      { label: 'Polar', value: 'CLIMATE_ZONE_POLAR' },
      { label: 'Mediterranean', value: 'CLIMATE_ZONE_MEDITERRANEAN' },
      { label: 'Monsoon', value: 'CLIMATE_ZONE_MONSOON' },
    ] },
    { type: 'number', name: 'elevation', label: 'Elevation (meters)', step: 0.01, suffix: 'm' },
    { type: 'text', name: 'address', label: 'Address', placeholder: 'Street address' },
    { type: 'text', name: 'region', label: 'Region', placeholder: 'State / Province / Region' },
    { type: 'text', name: 'country', label: 'Country', placeholder: 'Country' },
    { type: 'number', name: 'latitude', label: 'Latitude', min: -90, max: 90, step: 0.000001 },
    { type: 'number', name: 'longitude', label: 'Longitude', min: -180, max: 180, step: 0.000001 },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Farm Details',
        fields: ['name', 'description', 'farm_type', 'soil_type', 'climate_zone'],
        columns: 2,
      },
      {
        id: 'location',
        title: 'Location',
        fields: ['address', 'region', 'country', 'latitude', 'longitude'],
        columns: 2,
      },
      {
        id: 'metrics',
        title: 'Measurements',
        fields: ['total_area_hectares', 'elevation'],
        columns: 2,
      },
    ],
  },
};

/** Form for setting farm boundary (SetFarmBoundaryRequest) */
export const farmBoundarySchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'select', name: 'farm_id', label: 'Farm', required: true, options: [], searchable: true }, // RPC: FarmService.ListFarms
    { type: 'textarea', name: 'geojson', label: 'GeoJSON Boundary', required: true, rows: 12, placeholder: '{"type": "Polygon", "coordinates": [...]}', helperText: 'Paste a valid GeoJSON Polygon representing the farm boundary' },
  ],
  layout: {
    type: 'vertical',
    gap: 'md',
    sections: [
      {
        id: 'boundary',
        title: 'Farm Boundary',
        fields: ['farm_id', 'geojson'],
      },
    ],
  },
};

/** Form for adding/editing a farm owner (FarmOwner) */
export const farmOwnerSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'owner_name', label: 'Owner Name', required: true, placeholder: 'Full name' },
    { type: 'email', name: 'email', label: 'Email', required: true, placeholder: 'owner@example.com' },
    { type: 'tel', name: 'phone', label: 'Phone', placeholder: '+1 (555) 000-0000' },
    { type: 'number', name: 'ownership_percentage', label: 'Ownership Percentage', min: 0, max: 100, step: 0.01, suffix: '%' },
    { type: 'switch', name: 'is_primary', label: 'Primary Owner', onLabel: 'Yes', offLabel: 'No' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'owner',
        title: 'Owner Information',
        fields: ['owner_name', 'email', 'phone', 'ownership_percentage', 'is_primary'],
        columns: 2,
      },
    ],
  },
};

/** Form for transferring farm ownership (TransferOwnershipRequest) */
export const ownershipTransferSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'select', name: 'farm_id', label: 'Farm', required: true, options: [], searchable: true }, // RPC: FarmService.ListFarms
    { type: 'text', name: 'from_user_id', label: 'From User ID', required: true, placeholder: 'Current owner user ID' },
    { type: 'text', name: 'to_user_id', label: 'To User ID', required: true, placeholder: 'New owner user ID' },
    { type: 'text', name: 'to_owner_name', label: 'New Owner Name', required: true, placeholder: 'Full name of new owner' },
    { type: 'email', name: 'to_email', label: 'New Owner Email', required: true, placeholder: 'newowner@example.com' },
    { type: 'tel', name: 'to_phone', label: 'New Owner Phone', placeholder: '+1 (555) 000-0000' },
    { type: 'number', name: 'ownership_percentage', label: 'Ownership Percentage', required: true, min: 0, max: 100, step: 0.01, suffix: '%' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'transfer',
        title: 'Ownership Transfer',
        fields: ['farm_id', 'from_user_id', 'to_user_id'],
        columns: 2,
      },
      {
        id: 'new_owner',
        title: 'New Owner Details',
        fields: ['to_owner_name', 'to_email', 'to_phone', 'ownership_percentage'],
        columns: 2,
      },
    ],
  },
};
