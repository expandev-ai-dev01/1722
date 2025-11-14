/**
 * @summary
 * Zod validation utilities.
 * Provides reusable validation schemas and helpers.
 *
 * @module utils/zodValidation
 */

import { z } from 'zod';

// String validations
export const zString = z.string().min(1);
export const zNullableString = (maxLength?: number) => {
  let schema = z.string();
  if (maxLength) {
    schema = schema.max(maxLength);
  }
  return schema.nullable();
};

// Name and description
export const zName = z.string().min(1).max(200);
export const zNullableDescription = z.string().max(500).nullable();

// Numeric validations
export const zFK = z.number().int().positive();
export const zNullableFK = z.number().int().positive().nullable();
export const zBit = z.number().int().min(0).max(1);

// Date validations
export const zDateString = z.string().datetime();
export const zNullableDateString = z.string().datetime().nullable();
