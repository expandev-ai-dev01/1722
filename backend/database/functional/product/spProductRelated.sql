/**
 * @summary
 * Retrieves related products based on category, confectioner, or popularity.
 *
 * @procedure spProductRelated
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/product/:id/related
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {INT} idProduct
 *   - Required: Yes
 *   - Description: Reference product identifier
 *
 * @param {INT} limit
 *   - Required: No
 *   - Description: Number of related products (default: 4)
 *
 * @testScenarios
 * - Valid related products retrieval
 * - Product not found
 * - No related products available
 * - Fallback to popular products
 */
CREATE OR ALTER PROCEDURE [functional].[spProductRelated]
  @idAccount INT,
  @idProduct INT,
  @limit INT = 4
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
   * @validation Validate product ID
   * @throw {idProductRequired}
   */
  IF (@idProduct IS NULL)
  BEGIN
    ;THROW 51000, 'idProductRequired', 1;
  END;

  DECLARE @idCategory INT;
  DECLARE @idConfectioner INT;

  /**
   * @rule {db-data-consistency,fn-product-related} Get reference product details
   */
  SELECT
    @idCategory = [idCategory],
    @idConfectioner = [idConfectioner]
  FROM [functional].[product]
  WHERE [idProduct] = @idProduct
    AND [idAccount] = @idAccount
    AND [deleted] = 0;

  /**
   * @validation Verify product exists
   * @throw {productNotFound}
   */
  IF (@idCategory IS NULL)
  BEGIN
    ;THROW 51000, 'productNotFound', 1;
  END;

  /**
   * @rule {db-multi-tenancy,fn-product-related} Find related products
   * Priority: same confectioner > same category > popular
   */
  WITH [RelatedProducts] AS (
    SELECT
      [prd].[idProduct],
      [prd].[name],
      [prd].[basePrice],
      [prd].[promotionalPrice],
      [prd].[mainImage],
      [prd].[averageRating],
      [prd].[totalReviews],
      [cnf].[name] AS [confectionerName],
      CASE
        WHEN [prd].[idConfectioner] = @idConfectioner THEN 1
        WHEN [prd].[idCategory] = @idCategory THEN 2
        ELSE 3
      END AS [priority]
    FROM [functional].[product] [prd]
      JOIN [functional].[confectioner] [cnf] ON ([cnf].[idAccount] = [prd].[idAccount] AND [cnf].[idConfectioner] = [prd].[idConfectioner])
    WHERE [prd].[idAccount] = @idAccount
      AND [prd].[idProduct] <> @idProduct
      AND [prd].[deleted] = 0
      AND [prd].[active] = 1
      AND [prd].[available] = 1
      AND [cnf].[deleted] = 0
      AND (
        [prd].[idConfectioner] = @idConfectioner
        OR [prd].[idCategory] = @idCategory
      )
  )
  /**
   * @output {RelatedProducts, n, n}
   * @column {INT} idProduct - Product identifier
   * @column {NVARCHAR} name - Product name
   * @column {NUMERIC} basePrice - Base price
   * @column {NUMERIC} promotionalPrice - Promotional price (nullable)
   * @column {NVARCHAR} mainImage - Main image URL
   * @column {NUMERIC} averageRating - Average rating
   * @column {INT} totalReviews - Total reviews count
   * @column {NVARCHAR} confectionerName - Confectioner name
   */
  SELECT TOP (@limit)
    [idProduct],
    [name],
    [basePrice],
    [promotionalPrice],
    [mainImage],
    [averageRating],
    [totalReviews],
    [confectionerName]
  FROM [RelatedProducts]
  ORDER BY
    [priority] ASC,
    [averageRating] DESC,
    [totalReviews] DESC;

  /**
   * @rule {fn-product-related} If not enough related products, fill with popular
   */
  IF (@@ROWCOUNT < @limit)
  BEGIN
    DECLARE @remaining INT = @limit - @@ROWCOUNT;

    SELECT TOP (@remaining)
      [prd].[idProduct],
      [prd].[name],
      [prd].[basePrice],
      [prd].[promotionalPrice],
      [prd].[mainImage],
      [prd].[averageRating],
      [prd].[totalReviews],
      [cnf].[name] AS [confectionerName]
    FROM [functional].[product] [prd]
      JOIN [functional].[confectioner] [cnf] ON ([cnf].[idAccount] = [prd].[idAccount] AND [cnf].[idConfectioner] = [prd].[idConfectioner])
    WHERE [prd].[idAccount] = @idAccount
      AND [prd].[idProduct] <> @idProduct
      AND [prd].[deleted] = 0
      AND [prd].[active] = 1
      AND [prd].[available] = 1
      AND [cnf].[deleted] = 0
      AND [prd].[idProduct] NOT IN (
        SELECT [idProduct]
        FROM [RelatedProducts]
      )
    ORDER BY
      [prd].[averageRating] DESC,
      [prd].[totalReviews] DESC;
  END;
END;
GO