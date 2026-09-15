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

/**
 * Form for a batch record (CreateBatchRequest / UpdateBatchRequest).
 *
 * Three pages imported `batchRecordFormSchema` from this package and no batch
 * schema existed, so the batch create and edit pages did not typecheck. The
 * fields are traceability.proto's BatchRecord, minus the ones the server owns
 * — id, tenant_id, version and the timestamps.
 */
export const batchRecordSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'record_id', label: 'Traceability Record ID', required: true, placeholder: 'Linked record ID' },
    { type: 'text', name: 'batch_number', label: 'Batch Number', required: true, placeholder: 'e.g. HARVEST-01H8Z…' },
    { type: 'number', name: 'quantity', label: 'Quantity', required: true, min: 0 },
    { type: 'text', name: 'unit', label: 'Unit', required: true, placeholder: 'kg, quintal, crate' },
    { type: 'number', name: 'weight_kg', label: 'Weight (kg)', min: 0, step: 0.01 },
    { type: 'date', name: 'production_date', label: 'Production Date' },
    // Not required: a fresh crate leaving the farm has no expiry yet, and
    // making this mandatory would have people invent one.
    { type: 'date', name: 'expiry_date', label: 'Expiry Date' },
    { type: 'text', name: 'quality_grade', label: 'Quality Grade', placeholder: 'A, B, Export' },
    { type: 'textarea', name: 'storage_conditions', label: 'Storage Conditions', placeholder: 'Temperature, humidity, handling notes' },
    { type: 'text', name: 'crop_cycle_id', label: 'Crop Cycle ID' },
    { type: 'text', name: 'yield_record_id', label: 'Yield Record ID' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'identity',
        title: 'Batch',
        fields: ['record_id', 'batch_number', 'quality_grade'],
        columns: 2,
      },
      {
        id: 'quantity',
        title: 'Quantity',
        fields: ['quantity', 'unit', 'weight_kg'],
        columns: 3,
      },
      {
        id: 'dates',
        title: 'Dates and Storage',
        fields: ['production_date', 'expiry_date', 'storage_conditions'],
        columns: 2,
      },
      {
        id: 'links',
        title: 'Linked Records',
        fields: ['crop_cycle_id', 'yield_record_id'],
        columns: 2,
      },
    ],
  },
};
