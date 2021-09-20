DECLARE @SQL NVARCHAR(MAX)

DELETE FROM [VM-TST-SQL013].[Bonava-Test].[dbo].[TEST$Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972];
INSERT INTO [VM-TST-SQL013].[Bonava-Test].[dbo].[TEST$Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Code],
	[Name],
	[Code Caption],
	[Filter Caption],
	[Description],
	[Blocked],
	[Consolidation Code],
	[Map-to IC Dimension Code]
)
SELECT
	[Code],
	[Name],
	[Code Caption],
	[Filter Caption],
	[Description],
	[Blocked],
	[Consolidation Code],
	[Map-to IC Dimension Code]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension]
WHERE [Code] in ('CC','CP','мо','мс-бхд','мс-назейр','мс-пюгмхжю','опха_са_опнь_кер','хмфяерэ')

DELETE FROM [VM-TST-SQL013].[Bonava-Test].[dbo].[TEST$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972]





INSERT INTO [VM-TST-SQL013].[Bonava-Test].[dbo].[TEST$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Dimension Code],
	[Code],
	[Name],
	[Dimension Value Type],
	[Totaling],
	[Blocked],
	[Consolidation Code],
	[Indentation],
	[Global Dimension No_],
	[Map-to IC Dimension Code],
	[Map-to IC Dimension Value Code],
	[Name 2]
)
SELECT
	DimValueOld.[Dimension Code],
	ISNULL(Map.[New Dimension Value Code], DimValueOld.Code),  
	ISNULL(Map.[Description], DimValueOld.[Name]),
	DimValueOld.[Dimension Value Type],
	'',
	DimValueOld.[Blocked],
	'',
	0,
	DimValueOld.[Global Dimension No_],
	'',
	'',
	''
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension Value] DimValueOld

LEFT JOIN [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] Map
	ON Map.[Dimension Code] = DimValueOld.[Dimension Code] collate Cyrillic_General_100_CI_AS
		AND Map.[Old Dimension Value Code] = DimValueOld.[Code] collate Cyrillic_General_100_CI_AS

WHERE DimValueOld.[Dimension Code] in ('CC','CP','мо','мс-бхд','мс-назейр','мс-пюгмхжю','опха_са_опнь_кер','хмфяерэ')