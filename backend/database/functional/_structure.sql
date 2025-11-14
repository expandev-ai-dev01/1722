/**
 * @schema functional
 * Business logic schema for LoveCakes application
 */
CREATE SCHEMA [functional];
GO

/**
 * @table category
 * Product categories for organizing cakes
 * @multitenancy true
 * @softDelete true
 * @alias cat
 */
CREATE TABLE [functional].[category] (
  [idCategory] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(500) NOT NULL DEFAULT (''),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table flavor
 * Available cake flavors
 * @multitenancy true
 * @softDelete true
 * @alias flv
 */
CREATE TABLE [functional].[flavor] (
  [idFlavor] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(500) NOT NULL DEFAULT (''),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table size
 * Available cake sizes with pricing
 * @multitenancy true
 * @softDelete true
 * @alias siz
 */
CREATE TABLE [functional].[size] (
  [idSize] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(500) NOT NULL DEFAULT (''),
  [priceModifier] NUMERIC(18, 6) NOT NULL DEFAULT (0),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table confectioner
 * Cake makers/sellers
 * @multitenancy true
 * @softDelete true
 * @alias cnf
 */
CREATE TABLE [functional].[confectioner] (
  [idConfectioner] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [photo] NVARCHAR(500) NULL,
  [averageRating] NUMERIC(3, 1) NOT NULL DEFAULT (0),
  [totalProductsSold] INTEGER NOT NULL DEFAULT (0),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table product
 * Cake products available for sale
 * @multitenancy true
 * @softDelete true
 * @alias prd
 */
CREATE TABLE [functional].[product] (
  [idProduct] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idCategory] INTEGER NOT NULL,
  [idConfectioner] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(1000) NOT NULL,
  [ingredients] NVARCHAR(MAX) NOT NULL,
  [nutritionalInfo] NVARCHAR(MAX) NULL,
  [basePrice] NUMERIC(18, 6) NOT NULL,
  [promotionalPrice] NUMERIC(18, 6) NULL,
  [mainImage] NVARCHAR(500) NOT NULL,
  [imageGallery] NVARCHAR(MAX) NULL,
  [averageRating] NUMERIC(3, 1) NOT NULL DEFAULT (0),
  [totalReviews] INTEGER NOT NULL DEFAULT (0),
  [preparationTime] NVARCHAR(50) NOT NULL,
  [available] BIT NOT NULL DEFAULT (1),
  [active] BIT NOT NULL DEFAULT (1),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table productFlavor
 * Available flavors for each product
 * @multitenancy true
 * @softDelete false
 * @alias prdFlv
 */
CREATE TABLE [functional].[productFlavor] (
  [idAccount] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [idFlavor] INTEGER NOT NULL,
  [available] BIT NOT NULL DEFAULT (1)
);
GO

/**
 * @table productSize
 * Available sizes for each product
 * @multitenancy true
 * @softDelete false
 * @alias prdSiz
 */
CREATE TABLE [functional].[productSize] (
  [idAccount] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [idSize] INTEGER NOT NULL,
  [available] BIT NOT NULL DEFAULT (1)
);
GO

/**
 * @table review
 * Customer reviews for products
 * @multitenancy true
 * @softDelete true
 * @alias rev
 */
CREATE TABLE [functional].[review] (
  [idReview] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [customerName] NVARCHAR(100) NOT NULL,
  [rating] INTEGER NOT NULL,
  [comment] NVARCHAR(1000) NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table cart
 * Shopping cart items
 * @multitenancy true
 * @softDelete false
 * @alias crt
 */
CREATE TABLE [functional].[cart] (
  [idCart] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idUser] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [idFlavor] INTEGER NOT NULL,
  [idSize] INTEGER NOT NULL,
  [quantity] INTEGER NOT NULL,
  [unitPrice] NUMERIC(18, 6) NOT NULL,
  [totalPrice] NUMERIC(18, 6) NOT NULL,
  [notes] NVARCHAR(200) NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkCategory
 * @keyType Object
 */
ALTER TABLE [functional].[category]
ADD CONSTRAINT [pkCategory] PRIMARY KEY CLUSTERED ([idCategory]);
GO

/**
 * @primaryKey pkFlavor
 * @keyType Object
 */
ALTER TABLE [functional].[flavor]
ADD CONSTRAINT [pkFlavor] PRIMARY KEY CLUSTERED ([idFlavor]);
GO

/**
 * @primaryKey pkSize
 * @keyType Object
 */
ALTER TABLE [functional].[size]
ADD CONSTRAINT [pkSize] PRIMARY KEY CLUSTERED ([idSize]);
GO

/**
 * @primaryKey pkConfectioner
 * @keyType Object
 */
ALTER TABLE [functional].[confectioner]
ADD CONSTRAINT [pkConfectioner] PRIMARY KEY CLUSTERED ([idConfectioner]);
GO

/**
 * @primaryKey pkProduct
 * @keyType Object
 */
ALTER TABLE [functional].[product]
ADD CONSTRAINT [pkProduct] PRIMARY KEY CLUSTERED ([idProduct]);
GO

/**
 * @primaryKey pkProductFlavor
 * @keyType Relationship
 */
ALTER TABLE [functional].[productFlavor]
ADD CONSTRAINT [pkProductFlavor] PRIMARY KEY CLUSTERED ([idAccount], [idProduct], [idFlavor]);
GO

/**
 * @primaryKey pkProductSize
 * @keyType Relationship
 */
ALTER TABLE [functional].[productSize]
ADD CONSTRAINT [pkProductSize] PRIMARY KEY CLUSTERED ([idAccount], [idProduct], [idSize]);
GO

/**
 * @primaryKey pkReview
 * @keyType Object
 */
ALTER TABLE [functional].[review]
ADD CONSTRAINT [pkReview] PRIMARY KEY CLUSTERED ([idReview]);
GO

/**
 * @primaryKey pkCart
 * @keyType Object
 */
ALTER TABLE [functional].[cart]
ADD CONSTRAINT [pkCart] PRIMARY KEY CLUSTERED ([idCart]);
GO

/**
 * @foreignKey fkProduct_Category
 * @target functional.category
 */
ALTER TABLE [functional].[product]
ADD CONSTRAINT [fkProduct_Category] FOREIGN KEY ([idCategory])
REFERENCES [functional].[category]([idCategory]);
GO

/**
 * @foreignKey fkProduct_Confectioner
 * @target functional.confectioner
 */
ALTER TABLE [functional].[product]
ADD CONSTRAINT [fkProduct_Confectioner] FOREIGN KEY ([idConfectioner])
REFERENCES [functional].[confectioner]([idConfectioner]);
GO

/**
 * @foreignKey fkProductFlavor_Product
 * @target functional.product
 */
ALTER TABLE [functional].[productFlavor]
ADD CONSTRAINT [fkProductFlavor_Product] FOREIGN KEY ([idProduct])
REFERENCES [functional].[product]([idProduct]);
GO

/**
 * @foreignKey fkProductFlavor_Flavor
 * @target functional.flavor
 */
ALTER TABLE [functional].[productFlavor]
ADD CONSTRAINT [fkProductFlavor_Flavor] FOREIGN KEY ([idFlavor])
REFERENCES [functional].[flavor]([idFlavor]);
GO

/**
 * @foreignKey fkProductSize_Product
 * @target functional.product
 */
ALTER TABLE [functional].[productSize]
ADD CONSTRAINT [fkProductSize_Product] FOREIGN KEY ([idProduct])
REFERENCES [functional].[product]([idProduct]);
GO

/**
 * @foreignKey fkProductSize_Size
 * @target functional.size
 */
ALTER TABLE [functional].[productSize]
ADD CONSTRAINT [fkProductSize_Size] FOREIGN KEY ([idSize])
REFERENCES [functional].[size]([idSize]);
GO

/**
 * @foreignKey fkReview_Product
 * @target functional.product
 */
ALTER TABLE [functional].[review]
ADD CONSTRAINT [fkReview_Product] FOREIGN KEY ([idProduct])
REFERENCES [functional].[product]([idProduct]);
GO

/**
 * @foreignKey fkCart_Product
 * @target functional.product
 */
ALTER TABLE [functional].[cart]
ADD CONSTRAINT [fkCart_Product] FOREIGN KEY ([idProduct])
REFERENCES [functional].[product]([idProduct]);
GO

/**
 * @foreignKey fkCart_Flavor
 * @target functional.flavor
 */
ALTER TABLE [functional].[cart]
ADD CONSTRAINT [fkCart_Flavor] FOREIGN KEY ([idFlavor])
REFERENCES [functional].[flavor]([idFlavor]);
GO

/**
 * @foreignKey fkCart_Size
 * @target functional.size
 */
ALTER TABLE [functional].[cart]
ADD CONSTRAINT [fkCart_Size] FOREIGN KEY ([idSize])
REFERENCES [functional].[size]([idSize]);
GO

/**
 * @check chkReview_Rating
 * @enum {1} 1 star
 * @enum {2} 2 stars
 * @enum {3} 3 stars
 * @enum {4} 4 stars
 * @enum {5} 5 stars
 */
ALTER TABLE [functional].[review]
ADD CONSTRAINT [chkReview_Rating] CHECK ([rating] BETWEEN 1 AND 5);
GO

/**
 * @check chkCart_Quantity
 */
ALTER TABLE [functional].[cart]
ADD CONSTRAINT [chkCart_Quantity] CHECK ([quantity] > 0 AND [quantity] <= 10);
GO

/**
 * @index ixCategory_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixCategory_Account]
ON [functional].[category]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixFlavor_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixFlavor_Account]
ON [functional].[flavor]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixSize_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixSize_Account]
ON [functional].[size]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixConfectioner_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixConfectioner_Account]
ON [functional].[confectioner]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixProduct_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixProduct_Account]
ON [functional].[product]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixProduct_Category
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixProduct_Category]
ON [functional].[product]([idAccount], [idCategory])
INCLUDE ([name], [basePrice], [available], [active])
WHERE [deleted] = 0;
GO

/**
 * @index ixProduct_Confectioner
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixProduct_Confectioner]
ON [functional].[product]([idAccount], [idConfectioner])
INCLUDE ([name], [basePrice], [available], [active])
WHERE [deleted] = 0;
GO

/**
 * @index ixProduct_Active_Available
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixProduct_Active_Available]
ON [functional].[product]([idAccount], [active], [available])
INCLUDE ([name], [basePrice], [averageRating])
WHERE [deleted] = 0;
GO

/**
 * @index ixReview_Product
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixReview_Product]
ON [functional].[review]([idAccount], [idProduct])
INCLUDE ([rating], [dateCreated])
WHERE [deleted] = 0;
GO

/**
 * @index ixCart_User
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixCart_User]
ON [functional].[cart]([idAccount], [idUser]);
GO

/**
 * @index ixCart_Product_Flavor_Size
 * @type Search
 * @unique true
 */
CREATE UNIQUE NONCLUSTERED INDEX [ixCart_Product_Flavor_Size]
ON [functional].[cart]([idAccount], [idUser], [idProduct], [idFlavor], [idSize]);
GO