#!/usr/bin/env node
/**
 * Proto → Form Schema + Report Schema Code Generator
 *
 * Reads protoc-gen-es v2 generated _pb.ts files and produces:
 *   1. Form schemas (FormSchema<Record<string, unknown>>) with enum dropdowns + RPC lookups
 *   2. Report schemas (ReportVisualization) with table columns + KPI widgets
 *
 * Usage: node scripts/generate-schemas.mjs
 */

import { readFileSync, writeFileSync, mkdirSync, readdirSync, statSync } from 'node:fs';
import { join, basename, dirname } from 'node:path';

// ─── Configuration ──────────────────────────────────────────────────────────

const PROTO_GEN_DIR = join(dirname(new URL(import.meta.url).pathname), '../../proto/src/gen');
const SCHEMAS_OUT_DIR = join(dirname(new URL(import.meta.url).pathname), '../src/schemas');
const REPORTS_OUT_DIR = join(SCHEMAS_OUT_DIR, 'reports');

/** Fields to skip in form schemas (audit/system fields) */
const SKIP_FIELDS = new Set([
  'id', 'tenantId', 'version', 'createdAt', 'updatedAt', 'createdBy', 'updatedBy',
  'deletedAt', 'deletedBy', 'isActive',
]);

/** Fields to skip in report table columns (too internal) */
const SKIP_REPORT_FIELDS = new Set([
  'tenantId', 'version', 'createdBy', 'updatedBy', 'deletedAt', 'deletedBy',
]);

/** FK field → { client, listMethod, responseKey, labelField } */
const FK_LOOKUPS = {
  farmId: { client: 'farmClient', method: 'listFarms', key: 'farms', label: 'name', entity: 'Farm' },
  fieldId: { client: 'fieldClient', method: 'listFields', key: 'fields', label: 'name', entity: 'Field' },
  cropId: { client: 'cropClient', method: 'listCrops', key: 'crops', label: 'name', entity: 'Crop' },
  currentCropId: { client: 'cropClient', method: 'listCrops', key: 'crops', label: 'name', entity: 'Crop' },
  sensorId: { client: 'sensorClient', method: 'listSensors', key: 'sensors', label: 'name', entity: 'Sensor' },
  zoneId: { client: 'irrigationClient', method: 'getIrrigationZones', key: 'zones', label: 'name', entity: 'Irrigation Zone' },
  controllerId: { client: 'irrigationClient', method: 'getWaterControllers', key: 'controllers', label: 'name', entity: 'Controller' },
  pestSpeciesId: { client: 'pestClient', method: 'listPestSpecies', key: 'species', label: 'commonName', entity: 'Pest Species' },
  plantSpeciesId: { client: 'diagnosisClient', method: 'listDiseases', key: 'diseases', label: 'name', entity: 'Plant Species' },
  imageId: { client: 'satelliteClient', method: 'listImages', key: 'images', label: 'id', entity: 'Satellite Image' },
};

// ─── Proto File Parser ──────────────────────────────────────────────────────

function findPbFiles(dir) {
  const results = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) {
      results.push(...findPbFiles(full));
    } else if (entry.endsWith('_pb.ts')) {
      results.push(full);
    }
  }
  return results;
}

function parseEnums(content) {
  const enums = {};
  const enumRegex = /export enum (\w+) \{([^}]+)\}/g;
  let match;
  while ((match = enumRegex.exec(content)) !== null) {
    const enumName = match[1];
    const body = match[2];
    const values = [];
    const seen = new Set();
    // Only match actual TS enum members (lines starting with identifier = number,)
    // Skip @generated comments by matching lines that start with an identifier (not *)
    const lines = body.split('\n');
    for (const line of lines) {
      const trimmed = line.trim();
      // Match: IDENTIFIER = NUMBER, (TS enum member, not inside comment)
      const m = trimmed.match(/^(\w+)\s*=\s*(\d+),?\s*$/);
      if (m) {
        const num = parseInt(m[2], 10);
        if (num === 0) continue; // skip UNSPECIFIED
        if (!seen.has(num)) {
          seen.add(num);
          values.push({ name: m[1], value: num });
        }
      }
    }
    enums[enumName] = values;
  }
  return enums;
}

