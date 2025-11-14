/**
 * @summary
 * Adds product to cart or updates quantity if already exists.
 *
 * @procedure spCartAdd
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - POST /api/v1/internal/cart
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {INT} idUser
 *   - Required: Yes
 *   - Description: User identifier
 *
 * @param {INT} idProduct
 *   - Required: Yes
 *   - Description: Product identifier
 *
 * @param {INT} idFlavor
 *   - Required: Yes
 *   - Description: Selected flavor identifier
 *
 * @param {INT} idSize
 *   - Required: Yes
 *   - Description: Selected size identifier
 *
 * @param {INT} quantity
 *   - Required: Yes
 *   - Description: Product quantity
 *
 * @param {NVARCHAR} notes
 *   - Required: No
 *   - Description: Additional notes
 *
 * @testScenarios
 * - Valid cart addition
 * - Update existing cart item
 * - Product not available
 * - Flavor not available
 * - Size not available
 * - Quantity exceeds limit
 */
CREATE OR ALTER PROCEDURE [functional].[spCartAdd]
  @idAccount INT,
  @idUser INT,
  @idProduct INT,
  @idFlavor INT,
  @idSize INT,
  @quantity INT,
  @notes NVARCHAR(200) = NULL
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
   * @validation Validate user ID
   * @throw {idUserRequired}
   */
  IF (@idUser IS NULL)
  BEGIN
    ;THROW 51000, 'idUserRequired', 1;
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
   * @validation Validate flavor selection
   * @throw {flavorRequired}
   */
  IF (@idFlavor IS NULL)
  BEGIN
    ;THROW 51000, 'flavorRequired', 1;
  END;

  /**
   * @validation Validate size selection
   * @throw {sizeRequired}
   */
  IF (@idSize IS NULL)
  BEGIN
    ;THROW 51000, 'sizeRequired', 1;
  END;

  /**
   * @validation Validate quantity
   * @throw {invalidQuantity}
   */
  IF (@quantity IS NULL OR @quantity < 1 OR @quantity > 10)
  BEGIN
    ;THROW 51000, 'invalidQuantity', 1;
  END;

  /**
   * @validation Verify product exists and is available
   * @throw {productNotAvailable}
   */
  IF NOT EXISTS (
    SELECT 1
    FROM [functional].[product] [prd]
    WHERE [prd].[idProduct] = @idProduct
      AND [prd].[idAccount] = @idAccount
      AND [prd].[deleted] = 0
      AND [prd].[active] = 1
      AND [prd].[available] = 1
  )
  BEGIN
    ;THROW 51000, 'productNotAvailable', 1;
  END;

  /**
   * @validation Verify flavor is available for product
   * @throw {flavorNotAvailable}
   */
  IF NOT EXISTS (
    SELECT 1
    FROM [functional].[productFlavor] [prdFlv]
    WHERE [prdFlv].[idAccount] = @idAccount
      AND [prdFlv].[idProduct] = @idProduct
      AND [prdFlv].[idFlavor] = @idFlavor
      AND [prdFlv].[available] = 1
  )
  BEGIN
    ;THROW 51000, 'flavorNotAvailable', 1;
  END;

  /**
   * @validation Verify size is available for product
   * @throw {sizeNotAvailable}
   */
  IF NOT EXISTS (
    SELECT 1
    FROM [functional].[productSize] [prdSiz]
    WHERE [prdSiz].[idAccount] = @idAccount
      AND [prdSiz].[idProduct] = @idProduct
      AND [prdSiz].[idSize] = @idSize
      AND [prdSiz].[available] = 1
  )
  BEGIN
    ;THROW 51000, 'sizeNotAvailable', 1;
  END;

  DECLARE @basePrice NUMERIC(18, 6);
  DECLARE @priceModifier NUMERIC(18, 6);
  DECLARE @unitPrice NUMERIC(18, 6);
  DECLARE @totalPrice NUMERIC(18, 6);
  DECLARE @existingQuantity INT;
  DECLARE @idCart INT;

  /**
   * @rule {fn-cart-pricing} Calculate prices
   */
  SELECT
    @basePrice = ISNULL([prd].[promotionalPrice], [prd].[basePrice])
  FROM [functional].[product] [prd]
  WHERE [prd].[idProduct] = @idProduct
    AND [prd].[idAccount] = @idAccount;

  SELECT
    @priceModifier = [siz].[priceModifier]
  FROM [functional].[size] [siz]
  WHERE [siz].[idSize] = @idSize
    AND [siz].[idAccount] = @idAccount;

  SET @unitPrice = @basePrice + @priceModifier;
  SET @totalPrice = @unitPrice * @quantity;

  /**
   * @rule {fn-cart-update} Check if item already exists in cart
   */
  SELECT
    @idCart = [crt].[idCart],
    @existingQuantity = [crt].[quantity]
  FROM [functional].[cart] [crt]
  WHERE [crt].[idAccount] = @idAccount
    AND [crt].[idUser] = @idUser
    AND [crt].[idProduct] = @idProduct
    AND [crt].[idFlavor] = @idFlavor
    AND [crt].[idSize] = @idSize;

  BEGIN TRY
    BEGIN TRAN;

    IF (@idCart IS NOT NULL)
    BEGIN
      /**
       * @rule {fn-cart-update} Update existing cart item
       */
      DECLARE @newQuantity INT = @existingQuantity + @quantity;

      /**
       * @validation Check quantity limit
       * @throw {quantityExceedsLimit}
       */
      IF (@newQuantity > 10)
      BEGIN
        ;THROW 51000, 'quantityExceedsLimit', 1;
      END;

      UPDATE [functional].[cart]
      SET
        [quantity] = @newQuantity,
        [totalPrice] = @unitPrice * @newQuantity,
        [notes] = ISNULL(@notes, [notes])
      WHERE [idCart] = @idCart;
    END
    ELSE
    BEGIN
      /**
       * @rule {fn-cart-create} Insert new cart item
       */
      INSERT INTO [functional].[cart] (
        [idAccount],
        [idUser],
        [idProduct],
        [idFlavor],
        [idSize],
        [quantity],
        [unitPrice],
        [totalPrice],
        [notes]
      )
      VALUES (
        @idAccount,
        @idUser,
        @idProduct,
        @idFlavor,
        @idSize,
        @quantity,
        @unitPrice,
        @totalPrice,
        @notes
      );

      SET @idCart = SCOPE_IDENTITY();
    END;

    COMMIT TRAN;

    /**
     * @output {CartItem, 1, n}
     * @column {INT} idCart - Cart item identifier
     * @column {INT} quantity - Item quantity
     * @column {NUMERIC} unitPrice - Unit price
     * @column {NUMERIC} totalPrice - Total price
     */
    SELECT
      [crt].[idCart],
      [crt].[quantity],
      [crt].[unitPrice],
      [crt].[totalPrice]
    FROM [functional].[cart] [crt]
    WHERE [crt].[idCart] = @idCart;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO