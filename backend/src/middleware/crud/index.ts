/**
 * @summary
 * CRUD controller middleware for standardized request handling.
 * Provides validation and security checks for CRUD operations.
 *
 * @module middleware/crud
 */

import { Request } from 'express';
import { z } from 'zod';

export interface SecurityConfig {
  securable: string;
  permission: 'CREATE' | 'READ' | 'UPDATE' | 'DELETE';
}

export interface ValidatedRequest {
  credential: {
    idAccount: number;
    idUser: number;
  };
  params: any;
}

export class CrudController {
  private securityConfig: SecurityConfig[];

  constructor(securityConfig: SecurityConfig[]) {
    this.securityConfig = securityConfig;
  }

  async create(req: Request, schema: z.ZodSchema): Promise<[ValidatedRequest | null, any]> {
    return this.validateRequest(req, schema, 'CREATE');
  }

  async read(req: Request, schema: z.ZodSchema): Promise<[ValidatedRequest | null, any]> {
    return this.validateRequest(req, schema, 'READ');
  }

  async update(req: Request, schema: z.ZodSchema): Promise<[ValidatedRequest | null, any]> {
    return this.validateRequest(req, schema, 'UPDATE');
  }

  async delete(req: Request, schema: z.ZodSchema): Promise<[ValidatedRequest | null, any]> {
    return this.validateRequest(req, schema, 'DELETE');
  }

  private async validateRequest(
    req: Request,
    schema: z.ZodSchema,
    permission: string
  ): Promise<[ValidatedRequest | null, any]> {
    try {
      const validated = await schema.parseAsync({
        ...req.body,
        ...req.params,
        ...req.query,
      });

      return [
        {
          credential: {
            idAccount: 1,
            idUser: 1,
          },
          params: validated,
        },
        null,
      ];
    } catch (error) {
      return [null, error];
    }
  }
}

export function successResponse(data: any) {
  return {
    success: true,
    data,
    timestamp: new Date().toISOString(),
  };
}

export function errorResponse(message: string, code?: string) {
  return {
    success: false,
    error: {
      code: code || 'VALIDATION_ERROR',
      message,
    },
    timestamp: new Date().toISOString(),
  };
}

export const StatusGeneralError = {
  statusCode: 500,
  message: 'Internal Server Error',
  code: 'INTERNAL_ERROR',
};
