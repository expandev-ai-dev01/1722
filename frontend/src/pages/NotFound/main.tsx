import { useNavigate } from 'react-router-dom';

/**
 * @page NotFoundPage
 * @summary 404 error page displayed when route is not found.
 * @domain core
 * @type error-page
 * @category public
 */
export const NotFoundPage = () => {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-6xl font-bold text-gray-900 mb-4">404</h1>
        <p className="text-xl text-gray-600 mb-8">Página não encontrada</p>
        <button
          onClick={() => navigate('/')}
          className="px-6 py-3 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
        >
          Voltar para Home
        </button>
      </div>
    </div>
  );
};

export default NotFoundPage;
