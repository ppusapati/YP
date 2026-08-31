/**
 * Field Service Form Schemas
 * Based on agriculture.field.v1 protobuf definitions
 */
import type { FormSchema } from '@samavāya/core';

/** Form for creating a new field (CreateFieldRequest) */
export const createFieldSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'select', name: 'farm_id', label: 'Farm', required: true, options: [], searchable: true }, // RPC: FarmService.ListFarms
    { type: 'text', name: 'name', label: 'Field Name', required: true, placeholder: 'Enter field name' },
    { type: 'number', name: 'area_hectares', label: 'Area (hectares)', min: 0, step: 0.01, suffix: 'ha' },
    { type: 'select', name: 'field_type', label: 'Field Type', options: [
      { label: 'Cropland', value: 'FIELD_TYPE_CROPLAND' },
      { label: 'Pasture', value: 'FIELD_TYPE_PASTURE' },
      { label: 'Orchard', value: 'FIELD_TYPE_ORCHARD' },
      { label: 'Vineyard', value: 'FIELD_TYPE_VINEYARD' },
      { label: 'Greenhouse', value: 'FIELD_TYPE_GREENHOUSE' },
      { label: 'Nursery', value: 'FIELD_TYPE_NURSERY' },
      { label: 'Agroforest', value: 'FIELD_TYPE_AGROFOREST' },
    ] },
    { type: 'select', name: 'soil_type', label: 'Soil Type', options: [
      { label: 'Clay', value: 'SOIL_TYPE_CLAY' },
      { label: 'Sandy', value: 'SOIL_TYPE_SANDY' },
      { label: 'Loamy', value: 'SOIL_TYPE_LOAMY' },
      { label: 'Silt', value: 'SOIL_TYPE_SILT' },
      { label: 'Peat', value: 'SOIL_TYPE_PEAT' },
      { label: 'Chalk', value: 'SOIL_TYPE_CHALK' },
      { label: 'Clay Loam', value: 'SOIL_TYPE_CLAY_LOAM' },
      { label: 'Sandy Loam', value: 'SOIL_TYPE_SANDY_LOAM' },
    ] },
    { type: 'select', name: 'irrigation_type', label: 'Irrigation Type', options: [
      { label: 'Rainfed', value: 'IRRIGATION_TYPE_RAINFED' },
      { label: 'Drip', value: 'IRRIGATION_TYPE_DRIP' },
      { label: 'Sprinkler', value: 'IRRIGATION_TYPE_SPRINKLER' },
      { label: 'Flood', value: 'IRRIGATION_TYPE_FLOOD' },
      { label: 'Center Pivot', value: 'IRRIGATION_TYPE_CENTER_PIVOT' },
      { label: 'Furrow', value: 'IRRIGATION_TYPE_FURROW' },
      { label: 'Subsurface', value: 'IRRIGATION_TYPE_SUBSURFACE' },
    ] },
    { type: 'number', name: 'elevation', label: 'Elevation (meters)', step: 0.01, suffix: 'm' },
    { type: 'number', name: 'slope', label: 'Slope (degrees)', min: 0, max: 90, step: 0.1, suffix: 'deg' },
    { type: 'select', name: 'aspect_direction', label: 'Aspect Direction', options: [
      { label: 'North', value: 'ASPECT_DIRECTION_NORTH' },
      { label: 'Northeast', value: 'ASPECT_DIRECTION_NORTHEAST' },
      { label: 'East', value: 'ASPECT_DIRECTION_EAST' },
      { label: 'Southeast', value: 'ASPECT_DIRECTION_SOUTHEAST' },
      { label: 'South', value: 'ASPECT_DIRECTION_SOUTH' },
      { label: 'Southwest', value: 'ASPECT_DIRECTION_SOUTHWEST' },
      { label: 'West', value: 'ASPECT_DIRECTION_WEST' },
      { label: 'Northwest', value: 'ASPECT_DIRECTION_NORTHWEST' },
      { label: 'Flat', value: 'ASPECT_DIRECTION_FLAT' },
    ] },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Field Details',
        fields: ['farm_id', 'name', 'field_type', 'soil_type', 'irrigation_type'],
        columns: 2,
      },
      {
        id: 'terrain',
        title: 'Terrain',
        fields: ['area_hectares', 'elevation', 'slope', 'aspect_direction'],
        columns: 2,
      },
    ],
  },
};

/** Form for assigning a crop to a field (AssignCropRequest) */
export const assignCropSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'select', name: 'field_id', label: 'Field', required: true, options: [], searchable: true }, // RPC: FieldService.ListFields
    { type: 'select', name: 'crop_id', label: 'Crop', required: true, options: [], searchable: true }, // RPC: CropService.ListCrops
    { type: 'text', name: 'variety', label: 'Variety', placeholder: 'Crop variety name' },
    { type: 'date', name: 'planting_date', label: 'Planting Date' },
    { type: 'date', name: 'expected_harvest_date', label: 'Expected Harvest Date' },
    { type: 'text', name: 'season', label: 'Season', placeholder: 'e.g. Kharif 2025, Rabi 2025' },
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3, placeholder: 'Additional notes about this crop assignment' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'assignment',
        title: 'Crop Assignment',
        fields: ['field_id', 'crop_id', 'variety', 'season'],
        columns: 2,
      },
      {
        id: 'schedule',
        title: 'Schedule',
        fields: ['planting_date', 'expected_harvest_date'],
        columns: 2,
      },
      {
        id: 'notes',
        title: 'Notes',
        fields: ['notes'],
        columns: 1,
      },
    ],
  },
};

/** Form for creating a field segment (FieldSegmentInput) */
export const fieldSegmentSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'select', name: 'field_id', label: 'Field', required: true, options: [], searchable: true }, // RPC: FieldService.ListFields
    { type: 'text', name: 'name', label: 'Segment Name', required: true, placeholder: 'Enter segment name' },
    { type: 'number', name: 'area_hectares', label: 'Area (hectares)', min: 0, step: 0.01, suffix: 'ha' },
    { type: 'select', name: 'soil_type', label: 'Soil Type', options: [
      { label: 'Clay', value: 'SOIL_TYPE_CLAY' },
      { label: 'Sandy', value: 'SOIL_TYPE_SANDY' },
      { label: 'Loamy', value: 'SOIL_TYPE_LOAMY' },
      { label: 'Silt', value: 'SOIL_TYPE_SILT' },
      { label: 'Peat', value: 'SOIL_TYPE_PEAT' },
      { label: 'Chalk', value: 'SOIL_TYPE_CHALK' },
      { label: 'Clay Loam', value: 'SOIL_TYPE_CLAY_LOAM' },
      { label: 'Sandy Loam', value: 'SOIL_TYPE_SANDY_LOAM' },
    ] },
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3, placeholder: 'Notes about this segment' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'segment',
        title: 'Segment Details',
        fields: ['field_id', 'name', 'area_hectares', 'soil_type', 'notes'],
        columns: 2,
      },
    ],
  },
};
