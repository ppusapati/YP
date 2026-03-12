import type { FormSchema } from '@samavāya/core';

export const traceabilityRecordFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'farmId', label: 'Farm', required: true },
    { type: 'text', name: 'fieldId', label: 'Field', required: true },
    { type: 'text', name: 'cropId', label: 'Crop' },
    { type: 'text', name: 'batchNumber', label: 'Batch Number', required: true },
    { type: 'text', name: 'productType', label: 'Product Type' },
    { type: 'text', name: 'originCountry', label: 'Origin Country' },
    { type: 'text', name: 'originRegion', label: 'Origin Region' },
    { type: 'text', name: 'seedSource', label: 'Seed Source' },
    { type: 'date', name: 'plantingDate', label: 'Planting Date' } as any,
    { type: 'date', name: 'harvestDate', label: 'Harvest Date' } as any,
    { type: 'date', name: 'processingDate', label: 'Processing Date' } as any,
    { type: 'date', name: 'packagingDate', label: 'Packaging Date' } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'product_info',
        title: 'Product Information',
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
    { type: 'text', name: 'farmId', label: 'Farm', required: true },
    {
      type: 'select', name: 'certificationType', label: 'Certification Type', required: true,
      options: [
        { label: 'Organic', value: '1' },
        { label: 'GAP', value: '2' },
        { label: 'Fairtrade', value: '3' },
        { label: 'Rainforest Alliance', value: '4' },
        { label: 'USDA Organic', value: '5' },
        { label: 'EU Organic', value: '6' },
      ],
    } as any,
    { type: 'text', name: 'certifyingBody', label: 'Certifying Body' },
    { type: 'text', name: 'scope', label: 'Scope' },
    { type: 'date', name: 'issueDate', label: 'Issue Date' } as any,
    { type: 'date', name: 'expiryDate', label: 'Expiry Date' } as any,
    { type: 'text', name: 'certificateNumber', label: 'Certificate Number' },
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Active', value: '1' },
        { label: 'Expired', value: '2' },
        { label: 'Revoked', value: '3' },
        { label: 'Pending', value: '4' },
      ],
    } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'cert_details',
        title: 'Certification Details',
        fields: ['farmId', 'certificationType', 'certifyingBody', 'scope', 'certificateNumber', 'status'],
        columns: 2,
      },
      {
        id: 'dates',
        title: 'Dates',
        fields: ['issueDate', 'expiryDate'],
        columns: 2,
      },
    ],
  },
};

export const batchRecordFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'farmId', label: 'Farm', required: true },
    { type: 'text', name: 'fieldId', label: 'Field' },
    { type: 'text', name: 'cropId', label: 'Crop' },
    { type: 'text', name: 'batchNumber', label: 'Batch Number', required: true },
    { type: 'text', name: 'productType', label: 'Product Type' },
    { type: 'number', name: 'quantity', label: 'Quantity' } as any,
    { type: 'text', name: 'unit', label: 'Unit' },
    { type: 'date', name: 'productionDate', label: 'Production Date' } as any,
    { type: 'date', name: 'expiryDate', label: 'Expiry Date' } as any,
    { type: 'text', name: 'processingFacility', label: 'Processing Facility' },
    { type: 'number', name: 'qualityScore', label: 'Quality Score', min: 0, max: 100 } as any,
    { type: 'textarea', name: 'storageConditions', label: 'Storage Conditions', rows: 2 } as any,
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3 } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'batch_details',
        title: 'Batch Details',
        fields: ['farmId', 'fieldId', 'cropId', 'batchNumber', 'productType'],
        columns: 2,
      },
      {
        id: 'production',
        title: 'Production',
        fields: ['quantity', 'unit', 'productionDate', 'expiryDate', 'processingFacility'],
        columns: 2,
      },
      {
        id: 'quality',
        title: 'Quality',
        fields: ['qualityScore', 'storageConditions', 'notes'],
        columns: 2,
      },
    ],
  },
};
