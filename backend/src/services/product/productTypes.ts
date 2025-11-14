/**
 * @summary
 * Product service type definitions.
 *
 * @module services/product/productTypes
 */

export interface ProductListParams {
  idAccount: number;
  page?: number;
  pageSize?: number;
  sortBy?: string;
  categoryIds?: number[];
  flavorIds?: number[];
  sizeIds?: number[];
  minPrice?: number;
  maxPrice?: number;
  confectionerIds?: number[];
  searchTerm?: string;
  availableOnly?: boolean;
}

export interface ProductListItem {
  idProduct: number;
  name: string;
  description: string;
  basePrice: number;
  promotionalPrice: number | null;
  mainImage: string;
  averageRating: number;
  totalReviews: number;
  preparationTime: string;
  available: boolean;
  confectionerName: string;
  categoryName: string;
}

export interface ProductListResponse {
  products: ProductListItem[];
  totalCount: number;
  totalPages: number;
  currentPage: number;
  pageSize: number;
}

export interface ProductFlavor {
  idFlavor: number;
  name: string;
  available: boolean;
}

export interface ProductSize {
  idSize: number;
  name: string;
  description: string;
  priceModifier: number;
  available: boolean;
}

export interface ProductReview {
  idReview: number;
  customerName: string;
  rating: number;
  comment: string | null;
  dateCreated: Date;
}

export interface ProductDetailsResponse {
  idProduct: number;
  name: string;
  description: string;
  ingredients: string[];
  nutritionalInfo: any | null;
  basePrice: number;
  promotionalPrice: number | null;
  mainImage: string;
  imageGallery: string[];
  averageRating: number;
  totalReviews: number;
  preparationTime: string;
  available: boolean;
  idConfectioner: number;
  confectionerName: string;
  confectionerPhoto: string | null;
  confectionerRating: number;
  confectionerProductsSold: number;
  flavors: ProductFlavor[];
  sizes: ProductSize[];
  reviews: ProductReview[];
}

export interface ProductRelatedResponse {
  idProduct: number;
  name: string;
  basePrice: number;
  promotionalPrice: number | null;
  mainImage: string;
  averageRating: number;
  totalReviews: number;
  confectionerName: string;
}
