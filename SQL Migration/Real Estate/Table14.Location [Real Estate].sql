DELETE FROM [Bonava-Test].[dbo].[Real Estate$Location$437dbf0e-84ff-417a-965d-ed2bb9650972];
DELETE FROM [Bonava-Test].[dbo].[Real Estate$Location$2944687f-9cf8-4134-a24c-e21fb70a8b1a];

-- Location
-- Base Table
INSERT INTO [Bonava-Test].[dbo].[Real Estate$Location$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Code],
	[Name],
	[Default Bin Code],
	[Name 2],
	[Address],
	[Address 2],
	[City],
	[Phone No_],
	[Phone No_ 2],
	[Telex No_],
	[Fax No_],
	[Contact],
	[Post Code],
	[County],
	[E-Mail],
	[Home Page],
	[Country_Region Code],
	[Use As In-Transit],
	[Require Put-away],
	[Require Pick],
	[Cross-Dock Due Date Calc_],
	[Use Cross-Docking],
	[Require Receive],
	[Require Shipment],
	[Bin Mandatory],
	[Directed Put-away and Pick],
	[Default Bin Selection],
	[Outbound Whse_ Handling Time],
	[Inbound Whse_ Handling Time],
	[Put-away Template Code],
	[Use Put-away Worksheet],
	[Pick According to FEFO],
	[Allow Breakbulk],
	[Bin Capacity Policy],
	[Open Shop Floor Bin Code],
	[To-Production Bin Code],
	[From-Production Bin Code],
	[Adjustment Bin Code],
	[Always Create Put-away Line],
	[Always Create Pick Line],
	[Special Equipment],
	[Receipt Bin Code],
	[Shipment Bin Code],
	[Cross-Dock Bin Code],
	[To-Assembly Bin Code],
	[From-Assembly Bin Code],
	[Asm_-to-Order Shpt_ Bin Code],
	[Base Calendar Code],
	[Use ADCS],
	[Last Goods Report No_],
	[Last Goods Report Date],
	[Responsible Employee No_]
)
SELECT
	LocationMapping.[New Location Code] AS [Code],
    [Name],
	'' AS [Default Bin Code],
	[Name 2],
	'' AS [Address],
	'' AS [Address 2],
	'' AS [City],
	'' AS [Phone No_],
	'' AS [Phone No_ 2],
	'' AS [Telex No_],
	'' AS [Fax No_],
	'' AS [Contact],
	'' AS [Post Code],
	'' AS [County],
	'' AS [E-Mail],
	'' AS [Home Page],
	'' AS [Country_Region Code],
	[Use As In-Transit],
	0 AS [Require Put-away],
	0 AS [Require Pick],
	'' AS [Cross-Dock Due Date Calc_],
	0 AS [Use Cross-Docking],
	0 AS [Require Receive],
	0 AS [Require Shipment],
	[Bin Mandatory],
	0 AS [Directed Put-away and Pick],
	[Default Bin Selection],
	'' AS [Outbound Whse_ Handling Time],
	'' AS [Inbound Whse_ Handling Time],
	'' AS [Put-away Template Code],
	0 AS [Use Put-away Worksheet],
	0 AS [Pick According to FEFO],
	0 AS [Allow Breakbulk],
	0 AS [Bin Capacity Policy],
	'' AS [Open Shop Floor Bin Code],
	'' AS [To-Production Bin Code],
	'' AS [From-Production Bin Code],
	'' AS [Adjustment Bin Code],
	0 AS [Always Create Put-away Line],
	0 AS [Always Create Pick Line],
	0 AS [Special Equipment],
	'' AS [Receipt Bin Code],
	'' AS [Shipment Bin Code],
	'' AS [Cross-Dock Bin Code],
	'' AS [To-Assembly Bin Code],
	'' AS [From-Assembly Bin Code],
	'' AS [Asm_-to-Order Shpt_ Bin Code],
	'' AS [Base Calendar Code],
	0 AS [Use ADCS],
	0 AS [Last Goods Report No_],
	[Last Goods Report Date],
	'' AS [Responsible Employee No_]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Location]
INNER JOIN [Bonava-Test].[dbo].[Real Estate$Location Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] LocationMapping
ON LocationMapping.[Old Location Code] = [Code] collate Cyrillic_General_100_CI_AS
WHERE [Blocked] <> '1';

-- Table Extension
INSERT INTO [Bonava-Test].[dbo].[Real Estate$Location$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
(
	[Code],
	[Blocked],
	[Def_ Gen_ Bus_ Posting Group]
)
SELECT 
	LocationMapping.[New Location Code] AS [Code],
	[Blocked],
	[Def_ Gen_ Bus_ Posting Group]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Location]
INNER JOIN [Bonava-Test].[dbo].[Real Estate$Location Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] LocationMapping
ON LocationMapping.[Old Location Code] = [Code] collate Cyrillic_General_100_CI_AS
WHERE [Blocked] <> '1';


DELETE FROM [Bonava-Test].[dbo].[Real Estate$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972] AS DefaultDimension
WHERE DefaultDimension.[Table ID] = '14';

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
	LocationMapping.[New Location Code] AS [No_],
	DefaultDimension.[Dimension Code],
	DefaultDimension.[Dimension Value Code],
	DefaultDimension.[Value Posting],
	DefaultDimension.[Multi Selection Action]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$Default Dimension] AS DefaultDimension
INNER JOIN [Bonava-Test].[dbo].[Real Estate$Location Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] LocationMapping
ON LocationMapping.[Old Location Code] = DefaultDimension.[No_] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Real Estate$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972] DimensionValue
ON DimensionValue.[Code] = DefaultDimension.[Dimension Value Code] collate Cyrillic_General_100_CI_AS
WHERE (DefaultDimension.[Dimension Code] = 'CC' OR 
	   DefaultDimension.[Dimension Code] = 'НП' OR
	   DefaultDimension.[Dimension Code] = 'НУ-ВИД' OR
	   DefaultDimension.[Dimension Code] = 'НУ-ОБЪЕКТ' OR
	   DefaultDimension.[Dimension Code] = 'НУ-РАЗНИЦА' OR
	   DefaultDimension.[Dimension Code] = 'ПРИБ_УБ_ПРОШ_ЛЕТ')
AND DefaultDimension.[Table ID] = '14';

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
	LocationMapping.[New Location Code] AS [No_],
	DefaultDimension.[Dimension Code],
	ISNULL(DimensionMapping.[New Dimension Value Code], '') AS [Dimension Value Code],
	DefaultDimension.[Value Posting],
	DefaultDimension.[Multi Selection Action]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$Default Dimension] AS DefaultDimension
INNER JOIN [Bonava-Test].[dbo].[Real Estate$Location Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] LocationMapping
ON LocationMapping.[Old Location Code] = DefaultDimension.[No_] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Real Estate$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] DimensionMapping
ON DimensionMapping.[Old Dimension Value Code] = DefaultDimension.[Dimension Value Code] collate Cyrillic_General_100_CI_AS
WHERE DefaultDimension.[Dimension Code] = 'CP' AND DefaultDimension.[Table ID] = '14';