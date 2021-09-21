--Vendor Agreement Details

DELETE FROM [Bonava-Test].[dbo].[Bonava$Vendor Agreement Details$2944687f-9cf8-4134-a24c-e21fb70a8b1a];
INSERT INTO [Bonava-Test].[dbo].[Bonava$Vendor Agreement Details$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
(
	[Vendor No_],
	[Agreement No_],
	[Line No_],
	[Project Code],
	[Global Dimension 1 Code],
	[Global Dimension 2 Code],
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
	'' AS [Global Dimension 1 Code],
	'' AS [Global Dimension 2 Code],
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
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Vendor Agreement Details];