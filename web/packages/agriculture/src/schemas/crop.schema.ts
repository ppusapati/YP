/**
 * Crop Form Schema
 */
import type { FormSchema } from '@samavāya/core';

export const cropFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'name', label: 'Crop Name', placeholder: 'e.g. Rice, Wheat', required: true },
    { type: 'text', name: 'scientific_name', label: 'Scientific Name', placeholder: 'e.g. Oryza sativa' },
    { type: 'text', name: 'code', label: 'Crop Code', placeholder: 'e.g. CROP-001', required: true },
    {
      type: 'select', name: 'category', label: 'Category', required: true,
      options: [
        { label: 'Cereals', value: 'cereals' },
        { label: 'Pulses', value: 'pulses' },
        { label: 'Oilseeds', value: 'oilseeds' },
        { label: 'Vegetables', value: 'vegetables' },
        { label: 'Fruits', value: 'fruits' },
        { label: 'Spices', value: 'spices' },
        { label: 'Fiber Crops', value: 'fiber' },
        { label: 'Sugar Crops', value: 'sugar' },
        { label: 'Fodder', value: 'fodder' },
        { label: 'Plantation', value: 'plantation' },
      ],
    } as any,
    {
      type: 'select', name: 'crop_type', label: 'Crop Type',
      options: [
        { label: 'Kharif', value: 'kharif' },
        { label: 'Rabi', value: 'rabi' },
        { label: 'Zaid', value: 'zaid' },
        { label: 'Perennial', value: 'perennial' },
      ],
    } as any,
    {
      type: 'select', name: 'season', label: 'Growing Season',
      options: [
        { label: 'Monsoon (Jun-Oct)', value: 'monsoon' },
        { label: 'Winter (Oct-Mar)', value: 'winter' },
        { label: 'Summer (Mar-Jun)', value: 'summer' },
        { label: 'Year-round', value: 'year_round' },
      ],
    } as any,
    { type: 'number', name: 'growth_duration_days', label: 'Growth Duration (days)', min: 1, max: 730 } as any,
    { type: 'number', name: 'optimal_temp_min', label: 'Min Temperature (°C)', min: -10, max: 50, step: 0.1 } as any,
    { type: 'number', name: 'optimal_temp_max', label: 'Max Temperature (°C)', min: -10, max: 60, step: 0.1 } as any,
    { type: 'number', name: 'optimal_humidity_min', label: 'Min Humidity (%)', min: 0, max: 100 } as any,
    { type: 'number', name: 'optimal_humidity_max', label: 'Max Humidity (%)', min: 0, max: 100 } as any,
    { type: 'number', name: 'water_requirement_mm', label: 'Water Requirement (mm)', min: 0 } as any,
    { type: 'number', name: 'soil_ph_min', label: 'Soil pH Min', min: 0, max: 14, step: 0.1 } as any,
    { type: 'number', name: 'soil_ph_max', label: 'Soil pH Max', min: 0, max: 14, step: 0.1 } as any,
    { type: 'textarea', name: 'description', label: 'Description', rows: 3 } as any,
    { type: 'url', name: 'image_url', label: 'Image URL', placeholder: 'https://...' },
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Active', value: 'active' },
        { label: 'Inactive', value: 'inactive' },
        { label: 'Experimental', value: 'experimental' },
      ],
    } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Crop Details',
        fields: ['name', 'scientific_name', 'code', 'category', 'crop_type', 'season', 'growth_duration_days', 'status'],
        columns: 2,
      },
      {
        id: 'conditions',
        title: 'Optimal Growing Conditions',
        fields: ['optimal_temp_min', 'optimal_temp_max', 'optimal_humidity_min', 'optimal_humidity_max', 'water_requirement_mm', 'soil_ph_min', 'soil_ph_max'],
        columns: 2,
      },
      {
        id: 'other',
        title: 'Additional Details',
        fields: ['description', 'image_url'],
        columns: 1,
      },
    ],
  },
};

export const cropVarietyFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'name', label: 'Variety Name', required: true },
    { type: 'text', name: 'code', label: 'Variety Code', required: true },
    { type: 'textarea', name: 'description', label: 'Description', rows: 3 } as any,
    { type: 'number', name: 'maturity_days', label: 'Maturity (days)', min: 1 } as any,
    { type: 'number', name: 'yield_potential', label: 'Yield Potential', min: 0, step: 0.1 } as any,
    {
      type: 'select', name: 'yield_unit', label: 'Yield Unit',
      options: [
        { label: 'Tonnes/Hectare', value: 'tonnes_ha' },
        { label: 'Quintals/Hectare', value: 'quintals_ha' },
        { label: 'Kg/Hectare', value: 'kg_ha' },
      ],
    } as any,
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Active', value: 'active' },
        { label: 'Inactive', value: 'inactive' },
        { label: 'Trial', value: 'trial' },
      ],
    } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'details',
        title: 'Variety Details',
        fields: ['name', 'code', 'description', 'maturity_days', 'yield_potential', 'yield_unit', 'status'],
        columns: 2,
      },
    ],
  },
};
