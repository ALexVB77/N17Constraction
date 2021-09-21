-- Salesperson\Purchaser

DELETE FROM [Bonava-Test].[dbo].[Bonava$Salesperson_Purchaser$437dbf0e-84ff-417a-965d-ed2bb9650972];
INSERT INTO [Bonava-Test].[dbo].[Bonava$Salesperson_Purchaser$437dbf0e-84ff-417a-965d-ed2bb9650972] 
(
	[Code],
	[Name],
	[Global Dimension 1 Code],
	[Global Dimension 2 Code],
	[E-Mail],
	[Job Title],
	[Search E-Mail],
	[E-Mail 2]
)
SELECT
	SalespersonPurchaser.[Code],
	SalespersonPurchaser.[Name],
	ISNULL(DimensionMapping.[New Dimension Value Code], '') AS [Global Dimension 1 Code],
	ISNULL(DimensionValue.[Code], '') AS [Global Dimension 2 Code],
	SalespersonPurchaser.[E-Mail],
	SalespersonPurchaser.[Job Title],
	SalespersonPurchaser.[Search E-Mail],
	SalespersonPurchaser.[E-Mail 2]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Salesperson_Purchaser] AS SalespersonPurchaser
LEFT JOIN [Bonava-Test].[dbo].[Bonava$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] DimensionMapping
ON DimensionMapping.[Old Dimension Value Code] = SalespersonPurchaser.[Global Dimension 1 Code] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Bonava$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972] DimensionValue
ON DimensionValue.[Code] = SalespersonPurchaser.[Global Dimension 2 Code] collate Cyrillic_General_100_CI_AS;