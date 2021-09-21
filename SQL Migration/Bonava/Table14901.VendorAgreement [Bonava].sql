-- Vendor Agreement Table

-- Base Table
DELETE FROM [Bonava-Test].[dbo].[Bonava$Vendor Agreement$437dbf0e-84ff-417a-965d-ed2bb9650972];
INSERT INTO [Bonava-Test].[dbo].[Bonava$Vendor Agreement$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Vendor No_],
	[No_],
	[Agreement Group],
	[Description],
	[External Agreement No_],
	[Agreement Date],
	[Active],
	[Starting Date],
	[Expire Date],
	[Phone No_],
	[Global Dimension 1 Code],
	[Global Dimension 2 Code],
	[Vendor Posting Group],
	[Currency Code],
	[Purchaser Code],
	[Blocked],
	[Gen_ Bus_ Posting Group],
	[E-Mail],
	[No_ Series],
	[VAT Bus_ Posting Group],
	[Location Code],
	[VAT Agent Prod_ Posting Group],
	[VAT Payment Source Type],
	[Tax Authority No_]
)
SELECT 
	VendorAgreement.[Vendor No_],
	VendorAgreement.[No_],
	VendorAgreement.[Agreement Group],
	VendorAgreement.[Description],
	VendorAgreement.[External Agreement No_],
	VendorAgreement.[Agreement Date],
	VendorAgreement.[Active],
	VendorAgreement.[Starting Date],
	VendorAgreement.[Expire Date],
	VendorAgreement.[Phone No_],
	ISNULL(
		(SELECT TOP 1 [Dimension Value Code] FROM [Bonava-Test].[dbo].[Bonava$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972] DD
		 WHERE [Table ID] = 14901 AND DD.[No_] = VendorAgreement.[No_] collate Cyrillic_General_100_CI_AS AND [Dimension Code] = 'CP'), ''),
	ISNULL(
		(SELECT TOP 1 [Dimension Value Code] FROM [Bonava-Test].[dbo].[Bonava$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972] DD
		 WHERE [Table ID] = 14901 AND DD.[No_] = VendorAgreement.[No_] collate Cyrillic_General_100_CI_AS AND [Dimension Code] = 'CC'), ''),
	ISNULL(GLAccMapping.[New No_], '') AS [Vendor Posting Group],
	VendorAgreement.[Currency Code],
	VendorAgreement.[Purchaser Code],
	VendorAgreement.[Blocked],
	VendorAgreement.[Gen_ Bus_ Posting Group],
	VendorAgreement.[E-Mail],
	VendorAgreement.[No_ Series],
	VendorAgreement.[VAT Bus_ Posting Group],
	ISNULL(LocationMapping.[New Location Code], '') AS [Location Code],
	VendorAgreement.[VAT Agent Prod_ Posting Group],
	VendorAgreement.[VAT Payment Source Type],
	VendorAgreement.[Tax Authority No_]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Vendor Agreement] VendorAgreement
LEFT JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping
ON GLAccMapping.[Old No_] = VendorAgreement.[Vendor Posting Group] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Bonava$Location Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] LocationMapping
ON LocationMapping.[Old Location Code] = VendorAgreement.[Location Code] collate Cyrillic_General_100_CI_AS
INNER JOIN [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Vendor] Vendor
ON Vendor.[No_] = VendorAgreement.[Vendor No_] AND Vendor.[Blocked] <> 2 
WHERE VendorAgreement.[Blocked] <> 2;

-- Table Extension
DELETE FROM [Bonava-Test].[dbo].[Bonava$Vendor Agreement$2944687f-9cf8-4134-a24c-e21fb70a8b1a];
INSERT INTO [Bonava-Test].[dbo].[Bonava$Vendor Agreement$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
(
	[Vendor No_],
	[No_],
	[Vat Agent Posting Group],
	[Agreement Amount],
	[VAT Amount],
	[Amount Without VAT],
	[WithOut],
	[Unbound Cost],
	[Check Limit Starting Date],
	[Check Limit Ending Date],
	[Check Limit Amount (LCY)],
	[Don_t Check CashFlow]
)
SELECT DISTINCT
	VendorAgreement.[Vendor No_],
	VendorAgreement.[No_],
	ISNULL(GLAccMapping.[New No_], '') AS [Vat Agent Posting Group],
	VendorAgreement.[Agreement Amount],
	VendorAgreement.[VAT Amount],
	VendorAgreement.[Amount Without VAT],
	VendorAgreement.[WithOut],
	VendorAgreement.[Unbound Cost],
	VendorAgreement.[Check Limit Starting Date],
	VendorAgreement.[Check Limit Ending Date],
	VendorAgreement.[Check Limit Amount (LCY)],
	VendorAgreement.[Don_t Check CashFlow]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Vendor Agreement] VendorAgreement
LEFT JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping
ON GLAccMapping.[Old No_] = [Vendor Posting Group] collate Cyrillic_General_100_CI_AS
INNER JOIN [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Vendor] Vendor
ON Vendor.[No_] = VendorAgreement.[Vendor No_] AND Vendor.[Blocked] <> 2
WHERE VendorAgreement.[Blocked] <> 2;