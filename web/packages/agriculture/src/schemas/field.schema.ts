/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { FormSchema } from '@samavāya/core';
import { farmClient } from '../services';

export const fieldFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'text', name: 'name', label: 'Name', required: true },
    { type: 'number', name: 'areaHectares', label: 'Area Hectares', min: 0, step: 0.01 },
    { type: 'select', name: 'fieldType', label: 'Field Type', options: [
        { label: 'Cropland', value: '1' },
        { label: 'Pasture', value: '2' },
        { label: 'Orchard', value: '3' },
        { label: 'Vineyard', value: '4' },
        { label: 'Greenhouse', value: '5' },
        { label: 'Nursery', value: '6' },
        { label: 'Agroforest', value: '7' },
      ] },
    { type: 'select', name: 'soilType', label: 'Soil Type', options: [
        { label: 'Clay', value: '1' },
        { label: 'Sandy', value: '2' },
        { label: 'Loamy', value: '3' },
        { label: 'Silt', value: '4' },
        { label: 'Peat', value: '5' },
        { label: 'Chalk', value: '6' },
        { label: 'Clay Loam', value: '7' },
        { label: 'Sandy Loam', value: '8' },
      ] },
    { type: 'select', name: 'irrigationType', label: 'Irrigation Type', options: [
        { label: 'Rainfed', value: '1' },
        { label: 'Drip', value: '2' },
        { label: 'Sprinkler', value: '3' },
        { label: 'Flood', value: '4' },
        { label: 'Center Pivot', value: '5' },
        { label: 'Furrow', value: '6' },
        { label: 'Subsurface', value: '7' },
      ] },
    { type: 'number', name: 'elevationMeters', label: 'Elevation Meters', min: 0, step: 0.01 },
    { type: 'number', name: 'slopeDegrees', label: 'Slope Degrees' },
    { type: 'select', name: 'aspectDirection', label: 'Aspect Direction', options: [
        { label: 'North', value: '1' },
        { label: 'Northeast', value: '2' },
        { label: 'East', value: '3' },
        { label: 'Southeast', value: '4' },
        { label: 'South', value: '5' },
        { label: 'Southwest', value: '6' },
        { label: 'West', value: '7' },
        { label: 'Northwest', value: '8' },
        { label: 'Flat', value: '9' },
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
        fields: ['farmId', 'name', 'fieldType', 'soilType', 'irrigationType'],
        columns: 2,
      },
      {
        id: 'classification',
        title: 'Status & Classification',
        fields: ['aspectDirection'],
        columns: 2,
      },
      {
        id: 'metrics',
        title: 'Measurements & Metrics',
        fields: ['areaHectares', 'elevationMeters', 'slopeDegrees'],
        columns: 2,
      },
    ],
  },
};
