DELETE FROM [Bonava-Test].[dbo].[Bonava$Inventory Posting Setup$437dbf0e-84ff-417a-965d-ed2bb9650972];

--Inventory Posting Setup
INSERT INTO [Bonava-Test].[dbo].[Bonava$Inventory Posting Setup$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Location Code],
	[Invt_ Posting Group Code],
	[Inventory Account],
	[Description],
    [View All Accounts on Lookup],
    [Inventory Account (Interim)],
    [Purch_ PD Gains Acc_],
    [Purch_ PD Losses Acc_],
    [WIP Account],
    [Material Variance Account],
    [Capacity Variance Account],
    [Mfg_ Overhead Variance Account],
    [Cap_ Overhead Variance Account],
    [Subcontracted Variance Account]
)
SELECT DISTINCT
	LocationMapping.[New Location Code] AS [Location Code],
	ISNULL(GLAccMapping.[New No_], '') AS [Invt_ Posting Group Code],
	ISNULL(GLAccMapping1.[New No_], '') AS [Inventory Account],
	'' AS [Description],
	0 AS [View All Accounts on Lookup],
	'' AS [Inventory Account (Interim)],
	'' AS [Purch_ PD Gains Acc_],
	'' AS [Purch_ PD Losses Acc_],
	'' AS [WIP Account],
	'' AS [Material Variance Account],
	'' AS [Capacity Variance Account],
	'' AS [Mfg_ Overhead Variance Account],
	'' AS [Cap_ Overhead Variance Account],
	'' AS [Subcontracted Variance Account]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Inventory Posting Setup] 
INNER JOIN [Bonava-Test].[dbo].[Bonava$Location Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] LocationMapping
ON LocationMapping.[Old Location Code] = [Location Code] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping
ON GLAccMapping.[Old No_] = [Invt_ Posting Group Code] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping1
ON GLAccMapping1.[Old No_] = [Inventory Account] collate Cyrillic_General_100_CI_AS;