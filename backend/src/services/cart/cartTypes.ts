/**
 * @summary
 * Cart service type definitions.
 *
 * @module services/cart/cartTypes
 */

export interface CartAddParams {
  idAccount: number;
  idUser: number;
  idProduct: number;
  idFlavor: number;
  idSize: number;
  quantity: number;
  notes?: string;
}

export interface CartAddResponse {
  idCart: number;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
}
