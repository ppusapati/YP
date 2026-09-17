/**
 * Conversions between what a form holds and what a protobuf message holds.
 *
 * These exist because the two representations disagree in three ways, and each
 * disagreement fails silently rather than loudly:
 *
 *  * **Field names.** The form schemas use the proto's snake_case names
 *    (`total_area_hectares`); protobuf-es generates camelCase
 *    (`totalAreaHectares`). Spreading form values into a request hands
 *    protobuf-es keys it does not recognise, and it drops them — the request
 *    succeeds and nothing changes. Several edit pages did exactly that behind
 *    an `as any`, which is what kept the typechecker quiet about it.
 *
 *  * **Enums.** A select's option value is the proto's JSON name
 *    (`'FARM_TYPE_CROP'`); the message carries a number. Assigning the string
 *    is a type error at best and a zero value at worst.
 *
 *  * **Timestamps.** A date input holds `yyyy-mm-dd`; the message holds a
 *    `Timestamp`.
 *
 * Converting through the generated descriptors rather than hand-written tables
 * means a value added to a proto cannot fall out of step with the page that
 * renders it.
 */
import { enumFromJson, enumToJson, type DescEnum } from '@bufbuild/protobuf';
import { timestampDate, timestampFromDate, type Timestamp } from '@bufbuild/protobuf/wkt';

// The enum descriptors the conversions above are used with, re-exported here
// so a page needs one import rather than three, and so the apps that do not
// depend on @samavāya/proto or @bufbuild/protobuf directly can still convert.
export {
  FarmTypeSchema,
  FarmSoilTypeSchema,
  ClimateZoneSchema,
  FarmStatusSchema,
  FieldTypeSchema,
  FieldSoilTypeSchema,
  IrrigationTypeSchema,
  AspectDirectionSchema,
  FieldStatusSchema,
  CropCategorySchema,
  SensorStatusSchema,
  SensorProtocolSchema,
  ScheduleTypeSchema,
  FrequencySchema,
  IrrigationStatusSchema,
} from '@samavāya/proto';

/**
 * A numeric proto enum as the option value a form select uses.
 *
 * Returns '' for an unset or unrecognised value, which reads as "nothing
 * selected" — the honest rendering of a value this build of the client does
 * not know about.
 */
export function enumOption(schema: DescEnum, value: number | undefined): string {
  if (value === undefined) return '';
  try {
    const name = enumToJson(schema, value);
    return typeof name === 'string' ? name : '';
  } catch {
    return '';
  }
}

/**
 * A form select's option value back to its numeric proto enum.
 *
 * Returns undefined rather than a guess when the option is not one the proto
 * declares, so the field is left unset and the service keeps what it holds. A
 * fallback to the zero value would quietly rewrite the record to
 * `*_UNSPECIFIED`.
 */
export function enumValue(schema: DescEnum, value: unknown): number | undefined {
  if (typeof value !== 'string' || value === '') return undefined;
  try {
    return enumFromJson(schema, value);
  } catch {
    return undefined;
  }
}

/** A protobuf Timestamp as the `yyyy-mm-dd` a date input expects. */
export function toDateInput(value: Timestamp | undefined): string {
  if (!value) return '';
  try {
    return timestampDate(value).toISOString().slice(0, 10);
  } catch {
    // A malformed timestamp blanks one field rather than failing the page: the
    // rest of the record is still worth showing and still worth editing.
    return '';
  }
}

/**
 * A protobuf Timestamp as the `yyyy-mm-ddThh:mm` a datetime-local input wants.
 *
 * Local time, not UTC: a datetime-local input has no timezone and the browser
 * reads whatever it is given as local, so handing it a UTC string shifts every
 * displayed time by the offset. An irrigation schedule showing 09:30 when it
 * runs at 04:00 is worse than showing nothing.
 */
export function toDateTimeInput(value: Timestamp | undefined): string {
  if (!value) return '';
  try {
    const date = timestampDate(value);
    const pad = (n: number) => String(n).padStart(2, '0');
    return (
      `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}` +
      `T${pad(date.getHours())}:${pad(date.getMinutes())}`
    );
  } catch {
    return '';
  }
}

/** A `yyyy-mm-dd` string as a protobuf Timestamp, or undefined when blank. */
export function toTimestamp(value: unknown): Timestamp | undefined {
  if (typeof value !== 'string' || value.trim() === '') return undefined;
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return undefined;
  return timestampFromDate(date);
}

/**
 * A form value as a number, or undefined when it is blank or unparseable.
 *
 * Distinct from `Number(value) || 0`: that turns an empty input into a real
 * zero, which on an update request overwrites a stored figure with 0 rather
 * than leaving it alone.
 */
export function numberValue(value: unknown): number | undefined {
  if (value === '' || value === null || value === undefined) return undefined;
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : undefined;
}

/** A form value as a string, treating null and undefined as empty. */
export function stringValue(value: unknown): string {
  return value === null || value === undefined ? '' : String(value);
}
