/**
 * @summary
 * Cart business rules and database operations.
 * Handles cart item management.
 *
 * @module services/cart/cartRules
 */

import { dbRequest, ExpectedReturn } from '@/utils/database';
import { CartAddParams, CartAddResponse } from './cartTypes';

/**
 * @summary
 * Adds product to cart or updates quantity.
 *
 * @function cartAdd
 * @param {CartAddParams} params - Cart add parameters
 * @returns {Promise<CartAddResponse>} Cart item details
 */
export async function cartAdd(params: CartAddParams): Promise<CartAddResponse> {
  const result = await dbRequest(
    '[functional].[spCartAdd]',
    {
      idAccount: params.idAccount,
      idUser: params.idUser,
      idProduct: params.idProduct,
      idFlavor: params.idFlavor,
      idSize: params.idSize,
      quantity: params.quantity,
      notes: params.notes || null,
    },
    ExpectedReturn.Single
  );

  return result;
}
