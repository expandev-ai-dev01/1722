/**
 * @summary
 * Retrieves detailed product information including flavors, sizes, and reviews.
 *
 * @procedure spProductGet
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/product/:id
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {INT} idProduct
 *   - Required: Yes
 *   - Description: Product identifier
 *
 * @testScenarios
 * - Valid product retrieval
 * - Product not found
 * - Product from different account
 * - Deleted product access
 */
CREATE OR ALTER PROCEDURE [functional].[spProductGet]
  @idAccount INT,
  @idProduct INT
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

  /**
   * @validation Verify product exists
   * @throw {productNotFound}
   */
  IF NOT EXISTS (
    SELECT 1
    FROM [functional].[product] [prd]
    WHERE [prd].[idProduct] = @idProduct
      AND [prd].[idAccount] = @idAccount
      AND [prd].[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'productNotFound', 1;
  END;

  /**
   * @output {ProductDetails, 1, n}
   * @column {INT} idProduct - Product identifier
   * @column {NVARCHAR} name - Product name
   * @column {NVARCHAR} description - Product description
   * @column {NVARCHAR} ingredients - Product ingredients (JSON array)
   * @column {NVARCHAR} nutritionalInfo - Nutritional information (JSON)
   * @column {NUMERIC} basePrice - Base price
   * @column {NUMERIC} promotionalPrice - Promotional price (nullable)
   * @column {NVARCHAR} mainImage - Main image URL
   * @column {NVARCHAR} imageGallery - Image gallery (JSON array)
   * @column {NUMERIC} averageRating - Average rating
   * @column {INT} totalReviews - Total reviews count
   * @column {NVARCHAR} preparationTime - Preparation time
   * @column {BIT} available - Availability status
   * @column {INT} idConfectioner - Confectioner identifier
   * @column {NVARCHAR} confectionerName - Confectioner name
   * @column {NVARCHAR} confectionerPhoto - Confectioner photo URL
   * @column {NUMERIC} confectionerRating - Confectioner average rating
   * @column {INT} confectionerProductsSold - Total products sold by confectioner
   */
  SELECT
    [prd].[idProduct],
    [prd].[name],
    [prd].[description],
    [prd].[ingredients],
    [prd].[nutritionalInfo],
    [prd].[basePrice],
    [prd].[promotionalPrice],
    [prd].[mainImage],
    [prd].[imageGallery],
    [prd].[averageRating],
    [prd].[totalReviews],
    [prd].[preparationTime],
    [prd].[available],
    [cnf].[idConfectioner],
    [cnf].[name] AS [confectionerName],
    [cnf].[photo] AS [confectionerPhoto],
    [cnf].[averageRating] AS [confectionerRating],
    [cnf].[totalProductsSold] AS [confectionerProductsSold]
  FROM [functional].[product] [prd]
    JOIN [functional].[confectioner] [cnf] ON ([cnf].[idAccount] = [prd].[idAccount] AND [cnf].[idConfectioner] = [prd].[idConfectioner])
  WHERE [prd].[idProduct] = @idProduct
    AND [prd].[idAccount] = @idAccount
    AND [prd].[deleted] = 0;

  /**
   * @output {Flavors, n, n}
   * @column {INT} idFlavor - Flavor identifier
   * @column {NVARCHAR} name - Flavor name
   * @column {BIT} available - Flavor availability for this product
   */
  SELECT
    [flv].[idFlavor],
    [flv].[name],
    [prdFlv].[available]
  FROM [functional].[productFlavor] [prdFlv]
    JOIN [functional].[flavor] [flv] ON ([flv].[idAccount] = [prdFlv].[idAccount] AND [flv].[idFlavor] = [prdFlv].[idFlavor])
  WHERE [prdFlv].[idAccount] = @idAccount
    AND [prdFlv].[idProduct] = @idProduct
    AND [flv].[deleted] = 0
  ORDER BY [flv].[name];

  /**
   * @output {Sizes, n, n}
   * @column {INT} idSize - Size identifier
   * @column {NVARCHAR} name - Size name
   * @column {NVARCHAR} description - Size description
   * @column {NUMERIC} priceModifier - Additional price for this size
   * @column {BIT} available - Size availability for this product
   */
  SELECT
    [siz].[idSize],
    [siz].[name],
    [siz].[description],
    [siz].[priceModifier],
    [prdSiz].[available]
  FROM [functional].[productSize] [prdSiz]
    JOIN [functional].[size] [siz] ON ([siz].[idAccount] = [prdSiz].[idAccount] AND [siz].[idSize] = [prdSiz].[idSize])
  WHERE [prdSiz].[idAccount] = @idAccount
    AND [prdSiz].[idProduct] = @idProduct
    AND [siz].[deleted] = 0
  ORDER BY [siz].[priceModifier];

  /**
   * @output {Reviews, n, n}
   * @column {INT} idReview - Review identifier
   * @column {NVARCHAR} customerName - Customer name
   * @column {INT} rating - Rating (1-5)
   * @column {NVARCHAR} comment - Review comment
   * @column {DATETIME2} dateCreated - Review date
   */
  SELECT
    [rev].[idReview],
    [rev].[customerName],
    [rev].[rating],
    [rev].[comment],
    [rev].[dateCreated]
  FROM [functional].[review] [rev]
  WHERE [rev].[idAccount] = @idAccount
    AND [rev].[idProduct] = @idProduct
    AND [rev].[deleted] = 0
  ORDER BY [rev].[dateCreated] DESC;
END;
GO