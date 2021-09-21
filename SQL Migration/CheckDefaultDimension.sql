SELECT OldDD.* 
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Default Dimension] AS OldDD

LEFT JOIN [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] Map
	ON Map.[Dimension Code] = OldDD.[Dimension Code] collate Cyrillic_General_100_CI_AS
		AND Map.[Old Dimension Value Code] = OldDD.[Dimension Value Code] collate Cyrillic_General_100_CI_AS

WHERE OldDD.[Dimension Code] in ('CC','CP') and OldDD.[Dimension Code] is null