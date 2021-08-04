DELETE FROM [Bonava-Test].[dbo].[Bonava$Salesperson_Purchaser$437dbf0e-84ff-417a-965d-ed2bb9650972];

-- Salesperson\Purchaser
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


DELETE FROM [Bonava-Test].[dbo].[Bonava$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972] AS DefaultDimension
WHERE DefaultDimension.[Table ID] = '13';

--Default Dimension
INSERT INTO [Bonava-Test].[dbo].[Bonava$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Table ID],
	[No_],
	[Dimension Code],
	[Dimension Value Code],
	[Value Posting],
	[Multi Selection Action]
)
SELECT
	DefaultDimension.[Table ID],
	DefaultDimension.[No_],
	DefaultDimension.[Dimension Code],
	DefaultDimension.[Dimension Value Code],
	DefaultDimension.[Value Posting],
	DefaultDimension.[Multi Selection Action]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Default Dimension] AS DefaultDimension
LEFT JOIN [Bonava-Test].[dbo].[Bonava$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972] DimensionValue
ON DimensionValue.[Code] = DefaultDimension.[Dimension Value Code] collate Cyrillic_General_100_CI_AS
WHERE (DefaultDimension.[Dimension Code] = 'CC' OR 
	   DefaultDimension.[Dimension Code] = 'НП' OR
	   DefaultDimension.[Dimension Code] = 'НУ-ВИД' OR
	   DefaultDimension.[Dimension Code] = 'НУ-ОБЪЕКТ' OR
	   DefaultDimension.[Dimension Code] = 'НУ-РАЗНИЦА' OR
	   DefaultDimension.[Dimension Code] = 'ПРИБ_УБ_ПРОШ_ЛЕТ')
AND DefaultDimension.[Table ID] = '13';

INSERT INTO [Bonava-Test].[dbo].[Bonava$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Table ID],
	[No_],
	[Dimension Code],
	[Dimension Value Code],
	[Value Posting],
	[Multi Selection Action]
)
SELECT
	DefaultDimension.[Table ID],
	DefaultDimension.[No_],
	DefaultDimension.[Dimension Code],
	ISNULL(DimensionMapping.[New Dimension Value Code], '') AS [Dimension Value Code],
	DefaultDimension.[Value Posting],
	DefaultDimension.[Multi Selection Action]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Default Dimension] AS DefaultDimension
LEFT JOIN [Bonava-Test].[dbo].[Bonava$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] DimensionMapping
ON DimensionMapping.[Old Dimension Value Code] = DefaultDimension.[Dimension Value Code] collate Cyrillic_General_100_CI_AS
WHERE DefaultDimension.[Dimension Code] = 'CP' AND DefaultDimension.[Table ID] = '13';