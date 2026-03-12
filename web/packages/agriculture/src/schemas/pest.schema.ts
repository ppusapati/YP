/**
 * Pest Prediction Service Form Schemas
 * Based on agriculture.pest.v1 protobuf definitions
 */
import type { FormSchema } from '@samavāya/core';

/** Form for requesting a pest prediction (PestPredictionRequest) */
export const pestPredictionRequestSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'select', name: 'field_id', label: 'Field', required: true, options: [], searchable: true }, // RPC: FieldService.ListFields
    { type: 'select', name: 'crop_id', label: 'Crop', required: true, options: [], searchable: true }, // RPC: CropService.ListCrops
    { type: 'number', name: 'temperature', label: 'Current Temperature (\u00B0C)', step: 0.1, suffix: '\u00B0C' },
    { type: 'number', name: 'humidity', label: 'Current Humidity (%)', min: 0, max: 100, step: 0.1, suffix: '%' },
    { type: 'number', name: 'rainfall_mm', label: 'Recent Rainfall (mm)', min: 0, step: 0.1, suffix: 'mm' },
    { type: 'number', name: 'wind_speed', label: 'Wind Speed (km/h)', min: 0, step: 0.1, suffix: 'km/h' },
    { type: 'number', name: 'soil_moisture', label: 'Soil Moisture (%)', min: 0, max: 100, step: 0.1, suffix: '%' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'target',
        title: 'Prediction Target',
        fields: ['field_id', 'crop_id'],
        columns: 2,
      },
      {
        id: 'conditions',
        title: 'Current Conditions',
        fields: ['temperature', 'humidity', 'rainfall_mm', 'wind_speed', 'soil_moisture'],
        columns: 2,
      },
    ],
  },
};

/** Form for creating a treatment plan (CreateTreatmentPlanRequest) */
export const treatmentPlanSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'prediction_id', label: 'Prediction ID', required: true, placeholder: 'Linked pest prediction ID' },
    { type: 'select', name: 'treatment_type', label: 'Treatment Type', required: true, options: [
      { label: 'Chemical', value: 'TREATMENT_TYPE_CHEMICAL' },
      { label: 'Biological', value: 'TREATMENT_TYPE_BIOLOGICAL' },
      { label: 'Cultural', value: 'TREATMENT_TYPE_CULTURAL' },
      { label: 'Mechanical', value: 'TREATMENT_TYPE_MECHANICAL' },
      { label: 'Integrated', value: 'TREATMENT_TYPE_INTEGRATED' },
    ] },
    { type: 'text', name: 'product_name', label: 'Product Name', placeholder: 'Name of treatment product' },
    { type: 'text', name: 'dosage', label: 'Dosage', placeholder: 'e.g. 2L/ha, 500g/ha' },
    { type: 'select', name: 'application_method', label: 'Application Method', options: [
      { label: 'Foliar Spray', value: 'APPLICATION_METHOD_FOLIAR_SPRAY' },
      { label: 'Soil Drench', value: 'APPLICATION_METHOD_SOIL_DRENCH' },
      { label: 'Seed Treatment', value: 'APPLICATION_METHOD_SEED_TREATMENT' },
      { label: 'Fumigation', value: 'APPLICATION_METHOD_FUMIGATION' },
      { label: 'Trap Placement', value: 'APPLICATION_METHOD_TRAP' },
      { label: 'Broadcast', value: 'APPLICATION_METHOD_BROADCAST' },
    ] },
    { type: 'date', name: 'application_date', label: 'Application Date' },
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3, placeholder: 'Treatment instructions, precautions, etc.' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'treatment',
        title: 'Treatment Details',
        fields: ['prediction_id', 'treatment_type', 'product_name', 'dosage'],
        columns: 2,
      },
      {
        id: 'application',
        title: 'Application',
        fields: ['application_method', 'application_date', 'notes'],
        columns: 2,
      },
    ],
  },
};
