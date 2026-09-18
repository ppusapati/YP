/**
 * ConnectRPC Transport Configuration for Agriculture Services
 *
 * Sets up the transport layer for communicating with the Go backend
 * microservices via ConnectRPC protocol.
 */
import { createConnectTransport } from '@connectrpc/connect-web';

/** Base URL for agriculture microservices gateway */
const AG_API_BASE_URL = '/api/agriculture';

/**
 * ConnectRPC transport for agriculture services.
 * Uses connect protocol over HTTP/1.1 (browser-compatible).
 */
export const agTransport = createConnectTransport({
  baseUrl: AG_API_BASE_URL,
});

/** Per-service base URLs (when services are not behind a single gateway) */
export const SERVICE_URLS = {
  farm: '/api/farm',
  crop: '/api/crop',
  field: '/api/field',
  soil: '/api/soil',
  irrigation: '/api/irrigation',
  sensor: '/api/sensor',
  satellite: '/api/satellite',
  'satellite-ingestion': '/api/satellite-ingestion',
  'satellite-processing': '/api/satellite-processing',
  'satellite-analytics': '/api/satellite-analytics',
  'satellite-tile': '/api/satellite-tile',
  'vegetation-index': '/api/vegetation-index',
  pest: '/api/pest',
  diagnosis: '/api/diagnosis',
  yield: '/api/yield',
  traceability: '/api/traceability',
  alert: '/api/alert',
  'field-analytics': '/api/field-analytics',
  prescription: '/api/prescription',
  advisory: '/api/advisory',
  // The services that had no client at all. Each has a running backend, a
  // gateway route and a generated descriptor; what was missing was these four
  // lines and the ones in ../services/index.ts.
  weather: '/api/weather',
  commerce: '/api/commerce',
  task: '/api/task',
  market: '/api/market',
  device: '/api/device',
  finance: '/api/finance',
  planning: '/api/planning',
  'soil-lab': '/api/soil-lab',
  sustainability: '/api/sustainability',
  agronomy: '/api/agronomy',
} as const;

/** Create a transport for a specific service */
export function createServiceTransport(service: keyof typeof SERVICE_URLS) {
  return createConnectTransport({
    baseUrl: SERVICE_URLS[service],
  });
}
