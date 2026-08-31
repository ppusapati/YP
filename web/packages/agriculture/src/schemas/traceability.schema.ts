/**
 * Traceability Service Form Schemas
 * Based on agriculture.traceability.v1 protobuf definitions
 */
import type { FormSchema } from '@samavāya/core';

/** Form for creating a traceability record (CreateTraceabilityRecordRequest) */
export const traceabilityRecordSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'batch_id', label: 'Batch ID', required: true, placeholder: 'Unique batch identifier' },
    { type: 'text', name: 'product_name', label: 'Product Name', required: true, placeholder: 'Name of the product' },
    { type: 'select', name: 'farm_id', label: 'Farm', required: true, options: [], searchable: true }, // RPC: FarmService.ListFarms
    { type: 'select', name: 'field_id', label: 'Field', options: [], searchable: true }, // RPC: FieldService.ListFields
    { type: 'select', name: 'crop_id', label: 'Crop', options: [], searchable: true }, // RPC: CropService.ListCrops
    { type: 'date', name: 'harvest_date', label: 'Harvest Date' },
    { type: 'date', name: 'processing_date', label: 'Processing Date' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'product',
        title: 'Product Details',
        fields: ['batch_id', 'product_name', 'farm_id', 'field_id', 'crop_id'],
        columns: 2,
      },
      {
        id: 'dates',
        title: 'Key Dates',
        fields: ['harvest_date', 'processing_date'],
        columns: 2,
      },
    ],
  },
};

/** Form for adding a certification (AddCertificationRequest) */
export const certificationSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'record_id', label: 'Traceability Record ID', required: true, placeholder: 'Linked record ID' },
    { type: 'select', name: 'cert_type', label: 'Certification Type', required: true, options: [
      { label: 'Organic', value: 'CERT_TYPE_ORGANIC' },
      { label: 'GAP (Good Agricultural Practice)', value: 'CERT_TYPE_GAP' },
      { label: 'Fairtrade', value: 'CERT_TYPE_FAIRTRADE' },
      { label: 'Rainforest Alliance', value: 'CERT_TYPE_RAINFOREST_ALLIANCE' },
      { label: 'USDA Organic', value: 'CERT_TYPE_USDA_ORGANIC' },
      { label: 'EU Organic', value: 'CERT_TYPE_EU_ORGANIC' },
    ] },
    { type: 'text', name: 'cert_body', label: 'Certifying Body', required: true, placeholder: 'Name of certifying organization' },
    { type: 'text', name: 'cert_number', label: 'Certificate Number', required: true, placeholder: 'Certificate reference number' },
    { type: 'date', name: 'issue_date', label: 'Issue Date', required: true },
    { type: 'date', name: 'expiry_date', label: 'Expiry Date', required: true },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'certification',
        title: 'Certification Details',
        fields: ['record_id', 'cert_type', 'cert_body', 'cert_number'],
        columns: 2,
      },
      {
        id: 'validity',
        title: 'Validity Period',
        fields: ['issue_date', 'expiry_date'],
        columns: 2,
      },
    ],
  },
};

/** Form for recording a supply chain event (RecordSupplyEventRequest) */
export const supplyEventSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'record_id', label: 'Traceability Record ID', required: true, placeholder: 'Linked record ID' },
    { type: 'select', name: 'event_type', label: 'Event Type', required: true, options: [
      { label: 'Harvest', value: 'EVENT_TYPE_HARVEST' },
      { label: 'Processing', value: 'EVENT_TYPE_PROCESSING' },
      { label: 'Transport', value: 'EVENT_TYPE_TRANSPORT' },
      { label: 'Storage', value: 'EVENT_TYPE_STORAGE' },
    ] },
    { type: 'text', name: 'location', label: 'Location', placeholder: 'Where the event occurred' },
    { type: 'datetime', name: 'timestamp', label: 'Timestamp', required: true },
    { type: 'text', name: 'handler', label: 'Handler', placeholder: 'Person or organization handling the product' },
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3, placeholder: 'Additional event details' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'event',
        title: 'Event Details',
        fields: ['record_id', 'event_type', 'location', 'timestamp', 'handler'],
        columns: 2,
      },
      {
        id: 'notes',
        title: 'Notes',
        fields: ['notes'],
        columns: 1,
      },
    ],
  },
};
