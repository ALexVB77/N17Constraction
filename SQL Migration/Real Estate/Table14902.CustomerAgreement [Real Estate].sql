DELETE FROM [Bonava-Test].[dbo].[Real Estate$Customer Agreement$437dbf0e-84ff-417a-965d-ed2bb9650972];
DELETE FROM [Bonava-Test].[dbo].[Real Estate$Customer Agreement$2944687f-9cf8-4134-a24c-e21fb70a8b1a];

--Customer Agreement
-- Base Table
INSERT INTO [Bonava-Test].[dbo].[Real Estate$Customer Agreement$437dbf0e-84ff-417a-965d-ed2bb9650972]
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
	ISNULL(DimensionMapping.[New Dimension Value Code], '') AS [Global Dimension 1 Code],
	ISNULL(DimensionValue.[Code], '') AS [Global Dimension 2 Code],
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
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$Customer Agreement] AS CustomerAgreement
LEFT JOIN [Bonava-Test].[dbo].[Real Estate$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping
ON GLAccMapping.[Old No_] = CustomerAgreement.[Customer Posting Group] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Real Estate$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] DimensionMapping
ON DimensionMapping.[Old Dimension Value Code] = CustomerAgreement.[Global Dimension 1 Code] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Real Estate$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972] DimensionValue
ON DimensionValue.[Code] = CustomerAgreement.[Global Dimension 2 Code] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Real Estate$Location Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] LocationMapping
ON LocationMapping.[Old Location Code] = CustomerAgreement.[Location Code] collate Cyrillic_General_100_CI_AS
WHERE CustomerAgreement.[Blocked] <> '2';

--Table Extension
INSERT INTO [Bonava-Test].[dbo].[Real Estate$Customer Agreement$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
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
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$Customer Agreement]
WHERE [Blocked] <> '2';


DELETE FROM [Bonava-Test].[dbo].[Real Estate$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972] AS DefaultDimension
WHERE DefaultDimension.[Table ID] = '14902';

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
AND DefaultDimension.[Table ID] = '14902';

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
WHERE DefaultDimension.[Dimension Code] = 'CP' AND DefaultDimension.[Table ID] = '14902';