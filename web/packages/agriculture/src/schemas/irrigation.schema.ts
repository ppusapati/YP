/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { FormSchema } from '@samavāya/core';
import { farmClient, fieldClient, irrigationClient } from '../services';

export const irrigationScheduleFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'fieldId', label: 'Field', loadOptions: async (query: string) => {
        const res = await fieldClient.listFields({ search: query, pageSize: 50 });
        return (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'zoneId', label: 'Irrigation Zone', loadOptions: async (query: string) => {
        const res = await irrigationClient.getIrrigationZones({ search: query, pageSize: 50 });
        return (res.zones || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'select', name: 'scheduleType', label: 'Schedule Type', options: [
        { label: 'Fixed', value: '1' },
        { label: 'Adaptive', value: '2' },
        { label: 'Ai Driven', value: '3' },
      ] },
    { type: 'date', name: 'startTime', label: 'Start Time' },
    { type: 'date', name: 'endTime', label: 'End Time' },
    { type: 'number', name: 'durationMinutes', label: 'Duration Minutes', min: 0, step: 1 },
    { type: 'number', name: 'waterQuantityLiters', label: 'Water Quantity Liters', min: 0, step: 0.01 },
    { type: 'number', name: 'flowRateLitersPerHour', label: 'Flow Rate Liters Per Hour', min: 0, step: 0.01 },
    { type: 'select', name: 'frequency', label: 'Frequency', options: [
        { label: 'Daily', value: '1' },
        { label: 'Weekly', value: '2' },
        { label: 'Bi Weekly', value: '3' },
        { label: 'Monthly', value: '4' },
        { label: 'Quarterly', value: '5' },
        { label: 'Semi Annual', value: '6' },
        { label: 'Annual', value: '7' },
      ] },
    { type: 'number', name: 'soilMoistureThresholdPct', label: 'Soil Moisture Threshold Pct', min: 0, max: 100 },
    { type: 'checkbox', name: 'weatherAdjusted', label: 'Weather Adjusted' },
    { type: 'text', name: 'cropGrowthStage', label: 'Crop Growth Stage' },
    { type: 'autocomplete', name: 'controllerId', label: 'Controller', loadOptions: async (query: string) => {
        const res = await irrigationClient.getWaterControllers({ search: query, pageSize: 50 });
        return (res.controllers || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'select', name: 'status', label: 'Status', options: [
        { label: 'Scheduled', value: '1' },
        { label: 'Active', value: '2' },
        { label: 'Completed', value: '3' },
        { label: 'Cancelled', value: '4' },
        { label: 'Failed', value: '5' },
      ] },
    { type: 'text', name: 'name', label: 'Name', required: true },
    { type: 'textarea', name: 'description', label: 'Description', rows: 3 },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Irrigation Schedule Details',
        fields: ['fieldId', 'farmId', 'zoneId', 'controllerId', 'name', 'description', 'scheduleType', 'cropGrowthStage'],
        columns: 2,
      },
      {
        id: 'classification',
        title: 'Status & Classification',
        fields: ['frequency', 'status'],
        columns: 2,
      },
      {
        id: 'metrics',
        title: 'Measurements & Metrics',
        fields: ['durationMinutes', 'waterQuantityLiters', 'flowRateLitersPerHour', 'soilMoistureThresholdPct'],
        columns: 2,
      },
      {
        id: 'dates',
        title: 'Dates',
        fields: ['startTime', 'endTime'],
        columns: 2,
      },
      {
        id: 'options',
        title: 'Options',
        fields: ['weatherAdjusted'],
        columns: 2,
      },
    ],
  },
};

export const irrigationZoneFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'fieldId', label: 'Field', loadOptions: async (query: string) => {
        const res = await fieldClient.listFields({ search: query, pageSize: 50 });
        return (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'text', name: 'name', label: 'Name', required: true },
    { type: 'textarea', name: 'description', label: 'Description', rows: 3 },
    { type: 'number', name: 'areaHectares', label: 'Area Hectares', min: 0, step: 0.01 },
    { type: 'text', name: 'soilType', label: 'Soil Type' },
    { type: 'text', name: 'cropType', label: 'Crop Type' },
    { type: 'text', name: 'cropGrowthStage', label: 'Crop Growth Stage' },
    { type: 'number', name: 'latitude', label: 'Latitude', min: -90, max: 90, step: 0.000001 },
    { type: 'number', name: 'longitude', label: 'Longitude', min: -180, max: 180, step: 0.000001 },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Irrigation Zone Details',
        fields: ['fieldId', 'farmId', 'name', 'description', 'soilType', 'cropType', 'cropGrowthStage'],
        columns: 2,
      },
      {
        id: 'metrics',
        title: 'Measurements & Metrics',
        fields: ['areaHectares', 'latitude', 'longitude'],
        columns: 2,
      },
    ],
  },
};
