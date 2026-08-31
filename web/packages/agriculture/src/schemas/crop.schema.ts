/**
 * Crop Service Form Schemas
 * Based on agriculture.crop.v1 protobuf definitions
 */
import type { FormSchema } from '@samavāya/core';

/** Form for creating a new crop (CreateCropRequest) */
export const createCropSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'name', label: 'Crop Name', required: true, placeholder: 'Enter crop name' },
    { type: 'text', name: 'scientific_name', label: 'Scientific Name', placeholder: 'e.g. Triticum aestivum' },
    { type: 'text', name: 'family', label: 'Family', placeholder: 'e.g. Poaceae' },
    { type: 'select', name: 'category', label: 'Category', options: [
      { label: 'Cereal', value: 'CROP_CATEGORY_CEREAL' },
      { label: 'Legume', value: 'CROP_CATEGORY_LEGUME' },
      { label: 'Vegetable', value: 'CROP_CATEGORY_VEGETABLE' },
      { label: 'Fruit', value: 'CROP_CATEGORY_FRUIT' },
      { label: 'Oilseed', value: 'CROP_CATEGORY_OILSEED' },
      { label: 'Fiber', value: 'CROP_CATEGORY_FIBER' },
      { label: 'Spice', value: 'CROP_CATEGORY_SPICE' },
    ] },
    { type: 'textarea', name: 'description', label: 'Description', rows: 3, placeholder: 'Describe the crop' },
    { type: 'url', name: 'image_url', label: 'Image URL', placeholder: 'https://...' },
    { type: 'array', name: 'disease_susceptibilities', label: 'Disease Susceptibilities', itemFields: [
      { type: 'text', name: 'disease', label: 'Disease Name', required: true, placeholder: 'e.g. Rust, Blight' },
    ], addLabel: 'Add Disease', minItems: 0 },
    { type: 'array', name: 'companion_plants', label: 'Companion Plants', itemFields: [
      { type: 'text', name: 'plant', label: 'Plant Name', required: true, placeholder: 'e.g. Marigold, Basil' },
    ], addLabel: 'Add Companion Plant', minItems: 0 },
    { type: 'text', name: 'rotation_group', label: 'Rotation Group', placeholder: 'e.g. Legume, Cereal, Root' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Crop Details',
        fields: ['name', 'scientific_name', 'family', 'category', 'description', 'image_url'],
        columns: 2,
      },
      {
        id: 'agronomics',
        title: 'Agronomic Properties',
        fields: ['disease_susceptibilities', 'companion_plants', 'rotation_group'],
        columns: 1,
      },
    ],
  },
};

/** Form for adding a crop variety (AddCropVarietyRequest) */
export const cropVarietySchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'select', name: 'crop_id', label: 'Crop', required: true, options: [], searchable: true }, // RPC: CropService.ListCrops
    { type: 'text', name: 'name', label: 'Variety Name', required: true, placeholder: 'Enter variety name' },
    { type: 'textarea', name: 'description', label: 'Description', rows: 3, placeholder: 'Describe the variety' },
    { type: 'number', name: 'maturity_days', label: 'Maturity Days', min: 0, step: 1, suffix: 'days' },
    { type: 'number', name: 'yield_potential', label: 'Yield Potential (kg/ha)', min: 0, step: 0.01, suffix: 'kg/ha' },
    { type: 'switch', name: 'is_hybrid', label: 'Hybrid Variety', onLabel: 'Yes', offLabel: 'No' },
    { type: 'text', name: 'disease_resistance', label: 'Disease Resistance', placeholder: 'Diseases this variety resists' },
    { type: 'text', name: 'suitable_regions', label: 'Suitable Regions', placeholder: 'Regions where this variety thrives' },
    { type: 'number', name: 'seed_rate', label: 'Seed Rate (kg/ha)', min: 0, step: 0.01, suffix: 'kg/ha' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Variety Details',
        fields: ['crop_id', 'name', 'description', 'disease_resistance', 'suitable_regions'],
        columns: 2,
      },
      {
        id: 'metrics',
        title: 'Performance Metrics',
        fields: ['maturity_days', 'yield_potential', 'seed_rate'],
        columns: 2,
      },
      {
        id: 'options',
        title: 'Options',
        fields: ['is_hybrid'],
        columns: 2,
      },
    ],
  },
};

/** Form for setting crop requirements (SetCropRequirementsRequest) */
export const cropRequirementsSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'select', name: 'crop_id', label: 'Crop', required: true, options: [], searchable: true }, // RPC: CropService.ListCrops
    { type: 'number', name: 'optimal_temp_min', label: 'Optimal Temp Min (C)', step: 0.1, suffix: '\u00B0C' },
    { type: 'number', name: 'optimal_temp_max', label: 'Optimal Temp Max (C)', step: 0.1, suffix: '\u00B0C' },
    { type: 'number', name: 'humidity_min', label: 'Humidity Min (%)', min: 0, max: 100, step: 0.1, suffix: '%' },
    { type: 'number', name: 'humidity_max', label: 'Humidity Max (%)', min: 0, max: 100, step: 0.1, suffix: '%' },
    { type: 'number', name: 'soil_ph_min', label: 'Soil pH Min', min: 0, max: 14, step: 0.1 },
    { type: 'number', name: 'soil_ph_max', label: 'Soil pH Max', min: 0, max: 14, step: 0.1 },
    { type: 'number', name: 'water_requirement_mm', label: 'Water Requirement (mm/season)', min: 0, step: 0.1, suffix: 'mm' },
    { type: 'number', name: 'sunlight_hours', label: 'Sunlight Hours (per day)', min: 0, max: 24, step: 0.1, suffix: 'hrs' },
    { type: 'switch', name: 'frost_tolerant', label: 'Frost Tolerant', onLabel: 'Yes', offLabel: 'No' },
    { type: 'switch', name: 'drought_tolerant', label: 'Drought Tolerant', onLabel: 'Yes', offLabel: 'No' },
    { type: 'text', name: 'soil_preference', label: 'Soil Preference', placeholder: 'Preferred soil type' },
    { type: 'textarea', name: 'nutrient_requirements', label: 'Nutrient Requirements', rows: 3, placeholder: 'NPK and micronutrient needs' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'temperature',
        title: 'Temperature & Climate',
        fields: ['crop_id', 'optimal_temp_min', 'optimal_temp_max', 'humidity_min', 'humidity_max', 'sunlight_hours'],
        columns: 2,
      },
      {
        id: 'soil',
        title: 'Soil Requirements',
        fields: ['soil_ph_min', 'soil_ph_max', 'soil_preference', 'nutrient_requirements'],
        columns: 2,
      },
      {
        id: 'water',
        title: 'Water & Resilience',
        fields: ['water_requirement_mm', 'frost_tolerant', 'drought_tolerant'],
        columns: 2,
      },
    ],
  },
};
