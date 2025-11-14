/**
 * @module core/types
 * @summary Global application types and interfaces.
 */

export interface ApiResponse<T> {
  data: T;
  message?: string;
  success: boolean;
}

export interface PaginatedResponse<T> {
  data: T[];
  totalCount: number;
  totalPages: number;
  currentPage: number;
  pageSize: number;
}

export interface ApiError {
  message: string;
  status?: number;
  code?: string;
}
