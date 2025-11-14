import { Outlet } from 'react-router-dom';
import { ErrorBoundary } from '@/core/components/ErrorBoundary';

/**
 * @component RootLayout
 * @summary Root layout component that wraps all pages with common structure.
 * @domain core
 * @type layout-component
 * @category layout
 */
export const RootLayout = () => {
  return (
    <ErrorBoundary>
      <div className="min-h-screen bg-gray-50">
        <Outlet />
      </div>
    </ErrorBoundary>
  );
};
