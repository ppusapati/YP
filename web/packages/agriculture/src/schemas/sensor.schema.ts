/**
 * Sensor Form Schema
 */
import type { FormSchema } from '@samavāya/core';

export const sensorFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'name', label: 'Sensor Name', required: true },
    { type: 'text', name: 'code', label: 'Sensor Code', required: true },
    { type: 'text', name: 'field_id', label: 'Field', required: true },
    {
      type: 'select', name: 'sensor_type', label: 'Sensor Type', required: true,
      options: [
        { label: 'Soil Moisture', value: 'soil_moisture' },
        { label: 'Temperature', value: 'temperature' },
        { label: 'Humidity', value: 'humidity' },
        { label: 'Soil Temperature', value: 'soil_temperature' },
        { label: 'Soil pH', value: 'soil_ph' },
        { label: 'Soil EC', value: 'soil_ec' },
        { label: 'Rainfall', value: 'rainfall' },
        { label: 'Wind Speed', value: 'wind_speed' },
        { label: 'Wind Direction', value: 'wind_direction' },
        { label: 'Solar Radiation', value: 'solar_radiation' },
        { label: 'Leaf Wetness', value: 'leaf_wetness' },
        { label: 'CO2', value: 'co2' },
        { label: 'Water Level', value: 'water_level' },
        { label: 'Flow Rate', value: 'flow_rate' },
        { label: 'Pressure', value: 'pressure' },
      ],
    } as any,
    { type: 'text', name: 'manufacturer', label: 'Manufacturer' },
    { type: 'text', name: 'model', label: 'Model' },
    { type: 'text', name: 'serial_number', label: 'Serial Number' },
    { type: 'text', name: 'firmware_version', label: 'Firmware Version' },
    { type: 'number', name: 'latitude', label: 'Latitude', step: 0.000001, min: -90, max: 90 } as any,
    { type: 'number', name: 'longitude', label: 'Longitude', step: 0.000001, min: -180, max: 180 } as any,
    { type: 'date', name: 'installation_date', label: 'Installation Date' } as any,
    { type: 'number', name: 'reading_interval_seconds', label: 'Reading Interval (sec)', min: 1 } as any,
    { type: 'text', name: 'unit_of_measurement', label: 'Unit of Measurement', placeholder: 'e.g. °C, %, mm' },
    { type: 'number', name: 'min_value', label: 'Min Expected Value' } as any,
    { type: 'number', name: 'max_value', label: 'Max Expected Value' } as any,
    { type: 'date', name: 'calibration_date', label: 'Last Calibration' } as any,
    { type: 'text', name: 'network_id', label: 'Network ID', placeholder: 'Sensor network identifier' },
    { type: 'number', name: 'battery_level', label: 'Battery Level (%)', min: 0, max: 100 } as any,
    { type: 'number', name: 'signal_strength', label: 'Signal Strength (dBm)' } as any,
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Online', value: 'online' },
        { label: 'Offline', value: 'offline' },
        { label: 'Maintenance', value: 'maintenance' },
        { label: 'Faulty', value: 'faulty' },
        { label: 'Decommissioned', value: 'decommissioned' },
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
        title: 'Sensor Details',
        fields: ['name', 'code', 'field_id', 'sensor_type', 'status'],
        columns: 2,
      },
      {
        id: 'hardware',
        title: 'Hardware',
        fields: ['manufacturer', 'model', 'serial_number', 'firmware_version', 'installation_date', 'calibration_date'],
        columns: 2,
      },
      {
        id: 'location',
        title: 'Location',
        fields: ['latitude', 'longitude', 'network_id'],
        columns: 3,
      },
      {
        id: 'config',
        title: 'Configuration',
        fields: ['reading_interval_seconds', 'unit_of_measurement', 'min_value', 'max_value'],
        columns: 2,
      },
      {
        id: 'health',
        title: 'Health',
        fields: ['battery_level', 'signal_strength'],
        columns: 2,
      },
    ],
  },
};
