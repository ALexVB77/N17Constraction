DELETE FROM [Bonava-Test].[dbo].[Bonava$Dimension Value Combination$437dbf0e-84ff-417a-965d-ed2bb9650972];

-- Dimension Value Combination
INSERT INTO [Bonava-Test].[dbo].[Bonava$Dimension Value Combination$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Dimension 1 Code],
	[Dimension 1 Value Code],
	[Dimension 2 Code],
	[Dimension 2 Value Code]
)
SELECT DISTINCT
	[Dimension 1 Code],
	ISNULL(DimensionValue.[Code], '') AS [Dimension 1 Value Code],
	[Dimension 2 Code],
	ISNULL(DimensionMapping.[New Dimension Value Code], '') AS [Dimension 2 Value Code]
FROM  [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension Value Combination]
LEFT JOIN [Bonava-Test].[dbo].[Bonava$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] DimensionMapping
ON DimensionMapping.[Old Dimension Value Code] = [Dimension 2 Value Code] collate Cyrillic_General_100_CI_AS
INNER JOIN [Bonava-Test].[dbo].[Bonava$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972] DimensionValue
ON DimensionValue.[Code] = [Dimension 1 Value Code] collate Cyrillic_General_100_CI_AS;