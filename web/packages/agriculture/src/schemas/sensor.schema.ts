/**
 * Sensor Service Form Schemas
 * Based on agriculture.sensor.v1 protobuf definitions
 */
import type { FormSchema } from '@samavāya/core';

/** Form for registering a sensor (RegisterSensorRequest) */
export const registerSensorSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'select', name: 'field_id', label: 'Field', required: true, options: [], searchable: true }, // RPC: FieldService.ListFields
    { type: 'text', name: 'name', label: 'Sensor Name', required: true, placeholder: 'Enter sensor name' },
    { type: 'select', name: 'sensor_type', label: 'Sensor Type', required: true, options: [
      { label: 'Soil Moisture', value: 'SENSOR_TYPE_SOIL_MOISTURE' },
      { label: 'Soil pH', value: 'SENSOR_TYPE_SOIL_PH' },
      { label: 'Temperature', value: 'SENSOR_TYPE_TEMPERATURE' },
      { label: 'Humidity', value: 'SENSOR_TYPE_HUMIDITY' },
      { label: 'Rainfall', value: 'SENSOR_TYPE_RAINFALL' },
      { label: 'Wind Speed', value: 'SENSOR_TYPE_WIND_SPEED' },
      { label: 'Wind Direction', value: 'SENSOR_TYPE_WIND_DIRECTION' },
      { label: 'Light Intensity', value: 'SENSOR_TYPE_LIGHT_INTENSITY' },
      { label: 'Leaf Wetness', value: 'SENSOR_TYPE_LEAF_WETNESS' },
    ] },
    { type: 'text', name: 'manufacturer', label: 'Manufacturer', placeholder: 'Sensor manufacturer' },
    { type: 'text', name: 'model', label: 'Model', placeholder: 'Sensor model number' },
    { type: 'select', name: 'protocol', label: 'Communication Protocol', options: [
      { label: 'MQTT', value: 'PROTOCOL_MQTT' },
      { label: 'LoRaWAN', value: 'PROTOCOL_LORAWAN' },
      { label: 'Zigbee', value: 'PROTOCOL_ZIGBEE' },
      { label: 'WiFi', value: 'PROTOCOL_WIFI' },
      { label: 'Cellular', value: 'PROTOCOL_CELLULAR' },
    ] },
    { type: 'number', name: 'latitude', label: 'Latitude', min: -90, max: 90, step: 0.000001 },
    { type: 'number', name: 'longitude', label: 'Longitude', min: -180, max: 180, step: 0.000001 },
    { type: 'date', name: 'installation_date', label: 'Installation Date' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Sensor Details',
        fields: ['field_id', 'name', 'sensor_type', 'manufacturer', 'model', 'protocol'],
        columns: 2,
      },
      {
        id: 'location',
        title: 'Location & Installation',
        fields: ['latitude', 'longitude', 'installation_date'],
        columns: 2,
      },
    ],
  },
};

/** Form for creating an alert rule (CreateAlertRuleRequest) */
export const alertRuleSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'select', name: 'sensor_id', label: 'Sensor', required: true, options: [], searchable: true }, // RPC: SensorService.ListSensors
    { type: 'text', name: 'metric', label: 'Metric', required: true, placeholder: 'e.g. soil_moisture, temperature' },
    { type: 'select', name: 'condition', label: 'Condition', required: true, options: [
      { label: 'Greater Than', value: 'CONDITION_GREATER_THAN' },
      { label: 'Less Than', value: 'CONDITION_LESS_THAN' },
      { label: 'Equal To', value: 'CONDITION_EQUAL_TO' },
      { label: 'Greater Than or Equal', value: 'CONDITION_GREATER_EQUAL' },
      { label: 'Less Than or Equal', value: 'CONDITION_LESS_EQUAL' },
      { label: 'Out of Range', value: 'CONDITION_OUT_OF_RANGE' },
    ] },
    { type: 'number', name: 'threshold', label: 'Threshold Value', required: true, step: 0.01 },
    { type: 'select', name: 'severity', label: 'Severity', required: true, options: [
      { label: 'Info', value: 'SEVERITY_INFO' },
      { label: 'Warning', value: 'SEVERITY_WARNING' },
      { label: 'Critical', value: 'SEVERITY_CRITICAL' },
      { label: 'Emergency', value: 'SEVERITY_EMERGENCY' },
    ] },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'rule',
        title: 'Alert Rule',
        fields: ['sensor_id', 'metric', 'condition', 'threshold', 'severity'],
        columns: 2,
      },
    ],
  },
};

/** Form for calibrating a sensor (CalibrateSensorRequest) */
export const calibrateSensorSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'select', name: 'sensor_id', label: 'Sensor', required: true, options: [], searchable: true }, // RPC: SensorService.ListSensors
    { type: 'number', name: 'reference_value', label: 'Reference Value', required: true, step: 0.001, helperText: 'Known accurate value from calibration standard' },
    { type: 'number', name: 'measured_value', label: 'Measured Value', required: true, step: 0.001, helperText: 'Value currently reported by the sensor' },
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3, placeholder: 'Calibration notes, conditions, etc.' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'calibration',
        title: 'Sensor Calibration',
        fields: ['sensor_id', 'reference_value', 'measured_value', 'notes'],
        columns: 2,
      },
    ],
  },
};
