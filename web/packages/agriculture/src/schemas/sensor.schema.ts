/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { FormSchema } from '@samavāya/core';
import { farmClient, fieldClient } from '../services';

export const sensorFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'fieldId', label: 'Field', loadOptions: async (query: string) => {
        const res = await fieldClient.listFields({ search: query, pageSize: 50 });
        return (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'select', name: 'sensorType', label: 'Sensor Type', options: [
        { label: 'Soil Moisture', value: '1' },
        { label: 'Soil Ph', value: '2' },
        { label: 'Temperature', value: '3' },
        { label: 'Humidity', value: '4' },
        { label: 'Rainfall', value: '5' },
        { label: 'Wind Speed', value: '6' },
        { label: 'Wind Direction', value: '7' },
        { label: 'Light Intensity', value: '8' },
        { label: 'Leaf Wetness', value: '9' },
      ] },
    { type: 'text', name: 'deviceId', label: 'Device Id' },
    { type: 'text', name: 'manufacturer', label: 'Manufacturer' },
    { type: 'text', name: 'model', label: 'Model' },
    { type: 'text', name: 'firmwareVersion', label: 'Firmware Version' },
    { type: 'date', name: 'installationDate', label: 'Installation Date' },
    { type: 'select', name: 'protocol', label: 'Protocol', options: [
        { label: 'Mqtt', value: '1' },
        { label: 'Lorawan', value: '2' },
        { label: 'Zigbee', value: '3' },
        { label: 'Wifi', value: '4' },
        { label: 'Cellular', value: '5' },
      ] },
    { type: 'number', name: 'readingIntervalSeconds', label: 'Reading Interval Seconds', min: 0, step: 1 },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Sensor Details',
        fields: ['fieldId', 'farmId', 'sensorType', 'deviceId', 'manufacturer', 'model', 'firmwareVersion'],
        columns: 2,
      },
      {
        id: 'classification',
        title: 'Status & Classification',
        fields: ['protocol'],
        columns: 2,
      },
      {
        id: 'metrics',
        title: 'Measurements & Metrics',
        fields: ['readingIntervalSeconds'],
        columns: 2,
      },
      {
        id: 'dates',
        title: 'Dates',
        fields: ['installationDate'],
        columns: 2,
      },
    ],
  },
};
