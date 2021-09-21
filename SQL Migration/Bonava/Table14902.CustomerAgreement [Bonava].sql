--Customer Agreement

-- Base Table
DELETE FROM [Bonava-Test].[dbo].[Bonava$Customer Agreement$437dbf0e-84ff-417a-965d-ed2bb9650972];
INSERT INTO [Bonava-Test].[dbo].[Bonava$Customer Agreement$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Customer No_],
	[No_],
	[Description],
	[External Agreement No_],
	[Agreement Date],
	[Active],
	[Starting Date],
	[Expire Date],
	[Agreement Group],
	[Ship-to Code],
	[Contact],
	[Phone No_],
	[Global Dimension 1 Code],
	[Global Dimension 2 Code],
	[Credit Limit (LCY)],
	[Customer Posting Group],
	[Salesperson Code],
	[Customer Disc_ Group],
	[Prices Including VAT],
	[Blocked],
	[Location Code],
	[Gen_ Bus_ Posting Group],
	[E-Mail],
	[No_ Series],
	[VAT Bus_ Posting Group],
	[Default Bank Code]
)
SELECT
	CustomerAgreement.[Customer No_],
	CustomerAgreement.[No_],
	CustomerAgreement.[Description],
	CustomerAgreement.[External Agreement No_],
	CustomerAgreement.[Agreement Date],
	CustomerAgreement.[Active],
	CustomerAgreement.[Starting Date],
	CustomerAgreement.[Expire Date],
	CustomerAgreement.[Agreement Group],
	CustomerAgreement.[Ship-to Code],
	CustomerAgreement.[Contact],
	CustomerAgreement.[Phone No_],
	ISNULL(
		(SELECT TOP 1 [Dimension Value Code] FROM [Bonava-Test].[dbo].[Bonava$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972] DD
		 WHERE [Table ID] = 14902 AND DD.[No_] = CustomerAgreement.[No_] collate Cyrillic_General_100_CI_AS AND [Dimension Code] = 'CP'), ''),
	ISNULL(
		(SELECT TOP 1 [Dimension Value Code] FROM [Bonava-Test].[dbo].[Bonava$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972] DD
		 WHERE [Table ID] = 14902 AND DD.[No_] = CustomerAgreement.[No_] collate Cyrillic_General_100_CI_AS AND [Dimension Code] = 'CC'), ''),
	CustomerAgreement.[Credit Limit (LCY)],
	ISNULL(GLAccMapping.[New No_], '') AS [Customer Posting Group],
	CustomerAgreement.[Salesperson Code],
	CustomerAgreement.[Customer Disc_ Group],
	CustomerAgreement.[Prices Including VAT],
	CustomerAgreement.[Blocked],
	ISNULL(LocationMapping.[New Location Code], '') AS [Location Code],
	CustomerAgreement.[Gen_ Bus_ Posting Group],
	CustomerAgreement.[E-Mail],
	CustomerAgreement.[No_ Series],
	CustomerAgreement.[VAT Bus_ Posting Group],
	CustomerAgreement.[Default Bank Code]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Customer Agreement] AS CustomerAgreement
LEFT JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping
ON GLAccMapping.[Old No_] = CustomerAgreement.[Customer Posting Group] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Bonava$Location Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] LocationMapping
ON LocationMapping.[Old Location Code] = CustomerAgreement.[Location Code] collate Cyrillic_General_100_CI_AS
INNER JOIN [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Customer] Customer
ON Customer.[No_] = CustomerAgreement.[Customer No_] AND Customer.[Blocked] <> 3 
WHERE CustomerAgreement.[Blocked] <> 3;

--Table Extension
DELETE FROM [Bonava-Test].[dbo].[Bonava$Customer Agreement$2944687f-9cf8-4134-a24c-e21fb70a8b1a];
INSERT INTO [Bonava-Test].[dbo].[Bonava$Customer Agreement$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
(
	[Customer No_],
	[No_],
	[CRM GUID],
	[Agreement Amount],
	[Agreement Sub Type],
	[Agreement Type],
	[Apartment Amount],
	[C1 Delivery of passport],
	[C1 E-Mail],
	[C1 Passport Series],
	[C1 Registration],
	[C1 Telephone],
	[C1 Telephone 1],
	[C2 Delivery of passport],
	[C2 E-Mail],
	[C2 Passport Series],
	[C2 Registration],
	[C2 Telephone],
	[C3 Delivery of passport],
	[C3 E-Mail],
	[C3 Passport №],
	[C3 Passport Series],
	[C3 Registration],
	[C3 Telephone],
	[C4 Telephone],
	[C5 Telephone],
	[Contact 1],
	[Contact 2],
	[Contact 3],
	[Contact 4],
	[Contact 5],
	[Amount part 1],
	[Amount part 2],
	[Amount part 3],
	[Amount part 4],
	[Amount part 5],
	[Amount part 1 Amount],
	[Amount part 2 Amount],
	[Amount part 3 Amount],
	[Amount part 4 Amount],
	[Amount part 5 Amount],
	[Installment Plan Amount],
	[C1 Place and BirthDate]
)
SELECT
	CustomerAgreement.[Customer No_],
	CustomerAgreement.[No_],
	CustomerAgreement.[CRM GUID],
	CustomerAgreement.[Agreement Amount],
	CustomerAgreement.[Agreement Sub Type],
	CustomerAgreement.[Agreement Type],
	CustomerAgreement.[Apartment Amount],
	CustomerAgreement.[C1 Delivery of passport],
	CustomerAgreement.[C1 E-Mail],
	CustomerAgreement.[C1 Passport Series],
	CustomerAgreement.[C1 Registration],
	CustomerAgreement.[C1 Telephone],
	CustomerAgreement.[C1 Telephone 1],
	CustomerAgreement.[C2 Delivery of passport],
	CustomerAgreement.[C2 E-Mail],
	CustomerAgreement.[C2 Passport Series],
	CustomerAgreement.[C2 Registration],
	CustomerAgreement.[C2 Telephone],
	CustomerAgreement.[C3 Delivery of passport],
	CustomerAgreement.[C3 E-Mail],
	CustomerAgreement.[C3 Passport №],
	CustomerAgreement.[C3 Passport Series],
	CustomerAgreement.[C3 Registration],
	CustomerAgreement.[C3 Telephone],
	CustomerAgreement.[C4 Telephone],
	CustomerAgreement.[C5 Telephone],
	CustomerAgreement.[Contact 1],
	CustomerAgreement.[Contact 2],
	CustomerAgreement.[Contact 3],
	CustomerAgreement.[Contact 4],
	CustomerAgreement.[Contact 5],
	CustomerAgreement.[Amount part 1],
	CustomerAgreement.[Amount part 2],
	CustomerAgreement.[Amount part 3],
	CustomerAgreement.[Amount part 4],
	CustomerAgreement.[Amount part 5],
	CustomerAgreement.[Amount part 1 Amount],
	CustomerAgreement.[Amount part 2 Amount],
	CustomerAgreement.[Amount part 3 Amount],
	CustomerAgreement.[Amount part 4 Amount],
	CustomerAgreement.[Amount part 5 Amount],
	CustomerAgreement.[Installment Plan Amount],
	CustomerAgreement.[C1 Place and BirthDate]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Customer Agreement] CustomerAgreement
INNER JOIN [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Customer] Customer
ON Customer.[No_] = CustomerAgreement.[Customer No_] AND Customer.[Blocked] <> 3 
WHERE CustomerAgreement.[Blocked] <> 3;