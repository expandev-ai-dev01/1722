/**
 * @summary
 * Cart API controller.
 * Handles cart item management endpoints.
 *
 * @module api/v1/internal/cart/controller
 */

import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import {
  CrudController,
  errorResponse,
  StatusGeneralError,
  successResponse,
} from '@/middleware/crud';
import { cartAdd } from '@/services/cart';

const securable = 'CART';

/**
 * @api {post} /api/v1/internal/cart Add to Cart
 * @apiName AddToCart
 * @apiGroup Cart
 * @apiVersion 1.0.0
 *
 * @apiDescription Adds product to cart or updates quantity
 *
 * @apiParam {Number} idProduct Product identifier
 * @apiParam {Number} idFlavor Selected flavor identifier
 * @apiParam {Number} idSize Selected size identifier
 * @apiParam {Number} quantity Product quantity (1-10)
 * @apiParam {String} [notes] Additional notes (max 200 characters)
 *
 * @apiSuccess {Number} idCart Cart item identifier
 * @apiSuccess {Number} quantity Item quantity
 * @apiSuccess {Number} unitPrice Unit price
 * @apiSuccess {Number} totalPrice Total price
 */
export async function addHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  const operation = new CrudController([{ securable, permission: 'CREATE' }]);

  const bodySchema = z.object({
    idProduct: z.number().int().positive(),
    idFlavor: z.number().int().positive(),
    idSize: z.number().int().positive(),
    quantity: z.number().int().min(1).max(10),
    notes: z.string().max(200).optional(),
  });

  const [validated, error] = await operation.create(req, bodySchema);

  if (!validated) {
    return next(error);
  }

  try {
    const params = validated.params as z.infer<typeof bodySchema>;

    const data = await cartAdd({
      idAccount: validated.credential.idAccount,
      idUser: validated.credential.idUser,
      idProduct: params.idProduct,
      idFlavor: params.idFlavor,
      idSize: params.idSize,
      quantity: params.quantity,
      notes: params.notes,
    });

    res.json(successResponse(data));
  } catch (error: any) {
    if (error.number === 51000) {
      res.status(400).json(errorResponse(error.message));
    } else {
      next(StatusGeneralError);
    }
  }
}
