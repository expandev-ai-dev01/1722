/**
 * @summary
 * Lists products with filtering, sorting, and pagination.
 * Supports multiple filter criteria and ordering options.
 *
 * @procedure spProductList
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/product
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {INT} page
 *   - Required: No
 *   - Description: Page number (default: 1)
 *
 * @param {INT} pageSize
 *   - Required: No
 *   - Description: Items per page (default: 12)
 *
 * @param {NVARCHAR} sortBy
 *   - Required: No
 *   - Description: Sort criteria (default: 'relevancia')
 *
 * @param {NVARCHAR} categoryIds
 *   - Required: No
 *   - Description: Comma-separated category IDs
 *
 * @param {NVARCHAR} flavorIds
 *   - Required: No
 *   - Description: Comma-separated flavor IDs
 *
 * @param {NVARCHAR} sizeIds
 *   - Required: No
 *   - Description: Comma-separated size IDs
 *
 * @param {NUMERIC} minPrice
 *   - Required: No
 *   - Description: Minimum price filter
 *
 * @param {NUMERIC} maxPrice
 *   - Required: No
 *   - Description: Maximum price filter
 *
 * @param {NVARCHAR} confectionerIds
 *   - Required: No
 *   - Description: Comma-separated confectioner IDs
 *
 * @param {NVARCHAR} searchTerm
 *   - Required: No
 *   - Description: Search term for name/description/ingredients
 *
 * @param {BIT} availableOnly
 *   - Required: No
 *   - Description: Filter only available products (default: 1)
 *
 * @testScenarios
 * - Valid listing with default parameters
 * - Filtering by multiple criteria
 * - Sorting by different options
 * - Pagination with various page sizes
 * - Search term filtering
 * - Price range filtering
 */
CREATE OR ALTER PROCEDURE [functional].[spProductList]
  @idAccount INT,
  @page INT = 1,
  @pageSize INT = 12,
  @sortBy NVARCHAR(50) = 'relevancia',
  @categoryIds NVARCHAR(MAX) = NULL,
  @flavorIds NVARCHAR(MAX) = NULL,
  @sizeIds NVARCHAR(MAX) = NULL,
  @minPrice NUMERIC(18, 6) = NULL,
  @maxPrice NUMERIC(18, 6) = NULL,
  @confectionerIds NVARCHAR(MAX) = NULL,
  @searchTerm NVARCHAR(100) = NULL,
  @availableOnly BIT = 1
