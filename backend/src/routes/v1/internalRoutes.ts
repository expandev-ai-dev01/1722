/**
 * @summary
 * Internal (authenticated) API routes configuration.
 * Handles protected endpoints that require authentication.
 *
 * @module routes/v1/internalRoutes
 */

import { Router } from 'express';
import * as productController from '@/api/v1/internal/product/controller';
import * as cartController from '@/api/v1/internal/cart/controller';

const router = Router();

// Product routes
router.get('/product', productController.listHandler);
router.get('/product/:id', productController.getHandler);
router.get('/product/:id/related', productController.relatedHandler);

// Cart routes
router.post('/cart', cartController.addHandler);

export default router;
