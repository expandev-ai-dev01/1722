/**
 * @summary
 * Product API controller.
 * Handles product listing, details, and related products endpoints.
 *
 * @module api/v1/internal/product/controller
 */

import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import {
  CrudController,
  errorResponse,
  StatusGeneralError,
  successResponse,
} from '@/middleware/crud';
import { productList, productGet, productRelated } from '@/services/product';

const securable = 'PRODUCT';

/**
 * @api {get} /api/v1/internal/product List Products
 * @apiName ListProducts
 * @apiGroup Product
 * @apiVersion 1.0.0
 *
 * @apiDescription Lists products with filtering, sorting, and pagination
 *
 * @apiParam {Number} [page=1] Page number
 * @apiParam {Number} [pageSize=12] Items per page (12, 24, or 36)
 * @apiParam {String} [sortBy=relevancia] Sort criteria
 * @apiParam {String} [categoryIds] Comma-separated category IDs
 * @apiParam {String} [flavorIds] Comma-separated flavor IDs
 * @apiParam {String} [sizeIds] Comma-separated size IDs
 * @apiParam {Number} [minPrice] Minimum price
 * @apiParam {Number} [maxPrice] Maximum price
 * @apiParam {String} [confectionerIds] Comma-separated confectioner IDs
 * @apiParam {String} [searchTerm] Search term
 * @apiParam {Boolean} [availableOnly=true] Filter only available products
 *
 * @apiSuccess {Object[]} products Product list
 * @apiSuccess {Number} totalCount Total products count
 * @apiSuccess {Number} totalPages Total pages
 * @apiSuccess {Number} currentPage Current page
 * @apiSuccess {Number} pageSize Page size
 */
export async function listHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  const operation = new CrudController([{ securable, permission: 'READ' }]);

  const querySchema = z.object({
    page: z.coerce.number().int().min(1).optional(),
    pageSize: z.coerce
      .number()
      .int()
      .refine((val) => [12, 24, 36].includes(val))
      .optional(),
    sortBy: z
      .enum([
        'relevancia',
        'preco_menor',
        'preco_maior',
        'mais_vendidos',
        'melhor_avaliados',
        'mais_recentes',
      ])
      .optional(),
    categoryIds: z.string().optional(),
    flavorIds: z.string().optional(),
    sizeIds: z.string().optional(),
    minPrice: z.coerce.number().min(0).optional(),
    maxPrice: z.coerce.number().min(0).optional(),
    confectionerIds: z.string().optional(),
    searchTerm: z.string().max(100).optional(),
    availableOnly: z.coerce.number().int().min(0).max(1).optional(),
  });

  const [validated, error] = await operation.read(req, querySchema);

  if (!validated) {
    return next(error);
  }

  try {
    const params = validated.params as z.infer<typeof querySchema>;

    const data = await productList({
      idAccount: validated.credential.idAccount,
      page: params.page,
      pageSize: params.pageSize,
      sortBy: params.sortBy,
      categoryIds: params.categoryIds?.split(',').map(Number),
      flavorIds: params.flavorIds?.split(',').map(Number),
      sizeIds: params.sizeIds?.split(',').map(Number),
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      confectionerIds: params.confectionerIds?.split(',').map(Number),
      searchTerm: params.searchTerm,
      availableOnly: params.availableOnly === 1,
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

/**
 * @api {get} /api/v1/internal/product/:id Get Product Details
 * @apiName GetProduct
 * @apiGroup Product
 * @apiVersion 1.0.0
 *
 * @apiDescription Retrieves detailed product information
 *
 * @apiParam {Number} id Product identifier
 *
 * @apiSuccess {Object} product Product details with flavors, sizes, and reviews
 */
export async function getHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  const operation = new CrudController([{ securable, permission: 'READ' }]);

  const paramsSchema = z.object({
    id: z.coerce.number().int().positive(),
  });

  const [validated, error] = await operation.read(req, paramsSchema);

  if (!validated) {
    return next(error);
  }

  try {
    const params = validated.params as z.infer<typeof paramsSchema>;

    const data = await productGet(validated.credential.idAccount, params.id);

    res.json(successResponse(data));
  } catch (error: any) {
    if (error.number === 51000) {
      res.status(400).json(errorResponse(error.message));
    } else {
      next(StatusGeneralError);
    }
  }
}

/**
 * @api {get} /api/v1/internal/product/:id/related Get Related Products
 * @apiName GetRelatedProducts
 * @apiGroup Product
 * @apiVersion 1.0.0
 *
 * @apiDescription Retrieves related products
 *
 * @apiParam {Number} id Product identifier
 * @apiParam {Number} [limit=4] Number of related products
 *
 * @apiSuccess {Object[]} products Related products list
 */
export async function relatedHandler(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  const operation = new CrudController([{ securable, permission: 'READ' }]);

  const paramsSchema = z.object({
    id: z.coerce.number().int().positive(),
    limit: z.coerce.number().int().min(1).max(10).optional(),
  });

  const [validated, error] = await operation.read(req, paramsSchema);

  if (!validated) {
    return next(error);
  }

  try {
    const params = validated.params as z.infer<typeof paramsSchema>;

    const data = await productRelated(validated.credential.idAccount, params.id, params.limit || 4);

    res.json(successResponse(data));
  } catch (error: any) {
    if (error.number === 51000) {
      res.status(400).json(errorResponse(error.message));
    } else {
      next(StatusGeneralError);
    }
  }
}
