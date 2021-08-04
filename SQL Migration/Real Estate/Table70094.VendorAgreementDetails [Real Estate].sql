DELETE FROM [Bonava-Test].[dbo].[Real Estate$Vendor Agreement Details$2944687f-9cf8-4134-a24c-e21fb70a8b1a];

--Vendor Agreement Details
INSERT INTO [Bonava-Test].[dbo].[Real Estate$Vendor Agreement Details$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
(
	[Vendor No_],
	[Agreement No_],
	[Line No_],
	[Project Code],
	[Global Dimension 1 Code],
	[Global Dimension 2 Code], --
	[Description],
	[Cost Type],
	[Amount],
	[Agreement Description],
	[Agreement Date],
	[Agreement Amount],
	[VAT Amount],
	[Amount Without VAT],
	[Project Line No_],
	[Original Amount],
	[ByOrder],
	[Close Commitment],
	[Close Ordered],
	[AmountLCY],
	[Currency Code]
)
SELECT 
	[Vendor No_],
	[Agreement No_],
	[Line No_],
	[Project Code],
	ISNULL(DimensionMapping.[New Dimension Value Code], '') AS [Global Dimension 1 Code],
	ISNULL(DimensionValue.[Code], '') AS [Global Dimension 2 Code], --
	[Description],
	[Cost Type],
	[Amount],
	[Agreement Description],
	[Agreement Date],
	[Agreement Amount],
	[VAT Amount],
	[Amount Without VAT],
	[Project Line No_],
	[Original Amount],
	[ByOrder],
	[Close Commitment],
	[Close Ordered],
	[AmountLCY],
	[Currency Code]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$Vendor Agreement Details]
LEFT JOIN [Bonava-Test].[dbo].[Real Estate$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] DimensionMapping
ON DimensionMapping.[Old Dimension Value Code] = [Global Dimension 1 Code] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Real Estate$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972] DimensionValue
ON DimensionValue.[Code] = [Global Dimension 2 Code] collate Cyrillic_General_100_CI_AS;