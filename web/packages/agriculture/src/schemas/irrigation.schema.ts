import type { FormSchema } from '@samavāya/core';

export const irrigationScheduleFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'name', label: 'Name', required: true },
    { type: 'textarea', name: 'description', label: 'Description' } as any,
    { type: 'text', name: 'fieldId', label: 'Field', required: true },
    { type: 'text', name: 'zoneId', label: 'Zone' },
    {
      type: 'select', name: 'scheduleType', label: 'Schedule Type',
      options: [
        { label: 'Fixed', value: '1' },
        { label: 'Adaptive', value: '2' },
        { label: 'AI Driven', value: '3' },
      ],
    } as any,
    { type: 'text', name: 'startTime', label: 'Start Time', placeholder: 'HH:MM' },
    { type: 'text', name: 'endTime', label: 'End Time', placeholder: 'HH:MM' },
    { type: 'number', name: 'durationMinutes', label: 'Duration (min)', min: 0 } as any,
    { type: 'number', name: 'waterQuantityLiters', label: 'Water Quantity (L)', min: 0 } as any,
    { type: 'number', name: 'flowRateLitersPerHour', label: 'Flow Rate (L/h)', min: 0 } as any,
    {
      type: 'select', name: 'frequency', label: 'Frequency',
      options: [
        { label: 'Daily', value: '1' },
        { label: 'Every Other Day', value: '2' },
        { label: 'Weekly', value: '3' },
        { label: 'Custom', value: '4' },
      ],
    } as any,
    { type: 'number', name: 'soilMoistureThresholdPct', label: 'Soil Moisture Threshold (%)', min: 0, max: 100 } as any,
    { type: 'checkbox', name: 'weatherAdjusted', label: 'Weather Adjusted' } as any,
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Scheduled', value: '1' },
        { label: 'Active', value: '2' },
        { label: 'Completed', value: '3' },
        { label: 'Cancelled', value: '4' },
        { label: 'Failed', value: '5' },
      ],
    } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'schedule_details',
        title: 'Schedule Details',
        fields: ['name', 'description', 'fieldId', 'zoneId', 'scheduleType', 'startTime', 'endTime', 'durationMinutes', 'frequency', 'status'],
        columns: 2,
      },
      {
        id: 'water_parameters',
        title: 'Water Parameters',
        fields: ['waterQuantityLiters', 'flowRateLitersPerHour'],
        columns: 2,
      },
      {
        id: 'smart_triggers',
        title: 'Smart Triggers',
        fields: ['soilMoistureThresholdPct', 'weatherAdjusted'],
        columns: 2,
      },
    ],
  },
};

export const irrigationZoneFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'name', label: 'Zone Name', required: true },
    { type: 'text', name: 'fieldId', label: 'Field', required: true },
    { type: 'text', name: 'farmId', label: 'Farm' },
    { type: 'textarea', name: 'description', label: 'Description' } as any,
    { type: 'number', name: 'areaHectares', label: 'Area (ha)', min: 0, step: 0.01 } as any,
    { type: 'text', name: 'soilType', label: 'Soil Type' },
    { type: 'text', name: 'cropType', label: 'Crop Type' },
    { type: 'text', name: 'cropGrowthStage', label: 'Crop Growth Stage' },
    { type: 'number', name: 'latitude', label: 'Latitude', step: 0.000001, min: -90, max: 90 } as any,
    { type: 'number', name: 'longitude', label: 'Longitude', step: 0.000001, min: -180, max: 180 } as any,
    { type: 'checkbox', name: 'isActive', label: 'Active' } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'zone_details',
        title: 'Zone Details',
        fields: ['name', 'fieldId', 'farmId', 'description', 'areaHectares', 'soilType', 'cropType', 'cropGrowthStage', 'isActive'],
        columns: 2,
      },
      {
        id: 'location',
        title: 'Location',
        fields: ['latitude', 'longitude'],
        columns: 2,
      },
    ],
  },
};