AS
BEGIN
  SET NOCOUNT ON;

  /**
   * @validation Validate required parameters
   * @throw {idAccountRequired}
   */
  IF (@idAccount IS NULL)
  BEGIN
    ;THROW 51000, 'idAccountRequired', 1;
  END;

  /**
   * @validation Validate page parameters
   * @throw {invalidPageNumber}
   */
  IF (@page < 1)
  BEGIN
    ;THROW 51000, 'invalidPageNumber', 1;
  END;

  /**
   * @validation Validate page size
   * @throw {invalidPageSize}
   */
  IF (@pageSize NOT IN (12, 24, 36))
  BEGIN
    SET @pageSize = 12;
  END;

  DECLARE @offset INT = (@page - 1) * @pageSize;

  /**
   * @rule {db-multi-tenancy,fn-product-filtering} Apply filters and multi-tenancy
   */
  WITH [FilteredProducts] AS (
    SELECT
      [prd].[idProduct],
      [prd].[name],
      [prd].[description],
      [prd].[basePrice],
      [prd].[promotionalPrice],
      [prd].[mainImage],
      [prd].[averageRating],
      [prd].[totalReviews],
      [prd].[preparationTime],
      [prd].[available],
      [cnf].[name] AS [confectionerName],
      [cat].[name] AS [categoryName]
    FROM [functional].[product] [prd]
      JOIN [functional].[confectioner] [cnf] ON ([cnf].[idAccount] = [prd].[idAccount] AND [cnf].[idConfectioner] = [prd].[idConfectioner])
      JOIN [functional].[category] [cat] ON ([cat].[idAccount] = [prd].[idAccount] AND [cat].[idCategory] = [prd].[idCategory])
    WHERE [prd].[idAccount] = @idAccount
      AND [prd].[deleted] = 0
      AND [prd].[active] = 1
      AND ([cnf].[deleted] = 0)
      AND ([cat].[deleted] = 0)
      AND (@availableOnly = 0 OR [prd].[available] = 1)
      AND (@categoryIds IS NULL OR [prd].[idCategory] IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@categoryIds, ',')))
      AND (@confectionerIds IS NULL OR [prd].[idConfectioner] IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@confectionerIds, ',')))
      AND (@minPrice IS NULL OR [prd].[basePrice] >= @minPrice)
      AND (@maxPrice IS NULL OR [prd].[basePrice] <= @maxPrice)
      AND (
        @searchTerm IS NULL
        OR [prd].[name] LIKE '%' + @searchTerm + '%'
        OR [prd].[description] LIKE '%' + @searchTerm + '%'
        OR [prd].[ingredients] LIKE '%' + @searchTerm + '%'
      )
      AND (
        @flavorIds IS NULL
        OR EXISTS (
          SELECT 1
          FROM [functional].[productFlavor] [prdFlv]
          WHERE [prdFlv].[idAccount] = [prd].[idAccount]
            AND [prdFlv].[idProduct] = [prd].[idProduct]
            AND [prdFlv].[idFlavor] IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@flavorIds, ','))
            AND [prdFlv].[available] = 1
        )
      )
      AND (
        @sizeIds IS NULL
        OR EXISTS (
          SELECT 1
          FROM [functional].[productSize] [prdSiz]
          WHERE [prdSiz].[idAccount] = [prd].[idAccount]
            AND [prdSiz].[idProduct] = [prd].[idProduct]
            AND [prdSiz].[idSize] IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@sizeIds, ','))
            AND [prdSiz].[available] = 1
        )
      )
  )
  /**
   * @output {Products, n, n}
   * @column {INT} idProduct - Product identifier
   * @column {NVARCHAR} name - Product name
   * @column {NVARCHAR} description - Product description
   * @column {NUMERIC} basePrice - Base price
   * @column {NUMERIC} promotionalPrice - Promotional price (nullable)
   * @column {NVARCHAR} mainImage - Main image URL
   * @column {NUMERIC} averageRating - Average rating
   * @column {INT} totalReviews - Total reviews count
   * @column {NVARCHAR} preparationTime - Preparation time
   * @column {BIT} available - Availability status
   * @column {NVARCHAR} confectionerName - Confectioner name
   * @column {NVARCHAR} categoryName - Category name
   */
  SELECT
    [idProduct],
    [name],
    [description],
    [basePrice],
    [promotionalPrice],
    [mainImage],
    [averageRating],
    [totalReviews],
    [preparationTime],
    [available],
    [confectionerName],
    [categoryName]
  FROM [FilteredProducts]
  ORDER BY
    CASE WHEN @sortBy = 'preco_menor' THEN [basePrice] END ASC,
    CASE WHEN @sortBy = 'preco_maior' THEN [basePrice] END DESC,
    CASE WHEN @sortBy = 'melhor_avaliados' THEN [averageRating] END DESC,
    CASE WHEN @sortBy = 'relevancia' THEN [averageRating] END DESC,
    [name] ASC
  OFFSET @offset ROWS
  FETCH NEXT @pageSize ROWS ONLY;

  /**
   * @output {TotalCount, 1, 1}
   * @column {INT} totalCount - Total products matching filters
   * @column {INT} totalPages - Total pages available
   */
  SELECT
    COUNT(*) AS [totalCount],
    CEILING(CAST(COUNT(*) AS FLOAT) / @pageSize) AS [totalPages]
  FROM [FilteredProducts];
END;
GO