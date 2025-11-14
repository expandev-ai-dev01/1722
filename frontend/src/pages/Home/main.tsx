/**
 * @page HomePage
 * @summary Home page displaying welcome message and product catalog preview.
 * @domain core
 * @type landing-page
 * @category public
 */
export const HomePage = () => {
  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">Bem-vindo ao LoveCakes</h1>
        <p className="text-lg text-gray-600">Bolos artesanais feitos com amor</p>
      </div>
    </div>
  );
};

export default HomePage;
