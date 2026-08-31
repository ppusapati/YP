/**
 * Yield Service Form Schemas
 * Based on agriculture.yield.v1 protobuf definitions
 */
import type { FormSchema } from '@samavāya/core';

/** Form for recording yield (RecordYieldRequest) */
export const yieldRecordSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'select', name: 'field_id', label: 'Field', required: true, options: [], searchable: true }, // RPC: FieldService.ListFields
    { type: 'select', name: 'crop_id', label: 'Crop', required: true, options: [], searchable: true }, // RPC: CropService.ListCrops
    { type: 'date', name: 'harvest_date', label: 'Harvest Date', required: true },
    { type: 'number', name: 'yield_amount', label: 'Yield Amount', required: true, min: 0, step: 0.01 },
    { type: 'select', name: 'unit', label: 'Unit', required: true, options: [
      { label: 'kg', value: 'UNIT_KG' },
      { label: 'tonnes', value: 'UNIT_TONNES' },
      { label: 'bushels', value: 'UNIT_BUSHELS' },
      { label: 'quintals', value: 'UNIT_QUINTALS' },
      { label: 'kg/ha', value: 'UNIT_KG_PER_HECTARE' },
    ] },
    { type: 'select', name: 'quality_grade', label: 'Quality Grade', options: [
      { label: 'Grade A (Premium)', value: 'QUALITY_GRADE_A' },
      { label: 'Grade B (Standard)', value: 'QUALITY_GRADE_B' },
      { label: 'Grade C (Below Standard)', value: 'QUALITY_GRADE_C' },
      { label: 'Grade D (Reject)', value: 'QUALITY_GRADE_D' },
    ] },
    { type: 'textarea', name: 'weather_notes', label: 'Weather Notes', rows: 2, placeholder: 'Weather conditions during harvest' },
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3, placeholder: 'Additional harvest observations' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'harvest',
        title: 'Harvest Details',
        fields: ['field_id', 'crop_id', 'harvest_date'],
        columns: 2,
      },
      {
        id: 'yield',
        title: 'Yield Measurement',
        fields: ['yield_amount', 'unit', 'quality_grade'],
        columns: 2,
      },
      {
        id: 'observations',
        title: 'Observations',
        fields: ['weather_notes', 'notes'],
        columns: 1,
      },
    ],
  },
};

/** Form for requesting a yield forecast (YieldForecastRequest) */
export const yieldForecastRequestSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'select', name: 'field_id', label: 'Field', required: true, options: [], searchable: true }, // RPC: FieldService.ListFields
    { type: 'select', name: 'crop_id', label: 'Crop', required: true, options: [], searchable: true }, // RPC: CropService.ListCrops
    { type: 'text', name: 'season', label: 'Season', required: true, placeholder: 'e.g. Kharif 2025, Rabi 2025' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'forecast',
        title: 'Forecast Parameters',
        fields: ['field_id', 'crop_id', 'season'],
        columns: 2,
      },
    ],
  },
};