function parseMessages(content) {
  const messages = {};
  // Match: export type MessageName = Message<"pkg.name"> & { ... };
  const msgRegex = /export type (\w+) = Message<"([^"]+)"> & \{([\s\S]*?)\n\};/g;
  let match;
  while ((match = msgRegex.exec(content)) !== null) {
    const msgName = match[1];
    const fullName = match[2];
    const body = match[3];

    const fields = [];
    // Match @generated from field: [repeated] TYPE NAME = NUM; followed by TS property
    const fieldRegex = /@generated from field: (repeated )?([\w.]+) (\w+) = (\d+);\s*\n\s*\*\/\s*\n\s*(\w+)(\??): ([^;]+);/g;
    let fm;
    while ((fm = fieldRegex.exec(body)) !== null) {
      fields.push({
        isRepeated: !!fm[1],
        protoType: fm[2],
        protoName: fm[3],
        fieldNumber: parseInt(fm[4], 10),
        tsName: fm[5],
        isOptional: !!fm[6],
        tsType: fm[7].trim(),
      });
    }

    // Also handle map fields: @generated from field: map<string, string> name = N;
    const mapFieldRegex = /@generated from field: map<([^,]+),\s*([^>]+)> (\w+) = (\d+);\s*\n\s*\*\/\s*\n\s*(\w+)(\??): ([^;]+);/g;
    while ((fm = mapFieldRegex.exec(body)) !== null) {
      fields.push({
        isRepeated: false,
        isMap: true,
        protoType: `map<${fm[1]},${fm[2]}>`,
        protoName: fm[3],
        fieldNumber: parseInt(fm[4], 10),
        tsName: fm[5],
        isOptional: !!fm[6],
        tsType: fm[7].trim(),
      });
    }

    messages[msgName] = { fullName, fields };
  }
  return messages;
}

