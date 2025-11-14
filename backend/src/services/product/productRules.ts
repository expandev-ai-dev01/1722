/**
 * @summary
 * Product business rules and database operations.
 * Handles product listing, details, and related products.
 *
 * @module services/product/productRules
 */

import { dbRequest, ExpectedReturn, IRecordSet } from '@/utils/database';
import {
  ProductListParams,
  ProductListResponse,
  ProductDetailsResponse,
  ProductRelatedResponse,
} from './productTypes';

/**
 * @summary
 * Lists products with filtering, sorting, and pagination.
 *
 * @function productList
 * @param {ProductListParams} params - List parameters
 * @returns {Promise<ProductListResponse>} Product list with pagination
 */
export async function productList(params: ProductListParams): Promise<ProductListResponse> {
  const result = (await dbRequest(
    '[functional].[spProductList]',
    {
      idAccount: params.idAccount,
      page: params.page || 1,
      pageSize: params.pageSize || 12,
      sortBy: params.sortBy || 'relevancia',
      categoryIds: params.categoryIds?.join(',') || null,
      flavorIds: params.flavorIds?.join(',') || null,
      sizeIds: params.sizeIds?.join(',') || null,
      minPrice: params.minPrice || null,
      maxPrice: params.maxPrice || null,
      confectionerIds: params.confectionerIds?.join(',') || null,
      searchTerm: params.searchTerm || null,
      availableOnly: params.availableOnly !== undefined ? (params.availableOnly ? 1 : 0) : 1,
    },
    ExpectedReturn.Multi,
    undefined,
    ['products', 'pagination']
  )) as { products: IRecordSet; pagination: IRecordSet };

  return {
    products: result.products.recordset,
    totalCount: result.pagination.recordset[0].totalCount,
    totalPages: result.pagination.recordset[0].totalPages,
    currentPage: params.page || 1,
    pageSize: params.pageSize || 12,
  };
}

/**
 * @summary
 * Retrieves detailed product information.
 *
 * @function productGet
 * @param {number} idAccount - Account identifier
 * @param {number} idProduct - Product identifier
 * @returns {Promise<ProductDetailsResponse>} Product details
 */
export async function productGet(
  idAccount: number,
  idProduct: number
): Promise<ProductDetailsResponse> {
  const result = (await dbRequest(
    '[functional].[spProductGet]',
    { idAccount, idProduct },
    ExpectedReturn.Multi,
    undefined,
    ['product', 'flavors', 'sizes', 'reviews']
  )) as {
    product: IRecordSet;
    flavors: IRecordSet;
    sizes: IRecordSet;
    reviews: IRecordSet;
  };

  const product = result.product.recordset[0];

  return {
    ...product,
    ingredients: JSON.parse(product.ingredients),
    nutritionalInfo: product.nutritionalInfo ? JSON.parse(product.nutritionalInfo) : null,
    imageGallery: product.imageGallery ? JSON.parse(product.imageGallery) : [],
    flavors: result.flavors.recordset,
    sizes: result.sizes.recordset,
    reviews: result.reviews.recordset,
  };
}

/**
 * @summary
 * Retrieves related products.
 *
 * @function productRelated
 * @param {number} idAccount - Account identifier
 * @param {number} idProduct - Reference product identifier
 * @param {number} limit - Number of related products
 * @returns {Promise<ProductRelatedResponse[]>} Related products
 */
export async function productRelated(
  idAccount: number,
  idProduct: number,
  limit: number = 4
): Promise<ProductRelatedResponse[]> {
  const result = (await dbRequest(
    '[functional].[spProductRelated]',
    { idAccount, idProduct, limit },
    ExpectedReturn.Multi
  )) as IRecordSet<any>[];

  return result[0].recordset;
}
