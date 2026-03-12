/**
 * Farm Form Schema — derived from agriculture.farm.v1 proto
 */
import type { FormSchema } from '@samavāya/core';

export const farmFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'name', label: 'Farm Name', placeholder: 'Enter farm name', required: true },
    { type: 'textarea', name: 'description', label: 'Description', placeholder: 'Farm description', rows: 3 } as any,
    { type: 'number', name: 'totalAreaHectares', label: 'Total Area (hectares)', required: true, min: 0, step: 0.01 } as any,
    {
      type: 'select', name: 'farmType', label: 'Farm Type', required: true,
      options: [
        { label: 'Crop', value: '1' },
        { label: 'Livestock', value: '2' },
        { label: 'Mixed', value: '3' },
        { label: 'Aquaculture', value: '4' },
      ],
    } as any,
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Active', value: '1' },
        { label: 'Inactive', value: '2' },
        { label: 'Pending', value: '3' },
        { label: 'Suspended', value: '4' },
        { label: 'Archived', value: '5' },
      ],
    } as any,
    {
      type: 'select', name: 'soilType', label: 'Primary Soil Type',
      options: [
        { label: 'Clay', value: '1' },
        { label: 'Sandy', value: '2' },
        { label: 'Loamy', value: '3' },
        { label: 'Silt', value: '4' },
        { label: 'Peat', value: '5' },
        { label: 'Chalky', value: '6' },
        { label: 'Laterite', value: '7' },
        { label: 'Black', value: '8' },
        { label: 'Red', value: '9' },
        { label: 'Alluvial', value: '10' },
      ],
    } as any,
    {
      type: 'select', name: 'climateZone', label: 'Climate Zone',
      options: [
        { label: 'Tropical', value: '1' },
        { label: 'Subtropical', value: '2' },
        { label: 'Arid', value: '3' },
        { label: 'Semi-Arid', value: '4' },
        { label: 'Temperate', value: '5' },
        { label: 'Continental', value: '6' },
        { label: 'Polar', value: '7' },
        { label: 'Mediterranean', value: '8' },
        { label: 'Monsoon', value: '9' },
      ],
    } as any,
    { type: 'number', name: 'elevationMeters', label: 'Elevation (m)', min: 0 } as any,
    { type: 'text', name: 'address', label: 'Address', placeholder: 'Street address' },
    { type: 'text', name: 'region', label: 'Region', placeholder: 'Region / State' },
    { type: 'text', name: 'country', label: 'Country', placeholder: 'Country' },
    { type: 'number', name: 'latitude', label: 'Latitude', step: 0.000001, min: -90, max: 90 } as any,
    { type: 'number', name: 'longitude', label: 'Longitude', step: 0.000001, min: -180, max: 180 } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Basic Information',
        fields: ['name', 'description', 'totalAreaHectares', 'farmType', 'status'],
        columns: 2,
      },
      {
        id: 'environment',
        title: 'Environmental Conditions',
        fields: ['soilType', 'climateZone', 'elevationMeters'],
        columns: 3,
      },
      {
        id: 'location',
        title: 'Location',
        fields: ['address', 'region', 'country', 'latitude', 'longitude'],
        columns: 2,
      },
    ],
  },
};