function parseServices(content) {
  const services = {};
  // Match service descriptors
  const svcRegex = /export const (\w+): GenService<\{([\s\S]*?)\}> =/g;
  let match;
  while ((match = svcRegex.exec(content)) !== null) {
    const svcName = match[1];
    const body = match[2];
    const methods = [];
    const methodRegex = /(\w+): \{\s*methodKind: "(\w+)";\s*input: typeof (\w+);\s*output: typeof (\w+);/g;
    let mm;
    while ((mm = methodRegex.exec(body)) !== null) {
      methods.push({
        name: mm[1],
        kind: mm[2],
        inputSchema: mm[3].replace(/Schema$/, ''),
        outputSchema: mm[4].replace(/Schema$/, ''),
      });
    }
    services[svcName] = methods;
  }
  return services;
}

// ─── Schema Generation Helpers ──────────────────────────────────────────────

function snakeToCamel(s) {
  return s.replace(/_([a-z])/g, (_, c) => c.toUpperCase());
}

function camelToTitle(s) {
  return s
    .replace(/([A-Z])/g, ' $1')
    .replace(/^./, c => c.toUpperCase())
    .trim();
}

function enumValueToLabel(enumName, valueName) {
  // TS enum values are already stripped of prefix by protoc-gen-es v2:
  // CROP, LIVESTOCK, MIXED, etc. (not FARM_TYPE_CROP)
  // Just convert SCREAMING_CASE to Title Case
  return valueName
    .toLowerCase()
    .split('_')
    .map(w => w.charAt(0).toUpperCase() + w.slice(1))
    .join(' ');
}

function isEnumType(protoType, allEnums) {
  // Proto type like "agriculture.farm.v1.FarmType"
  const shortName = protoType.split('.').pop();
  return shortName && shortName in allEnums;
}

function getEnumName(protoType) {
  return protoType.split('.').pop();
}

function isTimestampType(protoType) {
  return protoType === 'google.protobuf.Timestamp';
}

function isMessageType(protoType) {
  return protoType.includes('.') && !isTimestampType(protoType);
}

function isFkField(tsName) {
  return tsName in FK_LOOKUPS;
}

function fieldToFormField(field, allEnums) {
  const { tsName, protoType, isRepeated, isMap } = field;

  if (SKIP_FIELDS.has(tsName)) return null;
  if (isMap) return null; // skip map fields for forms
  if (isRepeated && isMessageType(protoType)) return null; // skip repeated nested messages

  const label = camelToTitle(tsName);

  // FK lookup fields
  if (isFkField(tsName)) {
    const lookup = FK_LOOKUPS[tsName];
    return {
      type: 'autocomplete',
      name: tsName,
      label: lookup.entity,
      required: tsName === 'farmId',
      _lookup: lookup,
    };
  }

  // Enum fields → select
  if (isEnumType(protoType, allEnums)) {
    const enumName = getEnumName(protoType);
    const enumValues = allEnums[enumName] || [];
    return {
      type: 'select',
      name: tsName,
      label,
      options: enumValues.map(v => ({
        label: enumValueToLabel(enumName, v.name),
        value: String(v.value),
      })),
    };
  }

  // Timestamp → date
  if (isTimestampType(protoType)) {
    return { type: 'date', name: tsName, label };
  }

  // Nested message → skip (too complex for flat form)
  if (isMessageType(protoType) && !isRepeated) {
    return null;
  }

  // Boolean → checkbox
  if (protoType === 'bool') {
    return { type: 'checkbox', name: tsName, label };
  }

  // Number types
  if (['double', 'float'].includes(protoType)) {
    const extra = {};
    if (tsName.toLowerCase().includes('pct') || tsName.toLowerCase().includes('percent')) {
      extra.min = 0;
      extra.max = 100;
    }
    if (tsName.toLowerCase().includes('hectare') || tsName.toLowerCase().includes('meter') ||
        tsName.toLowerCase().includes('liter') || tsName.toLowerCase().includes('rate')) {
      extra.min = 0;
      extra.step = 0.01;
    }
    if (tsName.toLowerCase().includes('latitude')) {
      extra.min = -90; extra.max = 90; extra.step = 0.000001;
    }
    if (tsName.toLowerCase().includes('longitude')) {
      extra.min = -180; extra.max = 180; extra.step = 0.000001;
    }
    return { type: 'number', name: tsName, label, ...extra };
  }

  if (['int32', 'int64', 'uint32', 'uint64', 'sint32', 'sint64'].includes(protoType)) {
    const extra = {};
    if (tsName === 'year') {
      extra.min = 2000; extra.max = 2100;
    }
    if (tsName.toLowerCase().includes('minutes') || tsName.toLowerCase().includes('seconds') ||
        tsName.toLowerCase().includes('hours') || tsName.toLowerCase().includes('days')) {
      extra.min = 0;
    }
    return { type: 'number', name: tsName, label, step: 1, ...extra };
  }

  // String fields
  if (protoType === 'string') {
    const required = tsName === 'name' || tsName === 'batchNumber';
    if (tsName === 'description' || tsName === 'notes' || tsName.toLowerCase().includes('plan') ||
        tsName.toLowerCase().includes('conditions') || tsName.toLowerCase().includes('targets')) {
      return { type: 'textarea', name: tsName, label, rows: 3 };
    }
    if (tsName.toLowerCase().includes('url') || tsName.toLowerCase().includes('image_url')) {
      return { type: 'url', name: tsName, label, placeholder: 'https://...' };
    }
    if (tsName.toLowerCase().includes('email')) {
      return { type: 'email', name: tsName, label };
    }
    return { type: 'text', name: tsName, label, ...(required ? { required: true } : {}) };
  }

  return null;
}

// ─── Form Schema Section Layout ─────────────────────────────────────────────

function groupFieldsIntoSections(fields, entityName) {
  // Group fields by semantic category
  const fkFields = fields.filter(f => f._lookup);
  const enumFields = fields.filter(f => f.type === 'select');
  const dateFields = fields.filter(f => f.type === 'date');
  const numericFields = fields.filter(f => f.type === 'number');
  const textFields = fields.filter(f => f.type === 'text' || f.type === 'textarea' || f.type === 'url' || f.type === 'email');
  const boolFields = fields.filter(f => f.type === 'checkbox');

  const sections = [];
  const usedFields = new Set();

  // Section 1: Core / Basic Info (text fields + FK lookups + main enums)
  const coreFields = [
    ...fkFields.map(f => f.name),
    ...textFields.filter(f => ['name', 'description', 'notes'].includes(f.name) || f.name.endsWith('Name')).map(f => f.name),
    ...enumFields.filter(f => f.name.includes('type') || f.name.includes('Type') || f.name === 'category').map(f => f.name),
  ].filter(n => !usedFields.has(n));

  // Add remaining text fields not yet used
  const remainingText = textFields.filter(f => !coreFields.includes(f.name)).map(f => f.name);

  if (coreFields.length > 0 || remainingText.length > 0) {
    const sectionFields = [...new Set([...coreFields, ...remainingText])];
    sectionFields.forEach(f => usedFields.add(f));
    sections.push({
      id: 'basic',
      title: `${camelToTitle(entityName)} Details`,
      fields: sectionFields,
      columns: 2,
    });
  }

  // Section 2: Status & Classification (enum selects not yet used)
  const statusFields = enumFields
    .filter(f => !usedFields.has(f.name))
    .map(f => f.name);
  if (statusFields.length > 0) {
    statusFields.forEach(f => usedFields.add(f));
    sections.push({
      id: 'classification',
      title: 'Status & Classification',
      fields: statusFields,
      columns: 2,
    });
  }

  // Section 3: Measurements & Metrics (numbers)
  const metricFields = numericFields
    .filter(f => !usedFields.has(f.name))
    .map(f => f.name);
  if (metricFields.length > 0) {
    metricFields.forEach(f => usedFields.add(f));
    sections.push({
      id: 'metrics',
      title: 'Measurements & Metrics',
      fields: metricFields,
      columns: 2,
    });
  }

  // Section 4: Dates
  const dateFieldNames = dateFields
    .filter(f => !usedFields.has(f.name))
    .map(f => f.name);
  if (dateFieldNames.length > 0) {
    dateFieldNames.forEach(f => usedFields.add(f));
    sections.push({
      id: 'dates',
      title: 'Dates',
      fields: dateFieldNames,
      columns: 2,
    });
  }

  // Section 5: Options (booleans)
  const boolFieldNames = boolFields
    .filter(f => !usedFields.has(f.name))
    .map(f => f.name);
  if (boolFieldNames.length > 0) {
    boolFieldNames.forEach(f => usedFields.add(f));
    sections.push({
      id: 'options',
      title: 'Options',
      fields: boolFieldNames,
      columns: 2,
    });
  }

  return sections;
}

// ─── Code Generation ────────────────────────────────────────────────────────

/**
 * Generate a single schema constant (no imports).
 * Returns { code, clients } where clients is the set of needed client imports.
 */
function generateFormSchemaBody(schemaName, fields, entityName) {
  const sections = groupFieldsIntoSections(fields, entityName);
  const clients = new Set();

  // Generate field definitions
  const fieldDefs = fields.map(f => {
    const parts = [];
    parts.push(`type: '${f.type}'`);
    parts.push(`name: '${f.name}'`);
    parts.push(`label: '${f.label || camelToTitle(f.name)}'`);

    if (f.placeholder) parts.push(`placeholder: '${f.placeholder}'`);
    if (f.required) parts.push(`required: true`);
    if (f.rows) parts.push(`rows: ${f.rows}`);
    if (f.min !== undefined) parts.push(`min: ${f.min}`);
    if (f.max !== undefined) parts.push(`max: ${f.max}`);
    if (f.step !== undefined) parts.push(`step: ${f.step}`);

    if (f.options) {
      const optStr = f.options
        .map(o => `        { label: '${o.label}', value: '${o.value}' }`)
        .join(',\n');
      parts.push(`options: [\n${optStr},\n      ]`);
    }

    if (f._lookup) {
      const lk = f._lookup;
      clients.add(lk.client);
      parts.push(`loadOptions: async (query: string) => {
        const res = await ${lk.client}.${lk.method}({ search: query, pageSize: 50 });
        return (res.${lk.key} || []).map((r: any) => ({ label: r.${lk.label} || r.id, value: r.id }));
      }`);
    }

    return `    { ${parts.join(', ')} }`;
  });

  // Generate sections
  const sectionDefs = sections.map(s => {
    return `      {\n        id: '${s.id}',\n        title: '${s.title}',\n        fields: [${s.fields.map(f => `'${f}'`).join(', ')}],\n        columns: ${s.columns},\n      }`;
  });

  const code = `export const ${schemaName}: FormSchema<Record<string, unknown>> = {
  fields: [
${fieldDefs.join(',\n')},
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
${sectionDefs.join(',\n')},
    ],
  },
};`;

  return { code, clients };
}

/**
 * Assemble a complete form schema file from one or more schema bodies.
 */
function assembleFormSchemaFile(schemas) {
  const allClients = new Set();
  for (const s of schemas) {
    for (const c of s.clients) allClients.add(c);
  }

  let imports = `/**\n * @generated from proto — DO NOT EDIT\n * Run: node scripts/generate-schemas.mjs\n */\nimport type { FormSchema } from '@samavāya/core';\n`;
  if (allClients.size > 0) {
    imports += `import { ${[...allClients].sort().join(', ')} } from '../services';\n`;
  }

  return imports + '\n' + schemas.map(s => s.code).join('\n\n') + '\n';
}

function generateReportSchemaCode(schemaName, entityFields, entityName) {
  // Filter fields for table columns
  const tableFields = entityFields.filter(f => {
    if (SKIP_REPORT_FIELDS.has(f.tsName)) return false;
    if (f.isRepeated || f.isMap) return false;
    if (isMessageType(f.protoType) && !isTimestampType(f.protoType)) return false;
    return true;
  });

  // Generate table columns
  const columns = tableFields.map(f => {
    const col = {
      field_code: f.tsName,
      header: camelToTitle(f.tsName),
      sortable: true,
    };

    if (['double', 'float', 'int32', 'int64'].includes(f.protoType)) {
      col.format = { type: 'number', decimal_places: f.protoType === 'double' || f.protoType === 'float' ? 2 : 0 };
      if (f.tsName.toLowerCase().includes('pct') || f.tsName.toLowerCase().includes('percent')) {
        col.format = { type: 'percent', decimal_places: 1 };
      }
    }
    if (isTimestampType(f.protoType)) {
      col.format = { type: 'date', date_format: 'YYYY-MM-DD' };
    }

    return col;
  });

  // Identify KPI-worthy numeric fields
  const numericFields = tableFields.filter(f =>
    ['double', 'float', 'int32', 'int64'].includes(f.protoType) && f.tsName !== 'id'
  );

  // Generate KPI widgets (up to 4)
  const kpiWidgets = numericFields.slice(0, 4).map((f, i) => {
    const isPct = f.tsName.toLowerCase().includes('pct') || f.tsName.toLowerCase().includes('percent');
    return {
      widget_id: `kpi-${f.tsName}`,
      title: camelToTitle(f.tsName),
      widget_type: 'kpi_card',
      grid_col: 1 + i * 6,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: f.tsName,
        aggregate: isPct ? 'avg' : 'sum',
        label: camelToTitle(f.tsName),
        format: isPct
          ? { type: 'percent', decimal_places: 1 }
          : { type: 'number', decimal_places: f.protoType === 'double' ? 2 : 0 },
      },
    };
  });

  // Table widget
  const tableWidget = {
    widget_id: `${entityName.toLowerCase()}-table`,
    title: `${camelToTitle(entityName)} Records`,
    widget_type: 'table',
    grid_col: 1,
    grid_row: kpiWidgets.length > 0 ? 3 : 1,
    grid_col_span: 24,
    grid_row_span: 8,
    table_config: {
      columns,
      default_sort_field: tableFields[0]?.tsName || 'id',
      default_sort_direction: 'asc',
      paginated: true,
      page_size: 25,
      exportable: true,
    },
  };

  const widgets = [...kpiWidgets, tableWidget];

  return `/**\n * @generated from proto — DO NOT EDIT\n * Run: node scripts/generate-schemas.mjs\n */\nimport type { ReportVisualization } from '@samavāya/core';\n\nexport const ${schemaName}: ReportVisualization = ${JSON.stringify({ layout_mode: 'grid', widgets }, null, 2).replace(/"(\w+)":/g, '$1:')};\n`;
}

