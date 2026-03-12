/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { FormSchema } from '@samavāya/core';
import { cropClient, farmClient, fieldClient } from '../services';

export const traceabilityRecordFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'fieldId', label: 'Field', loadOptions: async (query: string) => {
        const res = await fieldClient.listFields({ search: query, pageSize: 50 });
        return (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'cropId', label: 'Crop', loadOptions: async (query: string) => {
        const res = await cropClient.listCrops({ search: query, pageSize: 50 });
        return (res.crops || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'text', name: 'batchNumber', label: 'Batch Number', required: true },
    { type: 'text', name: 'productType', label: 'Product Type' },
    { type: 'text', name: 'originCountry', label: 'Origin Country' },
    { type: 'text', name: 'originRegion', label: 'Origin Region' },
    { type: 'text', name: 'seedSource', label: 'Seed Source' },
    { type: 'date', name: 'plantingDate', label: 'Planting Date' },
    { type: 'date', name: 'harvestDate', label: 'Harvest Date' },
    { type: 'date', name: 'processingDate', label: 'Processing Date' },
    { type: 'date', name: 'packagingDate', label: 'Packaging Date' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Traceability Record Details',
        fields: ['farmId', 'fieldId', 'cropId', 'batchNumber', 'productType', 'originCountry', 'originRegion', 'seedSource'],
        columns: 2,
      },
      {
        id: 'dates',
        title: 'Dates',
        fields: ['plantingDate', 'harvestDate', 'processingDate', 'packagingDate'],
        columns: 2,
      },
    ],
  },
};

export const certificationFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'recordId', label: 'Record Id' },
    { type: 'select', name: 'certType', label: 'Cert Type', options: [
        { label: 'Organic', value: '1' },
        { label: 'Gap', value: '2' },
        { label: 'Fairtrade', value: '3' },
        { label: 'Rainforest Alliance', value: '4' },
        { label: 'Usda Organic', value: '5' },
        { label: 'Eu Organic', value: '6' },
      ] },
    { type: 'text', name: 'certNumber', label: 'Cert Number' },
    { type: 'text', name: 'issuedBy', label: 'Issued By' },
    { type: 'date', name: 'issuedDate', label: 'Issued Date' },
    { type: 'date', name: 'expiryDate', label: 'Expiry Date' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Certification Details',
        fields: ['certType', 'recordId', 'certNumber', 'issuedBy'],
        columns: 2,
      },
      {
        id: 'dates',
        title: 'Dates',
        fields: ['issuedDate', 'expiryDate'],
        columns: 2,
      },
    ],
  },
};

export const batchRecordFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'recordId', label: 'Record Id' },
    { type: 'text', name: 'batchNumber', label: 'Batch Number', required: true },
    { type: 'number', name: 'quantity', label: 'Quantity', step: 1 },
    { type: 'text', name: 'unit', label: 'Unit' },
    { type: 'date', name: 'productionDate', label: 'Production Date' },
    { type: 'date', name: 'expiryDate', label: 'Expiry Date' },
    { type: 'textarea', name: 'storageConditions', label: 'Storage Conditions', rows: 3 },
    { type: 'text', name: 'qualityGrade', label: 'Quality Grade' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Batch Record Details',
        fields: ['recordId', 'batchNumber', 'unit', 'storageConditions', 'qualityGrade'],
        columns: 2,
      },
      {
        id: 'metrics',
        title: 'Measurements & Metrics',
        fields: ['quantity'],
        columns: 2,
      },
      {
        id: 'dates',
        title: 'Dates',
        fields: ['productionDate', 'expiryDate'],
        columns: 2,
      },
    ],
  },
};
