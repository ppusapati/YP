/**
 * Soil Service Form Schemas
 * Based on agriculture.soil.v1 protobuf definitions
 */
import type { FormSchema } from '@samavāya/core';

/** Form for creating a soil sample (CreateSoilSampleRequest) */
export const createSoilSampleSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'select', name: 'field_id', label: 'Field', required: true, options: [], searchable: true }, // RPC: FieldService.ListFields
    { type: 'select', name: 'farm_id', label: 'Farm', required: true, options: [], searchable: true }, // RPC: FarmService.ListFarms
    { type: 'text', name: 'sample_location', label: 'Sample Location', placeholder: 'GPS coordinates or description' },
    { type: 'number', name: 'depth_cm', label: 'Sample Depth (cm)', min: 0, step: 0.1, suffix: 'cm' },
    { type: 'date', name: 'collection_date', label: 'Collection Date' },
    { type: 'number', name: 'ph', label: 'pH', min: 0, max: 14, step: 0.01 },
    { type: 'number', name: 'organic_matter_pct', label: 'Organic Matter (%)', min: 0, max: 100, step: 0.01, suffix: '%' },
    { type: 'number', name: 'nitrogen_ppm', label: 'Nitrogen (ppm)', min: 0, step: 0.01, suffix: 'ppm' },
    { type: 'number', name: 'phosphorus_ppm', label: 'Phosphorus (ppm)', min: 0, step: 0.01, suffix: 'ppm' },
    { type: 'number', name: 'potassium_ppm', label: 'Potassium (ppm)', min: 0, step: 0.01, suffix: 'ppm' },
    { type: 'number', name: 'calcium_ppm', label: 'Calcium (ppm)', min: 0, step: 0.01, suffix: 'ppm' },
    { type: 'number', name: 'magnesium_ppm', label: 'Magnesium (ppm)', min: 0, step: 0.01, suffix: 'ppm' },
    { type: 'number', name: 'sulfur_ppm', label: 'Sulfur (ppm)', min: 0, step: 0.01, suffix: 'ppm' },
    { type: 'number', name: 'iron_ppm', label: 'Iron (ppm)', min: 0, step: 0.01, suffix: 'ppm' },
    { type: 'number', name: 'manganese_ppm', label: 'Manganese (ppm)', min: 0, step: 0.01, suffix: 'ppm' },
    { type: 'number', name: 'zinc_ppm', label: 'Zinc (ppm)', min: 0, step: 0.01, suffix: 'ppm' },
    { type: 'number', name: 'copper_ppm', label: 'Copper (ppm)', min: 0, step: 0.01, suffix: 'ppm' },
    { type: 'number', name: 'boron_ppm', label: 'Boron (ppm)', min: 0, step: 0.01, suffix: 'ppm' },
    { type: 'number', name: 'moisture_pct', label: 'Moisture (%)', min: 0, max: 100, step: 0.01, suffix: '%' },
    { type: 'select', name: 'texture', label: 'Texture', options: [
      { label: 'Sandy', value: 'SOIL_TEXTURE_SANDY' },
      { label: 'Loamy', value: 'SOIL_TEXTURE_LOAMY' },
      { label: 'Clay', value: 'SOIL_TEXTURE_CLAY' },
      { label: 'Silt', value: 'SOIL_TEXTURE_SILT' },
      { label: 'Peat', value: 'SOIL_TEXTURE_PEAT' },
      { label: 'Chalk', value: 'SOIL_TEXTURE_CHALK' },
    ] },
    { type: 'number', name: 'bulk_density', label: 'Bulk Density (g/cm\u00B3)', min: 0, step: 0.01, suffix: 'g/cm\u00B3' },
    { type: 'number', name: 'cation_exchange_capacity', label: 'CEC (cmol/kg)', min: 0, step: 0.01, suffix: 'cmol/kg' },
    { type: 'number', name: 'electrical_conductivity', label: 'EC (dS/m)', min: 0, step: 0.01, suffix: 'dS/m' },
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3, placeholder: 'Additional notes about this sample' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'source',
        title: 'Sample Source',
        fields: ['field_id', 'farm_id', 'sample_location', 'depth_cm', 'collection_date'],
        columns: 2,
      },
      {
        id: 'primary',
        title: 'Primary Analysis',
        fields: ['ph', 'organic_matter_pct', 'moisture_pct', 'texture', 'bulk_density', 'cation_exchange_capacity', 'electrical_conductivity'],
        columns: 2,
      },
      {
        id: 'macronutrients',
        title: 'Macronutrients',
        fields: ['nitrogen_ppm', 'phosphorus_ppm', 'potassium_ppm', 'calcium_ppm', 'magnesium_ppm', 'sulfur_ppm'],
        columns: 3,
      },
      {
        id: 'micronutrients',
        title: 'Micronutrients',
        fields: ['iron_ppm', 'manganese_ppm', 'zinc_ppm', 'copper_ppm', 'boron_ppm'],
        columns: 3,
      },
      {
        id: 'notes_section',
        title: 'Notes',
        fields: ['notes'],
        columns: 1,
      },
    ],
  },
};

/** Form for analyzing a soil sample (AnalyzeSoilRequest) */
export const analyzeSoilSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'select', name: 'sample_id', label: 'Soil Sample', required: true, options: [], searchable: true }, // RPC: SoilService.ListSoilSamples
    { type: 'select', name: 'analysis_type', label: 'Analysis Type', required: true, options: [
      { label: 'Full Analysis', value: 'ANALYSIS_TYPE_FULL' },
      { label: 'Nutrient Only', value: 'ANALYSIS_TYPE_NUTRIENT' },
      { label: 'pH & EC Only', value: 'ANALYSIS_TYPE_PH_EC' },
      { label: 'Texture Analysis', value: 'ANALYSIS_TYPE_TEXTURE' },
      { label: 'Heavy Metals', value: 'ANALYSIS_TYPE_HEAVY_METALS' },
      { label: 'Biological', value: 'ANALYSIS_TYPE_BIOLOGICAL' },
    ] },
  ],
  layout: {
    type: 'vertical',
    gap: 'md',
    sections: [
      {
        id: 'analysis',
        title: 'Soil Analysis',
        fields: ['sample_id', 'analysis_type'],
      },
    ],
  },
};