// ─── Service Configuration ──────────────────────────────────────────────────

/**
 * Maps service file patterns to schema generation config.
 * entityMsg: The main entity message name
 * createMsg: The Create/Submit request message name
 * schemas: Array of { name, msg, exportName } for secondary schemas
 */
const SERVICE_CONFIGS = [
  {
    dir: 'farm-service',
    entityMsg: 'Farm',
    createMsg: 'CreateFarmRequest',
    file: 'farm',
    formExport: 'farmFormSchema',
    reportExport: 'farmReportSchema',
  },
  {
    dir: 'field-service',
    entityMsg: 'Field',
    createMsg: 'CreateFieldRequest',
    file: 'field',
    formExport: 'fieldFormSchema',
    reportExport: 'fieldReportSchema',
  },
  {
    dir: 'crop-service',
    entityMsg: 'Crop',
    createMsg: 'CreateCropRequest',
    file: 'crop',
    formExport: 'cropFormSchema',
    reportExport: 'cropReportSchema',
    extraSchemas: [
      { entityMsg: 'CropVariety', createMsg: 'AddVarietyRequest', formExport: 'cropVarietyFormSchema' },
    ],
  },
  {
    dir: 'soil-service',
    entityMsg: 'SoilSample',
    createMsg: 'CreateSoilSampleRequest',
    file: 'soil',
    formExport: 'soilSampleFormSchema',
    reportExport: 'soilSampleReportSchema',
  },
  {
    dir: 'sensor-service',
    entityMsg: 'Sensor',
    createMsg: 'RegisterSensorRequest',
    file: 'sensor',
    formExport: 'sensorFormSchema',
    reportExport: 'sensorReportSchema',
    altCreateMsg: 'CreateSensorRequest',
  },
  {
    dir: 'irrigation-service',
    entityMsg: 'IrrigationSchedule',
    createMsg: 'CreateScheduleRequest',
    file: 'irrigation',
    formExport: 'irrigationScheduleFormSchema',
    reportExport: 'irrigationScheduleReportSchema',
    extraSchemas: [
      { entityMsg: 'IrrigationZone', createMsg: 'CreateZoneRequest', formExport: 'irrigationZoneFormSchema' },
    ],
  },
  {
    dir: 'satellite-service',
    entityMsg: 'SatelliteImage',
    createMsg: 'RequestImageryRequest',
    file: 'satellite',
    formExport: 'satelliteImageFormSchema',
    reportExport: 'satelliteImageReportSchema',
  },
  {
    dir: 'pest-prediction-service',
    entityMsg: 'PestPrediction',
    createMsg: 'CreatePestPredictionRequest',
    file: 'pest',
    formExport: 'pestPredictionFormSchema',
    reportExport: 'pestPredictionReportSchema',
    extraSchemas: [
      { entityMsg: 'PestObservation', createMsg: 'ReportObservationRequest', formExport: 'pestObservationFormSchema' },
    ],
  },
  {
    dir: 'plant-diagnosis-service',
    entityMsg: 'DiagnosisRequest',
    createMsg: 'SubmitDiagnosisRequest',
    file: 'diagnosis',
    formExport: 'diagnosisRequestFormSchema',
    reportExport: 'diagnosisReportSchema',
  },
  {
    dir: 'yield-service',
    entityMsg: 'YieldPrediction',
    createMsg: 'PredictYieldRequest',
    file: 'yield',
    formExport: 'yieldPredictionFormSchema',
    reportExport: 'yieldPredictionReportSchema',
    extraSchemas: [
      { entityMsg: 'YieldRecord', createMsg: 'RecordYieldRequest', formExport: 'yieldRecordFormSchema' },
      { entityMsg: 'HarvestPlan', createMsg: 'CreateHarvestPlanRequest', formExport: 'harvestPlanFormSchema' },
    ],
  },
  {
    dir: 'traceability-service',
    entityMsg: 'TraceabilityRecord',
    createMsg: 'CreateRecordRequest',
    file: 'traceability',
    formExport: 'traceabilityRecordFormSchema',
    reportExport: 'traceabilityRecordReportSchema',
    extraSchemas: [
      { entityMsg: 'Certification', createMsg: 'CreateCertificationRequest', formExport: 'certificationFormSchema' },
      { entityMsg: 'BatchRecord', createMsg: 'CreateBatchRequest', formExport: 'batchRecordFormSchema' },
    ],
  },
];

