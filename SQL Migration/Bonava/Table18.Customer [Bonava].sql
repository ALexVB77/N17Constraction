DELETE FROM [Bonava-Test].[dbo].[Bonava$Customer$437dbf0e-84ff-417a-965d-ed2bb9650972];
DELETE FROM [Bonava-Test].[dbo].[Bonava$Customer$2944687f-9cf8-4134-a24c-e21fb70a8b1a];

--Customer
-- Base Table
INSERT INTO [Bonava-Test].[dbo].[Bonava$Customer$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[No_],
	[Name],
	[Search Name],
	[Name 2],
	[Address],
	[Address 2],
	[City],
	[Contact],
	[Phone No_],
	[Customer Posting Group],
	[Invoice Disc_ Code],
	[Country_Region Code],
	[Last Date Modified],
	[Prices Including VAT],
	[VAT Registration No_],
	[Gen_ Bus_ Posting Group],
	[Post Code],
	[E-Mail],
	[No_ Series],
	[VAT Bus_ Posting Group],
	[Reserve],
	[Primary Contact No_],
	[Allow Line Disc_],
	[Full Name],
	[KPP Code],
	[Agreement Posting],
	[Agreement Nos_]
)
SELECT
	[No_],
	[Name],
	[Search Name],
	[Name 2],
	[Address],
	[Address 2],
	[City],
	[Contact],
	[Phone No_],
	ISNULL(GLAccMapping.[New No_], '') AS [Customer Posting Group],
	[Invoice Disc_ Code],
	[Country_Region Code],
	[Last Date Modified],
	[Prices Including VAT],
	[VAT Registration No_],
	[Gen_ Bus_ Posting Group],
	[Post Code],
	[E-Mail],
	[No_ Series],
	[VAT Bus_ Posting Group],
	[Reserve],
	[Primary Contact No_],
	[Allow Line Disc_],
	[Full Name],
	[KPP Code],
	[Agreement Posting],
	[Agreement Nos_]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Customer]
LEFT JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping
ON GLAccMapping.[Old No_] = [Customer Posting Group] collate Cyrillic_General_100_CI_AS
WHERE [Blocked] <> '3';

-- Table Extension
INSERT INTO [Bonava-Test].[dbo].[Bonava$Customer$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
(
	[No_],
	[CRM GUID]
)
SELECT
	[No_],
	[CRM GUID]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Customer]
WHERE [Blocked] <> '3';


DELETE FROM [Bonava-Test].[dbo].[Bonava$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972] AS DefaultDimension
WHERE DefaultDimension.[Table ID] = '18';

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
	DefaultDimension.[No_],
	DefaultDimension.[Dimension Code],
	DefaultDimension.[Dimension Value Code],
	DefaultDimension.[Value Posting],
	DefaultDimension.[Multi Selection Action]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Default Dimension] AS DefaultDimension
LEFT JOIN [Bonava-Test].[dbo].[Bonava$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972] DimensionValue
ON DimensionValue.[Code] = DefaultDimension.[Dimension Value Code] collate Cyrillic_General_100_CI_AS
WHERE (DefaultDimension.[Dimension Code] = 'CC' OR 
	   DefaultDimension.[Dimension Code] = 'НП' OR
	   DefaultDimension.[Dimension Code] = 'НУ-ВИД' OR
	   DefaultDimension.[Dimension Code] = 'НУ-ОБЪЕКТ' OR
	   DefaultDimension.[Dimension Code] = 'НУ-РАЗНИЦА' OR
	   DefaultDimension.[Dimension Code] = 'ПРИБ_УБ_ПРОШ_ЛЕТ')
AND DefaultDimension.[Table ID] = '18';

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
	DefaultDimension.[No_],
	DefaultDimension.[Dimension Code],
	ISNULL(DimensionMapping.[New Dimension Value Code], '') AS [Dimension Value Code],
	DefaultDimension.[Value Posting],
	DefaultDimension.[Multi Selection Action]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Default Dimension] AS DefaultDimension
LEFT JOIN [Bonava-Test].[dbo].[Bonava$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] DimensionMapping
ON DimensionMapping.[Old Dimension Value Code] = DefaultDimension.[Dimension Value Code] collate Cyrillic_General_100_CI_AS
WHERE DefaultDimension.[Dimension Code] = 'CP' AND DefaultDimension.[Table ID] = '18';