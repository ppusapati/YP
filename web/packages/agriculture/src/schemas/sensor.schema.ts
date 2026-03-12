/**
 * Sensor Form Schema — derived from agriculture.sensor.v1 proto
 */
import type { FormSchema } from '@samavāya/core';

export const sensorFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'fieldId', label: 'Field', placeholder: 'Select field', required: true },
    { type: 'text', name: 'farmId', label: 'Farm', placeholder: 'Select farm', required: true },
    {
      type: 'select', name: 'sensorType', label: 'Sensor Type', required: true,
      options: [
        { label: 'Soil Moisture', value: '1' },
        { label: 'Soil pH', value: '2' },
        { label: 'Temperature', value: '3' },
        { label: 'Humidity', value: '4' },
        { label: 'Rainfall', value: '5' },
        { label: 'Wind Speed', value: '6' },
        { label: 'Wind Direction', value: '7' },
        { label: 'Light Intensity', value: '8' },
        { label: 'Leaf Wetness', value: '9' },
      ],
    } as any,
    { type: 'text', name: 'deviceId', label: 'Device ID', required: true },
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Active', value: '1' },
        { label: 'Inactive', value: '2' },
        { label: 'Maintenance', value: '3' },
        { label: 'Decommissioned', value: '4' },
      ],
    } as any,
    { type: 'text', name: 'manufacturer', label: 'Manufacturer' },
    { type: 'text', name: 'model', label: 'Model' },
    { type: 'text', name: 'firmwareVersion', label: 'Firmware Version' },
    {
      type: 'select', name: 'protocol', label: 'Protocol',
      options: [
        { label: 'MQTT', value: '1' },
        { label: 'LoRaWAN', value: '2' },
        { label: 'Zigbee', value: '3' },
        { label: 'WiFi', value: '4' },
        { label: 'Cellular', value: '5' },
      ],
    } as any,
    { type: 'number', name: 'readingIntervalSeconds', label: 'Reading Interval (sec)', min: 1 } as any,
    { type: 'number', name: 'latitude', label: 'Latitude', step: 0.000001, min: -90, max: 90 } as any,
    { type: 'number', name: 'longitude', label: 'Longitude', step: 0.000001, min: -180, max: 180 } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'details',
        title: 'Sensor Details',
        fields: ['fieldId', 'farmId', 'sensorType', 'deviceId', 'status'],
        columns: 2,
      },
      {
        id: 'hardware',
        title: 'Hardware Info',
        fields: ['manufacturer', 'model', 'firmwareVersion', 'protocol'],
        columns: 2,
      },
      {
        id: 'location_config',
        title: 'Location & Configuration',
        fields: ['latitude', 'longitude', 'readingIntervalSeconds'],
        columns: 3,
      },
    ],
  },
};
