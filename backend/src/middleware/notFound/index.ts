/**
 * @summary
 * 404 Not Found middleware.
 * Handles requests to non-existent routes.
 *
 * @module middleware/notFound
 */

import { Request, Response } from 'express';

export async function notFoundMiddleware(req: Request, res: Response): Promise<void> {
  res.status(404).json({
    success: false,
    error: {
      code: 'NOT_FOUND',
      message: `Route ${req.method} ${req.path} not found`,
    },
    timestamp: new Date().toISOString(),
  });
}
