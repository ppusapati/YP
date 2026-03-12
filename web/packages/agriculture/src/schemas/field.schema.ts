/**
 * Field Form Schema — derived from agriculture.field.v1 proto
 */
import type { FormSchema } from '@samavāya/core';

export const fieldFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'farmId', label: 'Farm', placeholder: 'Select farm', required: true },
    { type: 'text', name: 'name', label: 'Field Name', placeholder: 'Enter field name', required: true },
    { type: 'number', name: 'areaHectares', label: 'Area (hectares)', min: 0, step: 0.01 } as any,
    {
      type: 'select', name: 'fieldType', label: 'Field Type',
      options: [
        { label: 'Cropland', value: '1' },
        { label: 'Pasture', value: '2' },
        { label: 'Orchard', value: '3' },
        { label: 'Vineyard', value: '4' },
        { label: 'Greenhouse', value: '5' },
        { label: 'Nursery', value: '6' },
        { label: 'Agroforest', value: '7' },
      ],
    } as any,
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Active', value: '1' },
        { label: 'Fallow', value: '2' },
        { label: 'Preparation', value: '3' },
        { label: 'Planted', value: '4' },
        { label: 'Harvesting', value: '5' },
        { label: 'Retired', value: '6' },
      ],
    } as any,
    {
      type: 'select', name: 'soilType', label: 'Soil Type',
      options: [
        { label: 'Clay', value: '1' },
        { label: 'Sandy', value: '2' },
        { label: 'Loamy', value: '3' },
        { label: 'Silt', value: '4' },
        { label: 'Peat', value: '5' },
        { label: 'Chalk', value: '6' },
        { label: 'Clay Loam', value: '7' },
        { label: 'Sandy Loam', value: '8' },
      ],
    } as any,
    {
      type: 'select', name: 'irrigationType', label: 'Irrigation Type',
      options: [
        { label: 'Rainfed', value: '1' },
        { label: 'Drip', value: '2' },
        { label: 'Sprinkler', value: '3' },
        { label: 'Flood', value: '4' },
        { label: 'Center Pivot', value: '5' },
        { label: 'Furrow', value: '6' },
        { label: 'Subsurface', value: '7' },
      ],
    } as any,
    { type: 'number', name: 'elevationMeters', label: 'Elevation (m)', min: 0 } as any,
    { type: 'number', name: 'slopeDegrees', label: 'Slope (degrees)', min: 0, max: 90, step: 0.1 } as any,
    {
      type: 'select', name: 'aspectDirection', label: 'Aspect Direction',
      options: [
        { label: 'North', value: '1' },
        { label: 'Northeast', value: '2' },
        { label: 'East', value: '3' },
        { label: 'Southeast', value: '4' },
        { label: 'South', value: '5' },
        { label: 'Southwest', value: '6' },
        { label: 'West', value: '7' },
        { label: 'Northwest', value: '8' },
        { label: 'Flat', value: '9' },
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
        title: 'Field Details',
        fields: ['farmId', 'name', 'areaHectares', 'fieldType', 'status'],
        columns: 2,
      },
      {
        id: 'soil_irrigation',
        title: 'Soil & Irrigation',
        fields: ['soilType', 'irrigationType'],
        columns: 2,
      },
      {
        id: 'geography',
        title: 'Geography',
        fields: ['elevationMeters', 'slopeDegrees', 'aspectDirection'],
        columns: 3,
      },
    ],
  },
};
