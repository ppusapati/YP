/**
 * Farm Form Schema
 * JSON form definition for DynamicFormRenderer
 */
import type { FormSchema } from '@samavāya/core';

export const farmFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'name', label: 'Farm Name', placeholder: 'Enter farm name', required: true },
    { type: 'text', name: 'code', label: 'Farm Code', placeholder: 'e.g. FARM-001', required: true },
    {
      type: 'select', name: 'farm_type', label: 'Farm Type', required: true,
      options: [
        { label: 'Arable', value: 'arable' },
        { label: 'Pastoral', value: 'pastoral' },
        { label: 'Mixed', value: 'mixed' },
        { label: 'Horticultural', value: 'horticultural' },
        { label: 'Plantation', value: 'plantation' },
        { label: 'Organic', value: 'organic' },
        { label: 'Dairy', value: 'dairy' },
        { label: 'Poultry', value: 'poultry' },
        { label: 'Aquaculture', value: 'aquaculture' },
      ],
    } as any,
    { type: 'textarea', name: 'description', label: 'Description', placeholder: 'Farm description', rows: 3 } as any,
    { type: 'number', name: 'total_area', label: 'Total Area', placeholder: '0', required: true, min: 0 } as any,
    {
      type: 'select', name: 'area_unit', label: 'Area Unit',
      options: [
        { label: 'Hectares', value: 'hectares' },
        { label: 'Acres', value: 'acres' },
        { label: 'Square Meters', value: 'sq_meters' },
        { label: 'Bigha', value: 'bigha' },
        { label: 'Guntha', value: 'guntha' },
      ],
    } as any,
    { type: 'text', name: 'address', label: 'Address', placeholder: 'Street address' },
    { type: 'text', name: 'city', label: 'City', placeholder: 'City' },
    { type: 'text', name: 'state', label: 'State', placeholder: 'State' },
    { type: 'text', name: 'country', label: 'Country', placeholder: 'Country' },
    { type: 'text', name: 'postal_code', label: 'Postal Code', placeholder: 'Postal code' },
    { type: 'number', name: 'latitude', label: 'Latitude', step: 0.000001, min: -90, max: 90 } as any,
    { type: 'number', name: 'longitude', label: 'Longitude', step: 0.000001, min: -180, max: 180 } as any,
    { type: 'number', name: 'altitude', label: 'Altitude (m)', min: 0 } as any,
    {
      type: 'select', name: 'climate_zone', label: 'Climate Zone',
      options: [
        { label: 'Tropical', value: 'tropical' },
        { label: 'Subtropical', value: 'subtropical' },
        { label: 'Temperate', value: 'temperate' },
        { label: 'Arid', value: 'arid' },
        { label: 'Semi-Arid', value: 'semi_arid' },
        { label: 'Mediterranean', value: 'mediterranean' },
        { label: 'Continental', value: 'continental' },
      ],
    } as any,
    {
      type: 'select', name: 'soil_type', label: 'Primary Soil Type',
      options: [
        { label: 'Alluvial', value: 'alluvial' },
        { label: 'Black (Regur)', value: 'black' },
        { label: 'Red', value: 'red' },
        { label: 'Laterite', value: 'laterite' },
        { label: 'Sandy', value: 'sandy' },
        { label: 'Clay', value: 'clay' },
        { label: 'Loam', value: 'loam' },
        { label: 'Silt', value: 'silt' },
      ],
    } as any,
    {
      type: 'select', name: 'water_source', label: 'Water Source',
      options: [
        { label: 'Canal', value: 'canal' },
        { label: 'Borewell', value: 'borewell' },
        { label: 'River', value: 'river' },
        { label: 'Rain-fed', value: 'rainfed' },
        { label: 'Reservoir', value: 'reservoir' },
        { label: 'Drip Irrigation', value: 'drip' },
        { label: 'Sprinkler', value: 'sprinkler' },
      ],
    } as any,
    { type: 'text', name: 'owner_name', label: 'Owner Name', placeholder: 'Farm owner name' },
    { type: 'tel', name: 'owner_contact', label: 'Owner Contact', placeholder: 'Phone number' },
    { type: 'text', name: 'manager_name', label: 'Manager Name', placeholder: 'Farm manager name' },
    { type: 'tel', name: 'manager_contact', label: 'Manager Contact', placeholder: 'Phone number' },
    { type: 'date', name: 'establishment_date', label: 'Establishment Date' } as any,
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Active', value: 'active' },
        { label: 'Inactive', value: 'inactive' },
        { label: 'Under Development', value: 'under_development' },
        { label: 'Abandoned', value: 'abandoned' },
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
        title: 'Basic Information',
        fields: ['name', 'code', 'farm_type', 'description', 'total_area', 'area_unit', 'status'],
        columns: 2,
      },
      {
        id: 'location',
        title: 'Location',
        fields: ['address', 'city', 'state', 'country', 'postal_code', 'latitude', 'longitude', 'altitude'],
        columns: 2,
      },
      {
        id: 'environment',
        title: 'Environmental Conditions',
        fields: ['climate_zone', 'soil_type', 'water_source'],
        columns: 3,
      },
      {
        id: 'contacts',
        title: 'Contacts',
        fields: ['owner_name', 'owner_contact', 'manager_name', 'manager_contact', 'establishment_date'],
        columns: 2,
      },
    ],
  },
};
