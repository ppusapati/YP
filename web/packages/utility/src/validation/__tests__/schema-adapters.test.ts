import { describe, it, expect } from 'vitest';
import {
  validateWithYup,
  getFieldErrors,
  hasFieldError,
  getFirstFieldError,
  mapToFormErrors,
  type SchemaValidationResult,
} from '../schema-adapters';

// These adapters turn a schema library's failure into the shape a form
// renders. Nothing here had a test, and the collection step — walking
// `yupError.inner` into a per-field bucket — is the part that is easy to get
// subtly wrong: a field with two problems should keep both, and two fields
// should not share a bucket.

/** A stand-in for a Yup schema, so the tests do not need Yup installed. */
function schemaThatFailsWith(inner: Array<{ path: string; errors: string[] }>) {
  return {
    validateSync() {
      throw {
        errors: inner.flatMap((i) => i.errors),
        inner: inner.map((i) => ({ path: i.path, message: i.errors[0]!, errors: i.errors })),
      };
    },
  } as never;
}

function schemaThatPasses<T>(value: T) {
  return { validateSync: () => value } as never;
}

describe('validateWithYup', () => {
  it('returns the parsed data when the schema passes', () => {
    const result = validateWithYup(schemaThatPasses({ name: 'Alice' }), {});

    expect(result.isValid).toBe(true);
    expect(result.data).toEqual({ name: 'Alice' });
    expect(result.fieldErrors).toEqual({});
  });

  it('groups every error under the field it belongs to', () => {
    const result = validateWithYup(
      schemaThatFailsWith([
        { path: 'email', errors: ['must be an email'] },
        { path: 'age', errors: ['must be a number'] },
      ]),
      {}
    );

    expect(result.isValid).toBe(false);
    expect(result.fieldErrors).toEqual({
      email: ['must be an email'],
      age: ['must be a number'],
    });
  });

  it('keeps every problem on a field that has more than one', () => {
    // The bucket is created once and appended to. Replacing it on the second
    // entry would silently drop the first message, and a form that shows one of
    // two problems sends the user round twice.
    const result = validateWithYup(
      schemaThatFailsWith([
        { path: 'password', errors: ['too short'] },
        { path: 'password', errors: ['needs a digit'] },
      ]),
      {}
    );

    expect(result.fieldErrors.password).toEqual(['too short', 'needs a digit']);
  });

  it('ignores entries with no path rather than bucketing them under ""', () => {
    const result = validateWithYup(
      schemaThatFailsWith([
        { path: '', errors: ['something is wrong'] },
        { path: 'name', errors: ['required'] },
      ]),
      {}
    );

    expect(Object.keys(result.fieldErrors)).toEqual(['name']);
    // Still reported at the form level, so it is not lost entirely.
    expect(result.errors).toContain('something is wrong');
  });
});

describe('field error helpers', () => {
  const result: SchemaValidationResult = {
    isValid: false,
    errors: ['too short', 'needs a digit'],
    fieldErrors: { password: ['too short', 'needs a digit'], email: [] },
  };

  it('returns an empty list for a field with no errors', () => {
    expect(getFieldErrors(result, 'name')).toEqual([]);
    expect(getFieldErrors(result, 'password')).toEqual(['too short', 'needs a digit']);
  });

  it('does not report a field as having an error when its list is empty', () => {
    // `email: []` is present but empty. Treating a present key as an error
    // would mark a valid field red.
    expect(hasFieldError(result, 'email')).toBe(false);
    expect(hasFieldError(result, 'password')).toBe(true);
    expect(hasFieldError(result, 'missing')).toBe(false);
  });

  it('returns the first error, or undefined', () => {
    expect(getFirstFieldError(result, 'password')).toBe('too short');
    expect(getFirstFieldError(result, 'email')).toBeUndefined();
    expect(getFirstFieldError(result, 'missing')).toBeUndefined();
  });
});

describe('mapToFormErrors', () => {
  it('takes one message per field', () => {
    expect(
      mapToFormErrors({
        isValid: false,
        errors: [],
        fieldErrors: { password: ['too short', 'needs a digit'], name: ['required'] },
      })
    ).toEqual({ password: 'too short', name: 'required' });
  });

  it('omits fields whose error list is empty', () => {
    // Not `{ email: undefined }`: a key present with no message renders as an
    // error with blank text under the field.
    const mapped = mapToFormErrors({
      isValid: false,
      errors: [],
      fieldErrors: { email: [], name: ['required'] },
    });

    expect(mapped).toEqual({ name: 'required' });
    expect('email' in mapped).toBe(false);
  });
});
