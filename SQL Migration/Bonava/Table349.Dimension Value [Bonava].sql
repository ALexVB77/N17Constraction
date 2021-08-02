-- Dimension Value
-- Base Table
-- ИНЖСЕТЬ
DELETE FROM [Bonava-Test].[dbo].[Bonava$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972]
WHERE [Dimension Code] = 'ИНЖСЕТЬ';

INSERT INTO [Bonava-Test].[dbo].[Bonava$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972]
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
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension Value]
WHERE [Dimension Code] = 'ИНЖСЕТЬ';

-- CP
DELETE FROM [Bonava-Test].[dbo].[Bonava$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972]
WHERE [Dimension Code] = 'CP';

INSERT INTO [Bonava-Test].[dbo].[Bonava$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Dimension Code],
	[Code],
	[Name],
	[Dimension Value Type],
	[Blocked],
	[Consolidation Code],
	[Indentation],
	[Global Dimension No_],
	[Map-to IC Dimension Code],
	[Map-to IC Dimension Value Code]
)
SELECT DISTINCT
	QueryResult.[Dimension Code],
	QueryResult.[New Dimension Value Code] AS [Code],
	QueryResult.[Description] AS [Description],
	ISNULL ((SELECT 
				DimensionValue.[Dimension Value Type]
			 FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension Value] AS DimensionValue
			 WHERE DimensionValue.[Dimension Code] = QueryResult.[Dimension Code] collate Cyrillic_General_100_CI_AS 
			 AND DimensionValue.[Code] = QueryResult.[Old Dimension Value Code] collate Cyrillic_General_100_CI_AS), '') AS [Dimension Value Type],
	ISNULL ((SELECT 
				DimensionValue.[Blocked]
			 FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension Value] AS DimensionValue
			 WHERE DimensionValue.[Dimension Code] = QueryResult.[Dimension Code] collate Cyrillic_General_100_CI_AS 
		     AND DimensionValue.[Code] = QueryResult.[Old Dimension Value Code] collate Cyrillic_General_100_CI_AS), '') AS [Blocked],
	ISNULL ((SELECT 
			    DimensionValue.[Consolidation Code]
			 FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension Value] AS DimensionValue
			 WHERE DimensionValue.[Dimension Code] = QueryResult.[Dimension Code] collate Cyrillic_General_100_CI_AS 
		     AND DimensionValue.[Code] = QueryResult.[Old Dimension Value Code] collate Cyrillic_General_100_CI_AS), '') AS [Consolidation Code],
	ISNULL ((SELECT 
				DimensionValue.[Indentation]
			 FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension Value] AS DimensionValue
			 WHERE DimensionValue.[Dimension Code] = QueryResult.[Dimension Code] collate Cyrillic_General_100_CI_AS 
			 AND DimensionValue.[Code] = QueryResult.[Old Dimension Value Code] collate Cyrillic_General_100_CI_AS), '') AS [Indentation],
	ISNULL ((SELECT 
				DimensionValue.[Global Dimension No_]
			 FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension Value] AS DimensionValue
			 WHERE DimensionValue.[Dimension Code] = QueryResult.[Dimension Code] collate Cyrillic_General_100_CI_AS 
			 AND DimensionValue.[Code] = QueryResult.[Old Dimension Value Code] collate Cyrillic_General_100_CI_AS), '') AS [Global Dimension No_],
	ISNULL ((SELECT 
				DimensionValue.[Map-to IC Dimension Code]
			 FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension Value] AS DimensionValue
			 WHERE DimensionValue.[Dimension Code] = QueryResult.[Dimension Code] collate Cyrillic_General_100_CI_AS 
			 AND DimensionValue.[Code] = QueryResult.[Old Dimension Value Code] collate Cyrillic_General_100_CI_AS), '') AS [Map-to IC Dimension Code],
	ISNULL ((SELECT 
				DimensionValue.[Map-to IC Dimension Value Code]
			FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension Value] AS DimensionValue
			WHERE DimensionValue.[Dimension Code] = QueryResult.[Dimension Code] collate Cyrillic_General_100_CI_AS 
			AND DimensionValue.[Code] = QueryResult.[Old Dimension Value Code] collate Cyrillic_General_100_CI_AS), '') AS [Map-to IC Dimension Value Code]
FROM
( SELECT DISTINCT
	 DimensionMapping.[Dimension Code],
	 DimensionMapping.[New Dimension Value Code],
	 DimensionMapping.[Old Dimension Value Code],
	 DimensionMapping.[Description]
  FROM [Bonava-Test].[dbo].[Bonava$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] AS DimensionMapping 
  WHERE DimensionMapping.[Dimension Code] = 'CP') QueryResult;

-- Table Extension
-- ИНЖСЕТЬ
DELETE FROM [Bonava-Test].[dbo].[Bonava$Dimension Value$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
WHERE [Dimension Code] = 'ИНЖСЕТЬ';

INSERT INTO [Bonava-Test].[dbo].[Bonava$Dimension Value$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
(
	[Dimension Code],
	[Code],
	[Check CF Forecast],
	[Cost Holder]
)
SELECT
	[Dimension Code],
	[Code],
	[Check CF Forecast],
	[Cost Holder]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension Value]
WHERE [Dimension Code] = 'ИНЖСЕТЬ';

-- CP
DELETE FROM [Bonava-Test].[dbo].[Bonava$Dimension Value$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
WHERE [Dimension Code] = 'CP';

INSERT INTO [Bonava-Test].[dbo].[Bonava$Dimension Value$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
(
	[Dimension Code],
	[Code],
	[Check CF Forecast],
	[Cost Holder],
	[Project Code]
)
SELECT 
	[Dimension Code],
	[Code],
	[Check CF Forecast],
	[Cost Holder],
	[Building project Code]
FROM (
SELECT DISTINCT
	QueryResult.[Dimension Code],
	QueryResult.[New Dimension Value Code] AS [Code],
	ISNULL ((SELECT 
				[Check CF Forecast]
			 FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension Value] AS DimensionValue
			 WHERE DimensionValue.[Dimension Code] = QueryResult.[Dimension Code] collate Cyrillic_General_100_CI_AS 
			 AND DimensionValue.[Code] = QueryResult.[Old Dimension Value Code] collate Cyrillic_General_100_CI_AS), '') AS [Check CF Forecast],
	ISNULL ((SELECT 
				[Cost Holder]
			FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension Value] AS DimensionValue
			WHERE DimensionValue.[Dimension Code] = QueryResult.[Dimension Code] collate Cyrillic_General_100_CI_AS 
			AND DimensionValue.[Code] = QueryResult.[Old Dimension Value Code] collate Cyrillic_General_100_CI_AS), '') AS [Cost Holder],
	ISNULL(BuildingTurn.[Building project Code], '') AS [Building project Code]
	,ROW_NUMBER() OVER(PARTITION BY QueryResult.[New Dimension Value Code] ORDER BY ISNULL(BuildingTurn.[Building project Code], '') DESC) AS [ROW]
FROM
( SELECT DISTINCT
	 DimensionMapping.[Dimension Code],
	 DimensionMapping.[New Dimension Value Code],
	 DimensionMapping.[Old Dimension Value Code]
  FROM [Bonava-Test].[dbo].[Bonava$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] AS DimensionMapping 
  WHERE DimensionMapping.[Dimension Code] = 'CP') QueryResult
LEFT JOIN [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Building turn] BuildingTurn
ON BuildingTurn.[Turn Dimension Code] = QueryResult.[Old Dimension Value Code] collate Cyrillic_General_100_CI_AS
) QueryResult1 WHERE QueryResult1.ROW = 1;