// ─── Main ───────────────────────────────────────────────────────────────────

function main() {
  console.log('Proto → Schema Code Generator');
  console.log('─'.repeat(50));

  // Step 1: Parse all _pb.ts files
  const pbFiles = findPbFiles(PROTO_GEN_DIR);
  console.log(`Found ${pbFiles.length} proto-generated files`);

  // Collect ALL enums across all files
  const allEnums = {};
  const allMessages = {};
  const fileContents = {};

  for (const file of pbFiles) {
    const content = readFileSync(file, 'utf-8');
    const relPath = file.replace(PROTO_GEN_DIR + '/', '');
    fileContents[relPath] = content;

    const enums = parseEnums(content);
    Object.assign(allEnums, enums);

    const messages = parseMessages(content);
    Object.assign(allMessages, messages);
  }

  console.log(`Parsed ${Object.keys(allEnums).length} enums, ${Object.keys(allMessages).length} messages`);

  // Step 2: Generate form schemas
  mkdirSync(SCHEMAS_OUT_DIR, { recursive: true });
  mkdirSync(REPORTS_OUT_DIR, { recursive: true });

  const formExports = [];
  const reportExports = [];

  for (const config of SERVICE_CONFIGS) {
    const pbFile = pbFiles.find(f => f.includes(config.dir));
    if (!pbFile) {
      console.warn(`  SKIP: ${config.dir} — no _pb.ts file found`);
      continue;
    }

    console.log(`\nProcessing ${config.dir}...`);

    // Generate primary form schema
    const createMsg = allMessages[config.createMsg];
    const entityMsg = allMessages[config.entityMsg];

    let reportCode = '';
    const schemasBodies = []; // collect { code, clients } for the file

    // Helper: resolve source message (handles wrapper-style CreateRequests)
    function resolveSourceMsg(createMsgName, entityMsgObj) {
      const cMsg = allMessages[createMsgName];
      if (cMsg) {
        const nonSkip = cMsg.fields.filter(f => !SKIP_FIELDS.has(f.tsName));
        const entityField = nonSkip.find(f => isMessageType(f.protoType) && !isTimestampType(f.protoType) && !f.isRepeated);
        if (entityField && nonSkip.length <= 2) {
          return { msg: entityMsgObj, label: 'entity (wrapper)' };
        }
        return { msg: cMsg, label: 'create' };
      }
      if (entityMsgObj) return { msg: entityMsgObj, label: 'entity (fallback)' };
      return { msg: null, label: 'none' };
    }

    // Primary schema
    const { msg: sourceMsg, label: sourceLabel } = resolveSourceMsg(config.createMsg, entityMsg);
    if (sourceMsg) {
      const fields = sourceMsg.fields
        .map(f => fieldToFormField(f, allEnums))
        .filter(Boolean);
      const body = generateFormSchemaBody(config.formExport, fields, config.entityMsg);
      schemasBodies.push(body);
      formExports.push({ file: config.file, name: config.formExport });
      console.log(`  Form [${sourceLabel}]: ${config.formExport} (${fields.length} fields)`);
    } else {
      console.warn(`  WARN: No source message found for ${config.formExport}`);
    }

    // Extra schemas
    if (config.extraSchemas) {
      for (const extra of config.extraSchemas) {
        const extraEntity = allMessages[extra.entityMsg];
        const { msg: extraSource } = resolveSourceMsg(extra.createMsg, extraEntity);
        if (extraSource) {
          const fields = extraSource.fields
            .map(f => fieldToFormField(f, allEnums))
            .filter(Boolean);
          const entityLabel = extra.entityMsg || extra.createMsg.replace(/^Create|Request$/g, '');
          const body = generateFormSchemaBody(extra.formExport, fields, entityLabel);
          schemasBodies.push(body);
          formExports.push({ file: config.file, name: extra.formExport });
          console.log(`  Form: ${extra.formExport} (${fields.length} fields)`);
        }
      }
    }

    // Write form schema file (single file with consolidated imports)
    if (schemasBodies.length > 0) {
      writeFileSync(join(SCHEMAS_OUT_DIR, `${config.file}.schema.ts`), assembleFormSchemaFile(schemasBodies));
    }

    // Generate report schema
    if (entityMsg) {
      reportCode = generateReportSchemaCode(config.reportExport, entityMsg.fields, config.entityMsg);
      writeFileSync(join(REPORTS_OUT_DIR, `${config.file}.report.ts`), reportCode);
      reportExports.push({ file: config.file, name: config.reportExport });
      console.log(`  Report: ${config.reportExport}`);
    }
  }

  // Step 3: Generate barrel exports
  // Form schemas index
  const formIndexLines = [];
  const seen = new Set();
  for (const { file, name } of formExports) {
    const key = `${file}:${name}`;
    if (seen.has(key)) continue;
    seen.add(key);
    // Group by file
    if (!formIndexLines.find(l => l.startsWith(`export {`) && l.includes(`'./${file}.schema'`))) {
      const names = formExports.filter(e => e.file === file).map(e => e.name);
      formIndexLines.push(`export { ${[...new Set(names)].join(', ')} } from './${file}.schema';`);
    }
  }
  writeFileSync(join(SCHEMAS_OUT_DIR, 'index.ts'), `/**\n * @generated — DO NOT EDIT\n */\n${[...new Set(formIndexLines)].join('\n')}\n`);

  // Report schemas index
  const reportIndexLines = reportExports.map(({ file, name }) =>
    `export { ${name} } from './${file}.report';`
  );
  writeFileSync(join(REPORTS_OUT_DIR, 'index.ts'), `/**\n * @generated — DO NOT EDIT\n */\n${reportIndexLines.join('\n')}\n`);

  console.log('\n' + '─'.repeat(50));
  console.log(`Generated ${formExports.length} form schemas`);
  console.log(`Generated ${reportExports.length} report schemas`);
  console.log('Done!');
}

main();
