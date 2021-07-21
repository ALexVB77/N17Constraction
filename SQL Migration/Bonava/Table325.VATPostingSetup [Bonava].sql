DELETE FROM [Bonava-Test].[dbo].[Bonava$VAT Posting Setup$437dbf0e-84ff-417a-965d-ed2bb9650972];

--VAT Posting Setup
--Base Table
INSERT INTO [Bonava-Test].[dbo].[Bonava$VAT Posting Setup$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[VAT Bus_ Posting Group],
	[VAT Prod_ Posting Group],
	[VAT Calculation Type],
    [VAT _],
    [Unrealized VAT Type],
    [Adjust for Payment Discount],
    [Sales VAT Account],
    [Sales VAT Unreal_ Account],
    [Purchase VAT Account],
    [Purch_ VAT Unreal_ Account],
    [VAT Identifier],
	[Tax Invoice Amount Type],
	[Not Include into VAT Ledger],
    [Trans_ VAT Type],
	[Trans_ VAT Account],
	[VAT Settlement Template],
    [VAT Settlement Batch],
	[VAT Exempt],
	[Manual VAT Settlement],
	[Write-Off VAT Account],
	[VAT Charge No_]
)
SELECT
	[VAT Bus_ Posting Group],
	[VAT Prod_ Posting Group],
	[VAT Calculation Type],
    [VAT %],
    [Unrealized VAT Type],
    [Adjust for Payment Discount],
    ISNULL(GLAccMapping.[New No_], '') AS [Sales VAT Account],
    ISNULL(GLAccMapping2.[New No_], '') AS [Sales VAT Unreal_ Account],
    ISNULL(GLAccMapping3.[New No_], '') AS [Purchase VAT Account],
    ISNULL(GLAccMapping4.[New No_], '') AS [Purch_ VAT Unreal_ Account],
    [VAT Identifier],
	[Tax Invoice Amount Type],
	[Not Include into VAT Ledger],
    [Trans_ VAT Type],
	ISNULL(GLAccMapping5.[New No_], '') AS [Trans_ VAT Account],
	CASE WHEN [Manual VAT Settlement] = '1' THEN 'ВОССТАНОВЛ' ELSE [VAT Settlement Template] END AS [VAT Settlement Template],
    CASE WHEN [Manual VAT Settlement] = '1' THEN 'ЗАЧЕТНДС' ELSE [VAT Settlement Batch] END AS [VAT Settlement Batch],
	[VAT Exempt],
	[Manual VAT Settlement],
	ISNULL(GLAccMapping6.[New No_], '') AS [Write-Off VAT Account],
	ISNULL(GLAccMapping7.[New No_], '') AS [VAT Charge No_]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$VAT Posting Setup]
LEFT JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping
ON GLAccMapping.[Old No_] = [Sales VAT Account] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping2
ON GLAccMapping2.[Old No_] = [Sales VAT Unreal_ Account] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping3
ON GLAccMapping3.[Old No_] = [Purchase VAT Account] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping4
ON GLAccMapping4.[Old No_] = [Purch_ VAT Unreal_ Account] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping5
ON GLAccMapping5.[Old No_] = [Trans_ VAT Account] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping6
ON GLAccMapping6.[Old No_] = [Write-Off VAT Account] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping7
ON GLAccMapping7.[Old No_] = [VAT Charge No_] collate Cyrillic_General_100_CI_AS;

DELETE FROM [Bonava-Test].[dbo].[Bonava$VAT Posting Setup$2944687f-9cf8-4134-a24c-e21fb70a8b1a];

--Table Extension
INSERT INTO [Bonava-Test].[dbo].[Bonava$VAT Posting Setup$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
(
	[VAT Bus_ Posting Group],
	[VAT Prod_ Posting Group],
	[VAT Allocation]
)
SELECT
	[VAT Bus_ Posting Group],
    [VAT Prod_ Posting Group],
    [VAT Allocation]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$VAT Posting Setup];