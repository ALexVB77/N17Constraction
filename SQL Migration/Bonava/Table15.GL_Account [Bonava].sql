DELETE FROM [Bonava-Test].[dbo].[Bonava$G_L Account$437dbf0e-84ff-417a-965d-ed2bb9650972];

-- G\L Account
INSERT INTO [Bonava-Test].[dbo].[Bonava$G_L Account$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[No_],
	[Name],
	[Search Name],
	[Account Type],
	[Global Dimension 1 Code],
	[Global Dimension 2 Code],
	[Income_Balance],
	[Debit_Credit],
	[No_ 2],
	[Blocked],
	[Direct Posting],
	[Reconciliation Account],
	[New Page],
	[No_ of Blank Lines],
	[Indentation],
	[Last Date Modified],
	[Totaling],
	[Consol_ Translation Method],
	[Consol_ Debit Acc_],
	[Consol_ Credit Acc_],
	[Gen_ Posting Type],
	[Gen_ Bus_ Posting Group],
	[Gen_ Prod_ Posting Group],
	[Automatic Ext_ Texts],
	[Tax Area Code],
	[Tax Liable],
	[Tax Group Code],
	[VAT Bus_ Posting Group],
	[VAT Prod_ Posting Group],
	[Exchange Rate Adjustment],
	[Default IC Partner G_L Acc_ No],
	[Source Type],
	[Currency Code],
	[Balance in Currency],
	[Adjust Debit Acc_],
	[Adjust Credit Acc_]
)
SELECT
	GLAccMapping.[New No_] AS [No_],
	GLAccount.[Name],
	GLAccount.[Search Name],
	GLAccount.[Account Type],
	ISNULL(DimensionMapping.[New Dimension Value Code], '') AS [Global Dimension 1 Code],
	ISNULL(DimensionValue.[Code], '') AS [Global Dimension 2 Code],
	GLAccount.[Income_Balance],
	GLAccount.[Debit_Credit],
	GLAccount.[No_ 2],
	GLAccount.[Blocked],
	GLAccount.[Direct Posting],
	GLAccount.[Reconciliation Account],
	GLAccount.[New Page],
	GLAccount.[No_ of Blank Lines],
	GLAccount.[Indentation],
	GLAccount.[Last Date Modified],
	GLAccount.[Totaling],
	GLAccount.[Consol_ Translation Method],
	GLAccount.[Consol_ Debit Acc_],
	GLAccount.[Consol_ Credit Acc_],
	GLAccount.[Gen_ Posting Type],
	GLAccount.[Gen_ Bus_ Posting Group],
	GLAccount.[Gen_ Prod_ Posting Group],
	GLAccount.[Automatic Ext_ Texts],
	GLAccount.[Tax Area Code],
	GLAccount.[Tax Liable],
	GLAccount.[Tax Group Code],
	GLAccount.[VAT Bus_ Posting Group],
	GLAccount.[VAT Prod_ Posting Group],
	GLAccount.[Exchange Rate Adjustment],
	GLAccount.[Default IC Partner G_L Acc_ No],
	GLAccount.[Source Type],
	GLAccount.[Currency Code],
	GLAccount.[Balance in Currency],
	GLAccount.[Adjust Debit Acc_],
	GLAccount.[Adjust Credit Acc_]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$G_L Account] AS GLAccount
INNER JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping
ON GLAccMapping.[Old No_] = GLAccount.[No_] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Bonava$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] DimensionMapping
ON DimensionMapping.[Old Dimension Value Code] = GLAccount.[Global Dimension 1 Code] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Bonava$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972] DimensionValue
ON DimensionValue.[Code] = GLAccount.[Global Dimension 2 Code] collate Cyrillic_General_100_CI_AS;


DELETE FROM [Bonava-Test].[dbo].[Bonava$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972] AS DefaultDimension
WHERE DefaultDimension.[Table ID] = '15';

--Default Dimension
INSERT INTO [Bonava-Test].[dbo].[Bonava$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972]
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
	GLAccMapping.[New No_] AS [No_],
	DefaultDimension.[Dimension Code],
	DefaultDimension.[Dimension Value Code],
	DefaultDimension.[Value Posting],
	DefaultDimension.[Multi Selection Action]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Default Dimension] AS DefaultDimension
INNER JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping
ON GLAccMapping.[Old No_] = DefaultDimension.[No_] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Bonava$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972] DimensionValue
ON DimensionValue.[Code] = DefaultDimension.[Dimension Value Code] collate Cyrillic_General_100_CI_AS
WHERE (DefaultDimension.[Dimension Code] = 'CC' OR 
	   DefaultDimension.[Dimension Code] = 'НП' OR
	   DefaultDimension.[Dimension Code] = 'НУ-ВИД' OR
	   DefaultDimension.[Dimension Code] = 'НУ-ОБЪЕКТ' OR
	   DefaultDimension.[Dimension Code] = 'НУ-РАЗНИЦА' OR
	   DefaultDimension.[Dimension Code] = 'ПРИБ_УБ_ПРОШ_ЛЕТ')
AND DefaultDimension.[Table ID] = '15';

INSERT INTO [Bonava-Test].[dbo].[Bonava$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972]
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
	GLAccMapping.[New No_] AS [No_],
	DefaultDimension.[Dimension Code],
	ISNULL(DimensionMapping.[New Dimension Value Code], '') AS [Dimension Value Code],
	DefaultDimension.[Value Posting],
	DefaultDimension.[Multi Selection Action]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Default Dimension] AS DefaultDimension
INNER JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping
ON GLAccMapping.[Old No_] = DefaultDimension.[No_] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Bonava$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] DimensionMapping
ON DimensionMapping.[Old Dimension Value Code] = DefaultDimension.[Dimension Value Code] collate Cyrillic_General_100_CI_AS
WHERE DefaultDimension.[Dimension Code] = 'CP' AND DefaultDimension.[Table ID] = '15';