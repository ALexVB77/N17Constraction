DELETE FROM [Bonava-Test].[dbo].[Real Estate$Vendor Agreement$437dbf0e-84ff-417a-965d-ed2bb9650972];
DELETE FROM [Bonava-Test].[dbo].[Real Estate$Vendor Agreement$2944687f-9cf8-4134-a24c-e21fb70a8b1a];

-- Vendor Agreement Table
INSERT INTO [Bonava-Test].[dbo].[Real Estate$Vendor Agreement$437dbf0e-84ff-417a-965d-ed2bb9650972]
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
	ISNULL(DimensionMapping.[New Dimension Value Code], '') AS [Global Dimension 1 Code],
	ISNULL(DimensionValue.[Code], '') AS [Global Dimension 2 Code],
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
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$Vendor Agreement] VendorAgreement
LEFT JOIN [Bonava-Test].[dbo].[Real Estate$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping
ON GLAccMapping.[Old No_] = [Vendor Posting Group] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Real Estate$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] DimensionMapping
ON DimensionMapping.[Old Dimension Value Code] = VendorAgreement.[Global Dimension 1 Code] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Real Estate$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972] DimensionValue
ON DimensionValue.[Code] = VendorAgreement.[Global Dimension 2 Code] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Real Estate$Location Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] LocationMapping
ON LocationMapping.[Old Location Code] = VendorAgreement.[Location Code] collate Cyrillic_General_100_CI_AS
WHERE VendorAgreement.[Blocked] <> '2';

-- Vendor Agreement Table Extension
INSERT INTO [Bonava-Test].[dbo].[Real Estate$Vendor Agreement$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
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
	[Vendor No_],
	[No_],
	ISNULL(GLAccMapping.[New No_], '') AS [Vat Agent Posting Group],
	[Agreement Amount],
	[VAT Amount],
	[Amount Without VAT],
	[WithOut],
	[Unbound Cost],
	[Check Limit Starting Date],
	[Check Limit Ending Date],
	[Check Limit Amount (LCY)],
	[Don_t Check CashFlow]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$Vendor Agreement]
LEFT JOIN [Bonava-Test].[dbo].[Real Estate$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping
ON GLAccMapping.[Old No_] = [Vendor Posting Group] collate Cyrillic_General_100_CI_AS
WHERE [Blocked] <> '2';


DELETE FROM [Bonava-Test].[dbo].[Real Estate$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972] AS DefaultDimension
WHERE DefaultDimension.[Table ID] = '14901';

--Default Dimension
INSERT INTO [Bonava-Test].[dbo].[Real Estate$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Table ID],
	[No_],
	[Dimension Code],
	[Dimension Value Code],
	[Value Posting],
	[Multi Selection Action]
)
SELECT
	DefaultDimension.[Table ID],
	DefaultDimension.[No_],
	DefaultDimension.[Dimension Code],
	DefaultDimension.[Dimension Value Code],
	DefaultDimension.[Value Posting],
	DefaultDimension.[Multi Selection Action]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$Default Dimension] AS DefaultDimension
LEFT JOIN [Bonava-Test].[dbo].[Real Estate$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972] DimensionValue
ON DimensionValue.[Code] = DefaultDimension.[Dimension Value Code] collate Cyrillic_General_100_CI_AS
WHERE (DefaultDimension.[Dimension Code] = 'CC' OR 
	   DefaultDimension.[Dimension Code] = 'НП' OR
	   DefaultDimension.[Dimension Code] = 'НУ-ВИД' OR
	   DefaultDimension.[Dimension Code] = 'НУ-ОБЪЕКТ' OR
	   DefaultDimension.[Dimension Code] = 'НУ-РАЗНИЦА' OR
	   DefaultDimension.[Dimension Code] = 'ПРИБ_УБ_ПРОШ_ЛЕТ')
AND DefaultDimension.[Table ID] = '14901';

INSERT INTO [Bonava-Test].[dbo].[Real Estate$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Table ID],
	[No_],
	[Dimension Code],
	[Dimension Value Code],
	[Value Posting],
	[Multi Selection Action]
)
SELECT
	DefaultDimension.[Table ID],
	DefaultDimension.[No_],
	DefaultDimension.[Dimension Code],
	ISNULL(DimensionMapping.[New Dimension Value Code], '') AS [Dimension Value Code],
	DefaultDimension.[Value Posting],
	DefaultDimension.[Multi Selection Action]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$Default Dimension] AS DefaultDimension
LEFT JOIN [Bonava-Test].[dbo].[Real Estate$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] DimensionMapping
ON DimensionMapping.[Old Dimension Value Code] = DefaultDimension.[Dimension Value Code] collate Cyrillic_General_100_CI_AS
WHERE DefaultDimension.[Dimension Code] = 'CP' AND DefaultDimension.[Table ID] = '14901';


DELETE FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$Comment Line];
-- Comment Line
INSERT INTO [Bonava-Test].[dbo].[Real Estate$Comment Line$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Table Name],
	[No_],
	[Line No_],
	[Date],
	[Comment]
)
SELECT
	[Table Name],
	[No_],
	[Line No_],
	[Date],
	[Comment]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$Comment Line];