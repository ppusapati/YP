/**
 * Agriculture Service Layer
 *
 * Typed service interfaces for communicating with the Go backend
 * microservices via ConnectRPC. Each service wraps the ConnectRPC
 * client with typed methods matching the proto definitions.
 */
import { createServiceTransport } from '../api/transport';
import type {
  Farm, Crop, CropVariety, Field, SoilSample,
  IrrigationSchedule, IrrigationZone, Sensor, SensorReading, SensorAlert,
  SatelliteImage, VegetationIndex,
  PestPrediction, PestObservation,
  DiagnosisRequest, DiagnosisResult,
  YieldPrediction, YieldRecord, HarvestPlan,
  TraceabilityRecord, Certification, BatchRecord,
  PaginatedResponse, ListParams,
} from '../types/index';

// ─── Generic CRUD helper ─────────────────────────────────────────────────────

async function fetchApi<T>(
  baseUrl: string,
  path: string,
  options?: RequestInit,
): Promise<T> {
  const res = await fetch(`${baseUrl}${path}`, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  });
  if (!res.ok) {
    const body = await res.text().catch(() => '');
    throw new Error(`API error ${res.status}: ${body}`);
  }
  return res.json();
}

function createCrudService<T extends { id: string }>(baseUrl: string, resource: string) {
  const base = `${baseUrl}/${resource}`;

  return {
    list(params?: ListParams): Promise<PaginatedResponse<T>> {
      const qs = new URLSearchParams();
      if (params?.page) qs.set('page', String(params.page));
      if (params?.page_size) qs.set('page_size', String(params.page_size));
      if (params?.sort_by) qs.set('sort_by', params.sort_by);
      if (params?.sort_order) qs.set('sort_order', params.sort_order);
      if (params?.search) qs.set('search', params.search);
      const query = qs.toString();
      return fetchApi<PaginatedResponse<T>>(base, query ? `?${query}` : '');
    },

    get(id: string): Promise<T> {
      return fetchApi<T>(base, `/${id}`);
    },

    create(data: Partial<T>): Promise<T> {
      return fetchApi<T>(base, '', {
        method: 'POST',
        body: JSON.stringify(data),
      });
    },

    update(id: string, data: Partial<T>): Promise<T> {
      return fetchApi<T>(base, `/${id}`, {
        method: 'PUT',
        body: JSON.stringify(data),
      });
    },

    remove(id: string): Promise<void> {
      return fetchApi<void>(base, `/${id}`, { method: 'DELETE' });
    },
  };
}

// ─── Service Instances ───────────────────────────────────────────────────────

export const farmService = createCrudService<Farm>('/api/farm', 'farms');
export const cropService = createCrudService<Crop>('/api/crop', 'crops');
export const cropVarietyService = createCrudService<CropVariety>('/api/crop', 'varieties');
export const fieldService = createCrudService<Field>('/api/field', 'fields');
export const soilService = createCrudService<SoilSample>('/api/soil', 'samples');
export const irrigationScheduleService = createCrudService<IrrigationSchedule>('/api/irrigation', 'schedules');
export const irrigationZoneService = createCrudService<IrrigationZone>('/api/irrigation', 'zones');
export const sensorService = createCrudService<Sensor>('/api/sensor', 'sensors');
export const satelliteService = createCrudService<SatelliteImage>('/api/satellite', 'images');
export const pestPredictionService = createCrudService<PestPrediction>('/api/pest', 'predictions');
export const pestObservationService = createCrudService<PestObservation>('/api/pest', 'observations');
export const diagnosisService = createCrudService<DiagnosisRequest>('/api/diagnosis', 'requests');
export const yieldPredictionService = createCrudService<YieldPrediction>('/api/yield', 'predictions');
export const yieldRecordService = createCrudService<YieldRecord>('/api/yield', 'records');
export const harvestPlanService = createCrudService<HarvestPlan>('/api/yield', 'harvest-plans');
export const traceabilityService = createCrudService<TraceabilityRecord>('/api/traceability', 'records');
export const certificationService = createCrudService<Certification>('/api/traceability', 'certifications');
export const batchRecordService = createCrudService<BatchRecord>('/api/traceability', 'batches');
