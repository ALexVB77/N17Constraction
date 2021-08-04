DELETE FROM [Bonava-Test].[dbo].[Real Estate$Gen_ Journal Batch$437dbf0e-84ff-417a-965d-ed2bb9650972];

--Gen Journal Batch
--Base Table
INSERT INTO [Bonava-Test].[dbo].[Real Estate$Gen_ Journal Batch$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Journal Template Name],
	[Name],
	[Description],
	[Reason Code],
	[Bal_ Account Type],
	[Bal_ Account No_],
	[No_ Series],
	[Posting No_ Series],
	[Copy VAT Setup to Jnl_ Lines],
	[Allow VAT Difference]
)
SELECT
	[Journal Template Name],
	[Name],
	[Description],
	[Reason Code],
	[Bal_ Account Type],
	ISNULL(GLAccMapping.[New No_], '') AS [Bal_ Account No_],
	[No_ Series],
	[Posting No_ Series],
	[Copy VAT Setup to Jnl_ Lines],
	[Allow VAT Difference]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$Gen_ Journal Batch]
LEFT JOIN [Bonava-Test].[dbo].[Real Estate$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping
ON GLAccMapping.[Old No_] = [Bal_ Account No_] collate Cyrillic_General_100_CI_AS;