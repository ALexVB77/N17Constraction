DELETE FROM [VM-TST-SQL013].[Bonava-Test].[dbo].[TEST$G_L Account$437dbf0e-84ff-417a-965d-ed2bb9650972]

-- G\L Account
INSERT INTO [VM-TST-SQL013].[Bonava-Test].[dbo].[TEST$G_L Account$437dbf0e-84ff-417a-965d-ed2bb9650972]
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
	ISNULL(
		(SELECT TOP 1 [Dimension Value Code] FROM [Bonava-Test].[dbo].[TEST$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972] DD
		 WHERE [Table ID] = 15 AND DD.[No_] = GLAccMapping.[New No_] AND [Dimension Code] = 'CP'), ''),
	ISNULL(
		(SELECT TOP 1 [Dimension Value Code] FROM [Bonava-Test].[dbo].[TEST$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972] DD
		 WHERE [Table ID] = 15 AND DD.[No_] = GLAccMapping.[New No_] AND [Dimension Code] = 'CC'), ''),
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



DELETE FROM [VM-TST-SQL013].[Bonava-Test].[dbo].[TEST$G_L Account$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
INSERT INTO [VM-TST-SQL013].[Bonava-Test].[dbo].[TEST$G_L Account$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
           ([No_]
           ,[Non-transmit])
SELECT
	GLAccMapping.[New No_] AS [No_],
	GLAccount.[Non-transmit]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$G_L Account] AS GLAccount
INNER JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping
ON GLAccMapping.[Old No_] = GLAccount.[No_] collate Cyrillic_General_100_CI_AS