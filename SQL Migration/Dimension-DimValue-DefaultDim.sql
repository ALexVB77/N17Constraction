DECLARE @SQL NVARCHAR(MAX)

-- Dimension

DELETE FROM [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972];
INSERT INTO [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Code],
	[Name],
	[Code Caption],
	[Filter Caption],
	[Description],
	[Blocked],
	[Consolidation Code],
	[Map-to IC Dimension Code]
)
SELECT
	[Code],[Name],[Code Caption],[Filter Caption],[Description],[Blocked],[Consolidation Code],	[Map-to IC Dimension Code]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension]
WHERE [Code] in ('CC','CP','Õœ','Õ”-¬»ƒ','Õ”-Œ¡⁄≈ “','Õ”-–¿«Õ»÷¿','œ–»¡_”¡_œ–Œÿ_À≈“','»Õ∆—≈“‹')

-- Dimension Values
DELETE FROM [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972]
INSERT INTO [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$Dimension Value$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Dimension Code],
	[Code],
	[Name],
	[Dimension Value Type],
	[Totaling],
	[Blocked],
	[Consolidation Code],
	[Indentation],
	[Global Dimension No_],
	[Map-to IC Dimension Code],
	[Map-to IC Dimension Value Code],
	[Name 2]
)
SELECT 
	[Dimension Code],[Code],[Name],[Dimension Value Type],[Totaling],[Blocked],[Consolidation Code],[Indentation],[Global Dimension No_],'','',[Name 2]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension Value] 
WHERE [Dimension Code] in ('Õœ','Õ”-¬»ƒ','Õ”-Œ¡⁄≈ “','Õ”-–¿«Õ»÷¿','œ–»¡_”¡_œ–Œÿ_À≈“','»Õ∆—≈“‹')
UNION ALL
SELECT DISTINCT
	DimValueOld.[Dimension Code],
	Map.[New Dimension Value Code], 
	SUBSTRING(Map.[Description],1,50), 
	DimValueOld.[Dimension Value Type],
	'',0,'',0,0,'','',
	SUBSTRING(Map.[Description],51,250)
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension Value] DimValueOld
INNER JOIN [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] Map
	ON Map.[Dimension Code] = DimValueOld.[Dimension Code] collate Cyrillic_General_100_CI_AS
		AND Map.[Old Dimension Value Code] = DimValueOld.[Code] collate Cyrillic_General_100_CI_AS
WHERE DimValueOld.[Dimension Code] in ('CC','CP')

DELETE FROM [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$Dimension Value$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
INSERT INTO [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$Dimension Value$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
    ([Dimension Code]
    ,[Code]
    ,[Cost Holder]
    ,[Check CF Forecast]
    ,[Project Code]
    ,[Cost Code Type]
    ,[Development Cost Place Holder]
    ,[Production Cost Place Holder]
    ,[Admin Cost Place Holder]
    ,[Check Address Dimension])
SELECT 
	--[Dimension Code],[Code],[Cost Holder],[Check CF Forecast],'',0,0,0,0,0
	[Dimension Code],[Code],'',0,'',0,0,0,0,0
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension Value] 
WHERE [Dimension Code] in ('Õœ','Õ”-¬»ƒ','Õ”-Œ¡⁄≈ “','Õ”-–¿«Õ»÷¿','œ–»¡_”¡_œ–Œÿ_À≈“','»Õ∆—≈“‹')
UNION ALL
SELECT DISTINCT
	DimValueOld.[Dimension Code],
	Map.[New Dimension Value Code],
	'', --DimValueOld.[Cost Holder],
	0,	--DimValueOld.[Check CF Forecast],
	'',0,0,0,0,0
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension Value] DimValueOld
INNER JOIN [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] Map
	ON Map.[Dimension Code] = DimValueOld.[Dimension Code] collate Cyrillic_General_100_CI_AS
		AND Map.[Old Dimension Value Code] = DimValueOld.[Code] collate Cyrillic_General_100_CI_AS
WHERE DimValueOld.[Dimension Code] in ('CC','CP')


-- Default Dimension

DELETE FROM [Bonava-Test].[dbo].[Bonava$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972]
INSERT INTO [Bonava-Test].[dbo].[Bonava$Default Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972]
	([Table ID]
	,[No_]
	,[Dimension Code]
	,[Dimension Value Code]
	,[Value Posting]
	,[Multi Selection Action])
SELECT
	DD_Old.[Table ID],
	CASE DD_Old.[Table ID] 
		WHEN 14 THEN Loc_Map.[New Location Code]
		WHEN 15 THEN GLA_Map.[New No_]
		ELSE DD_Old.[No_]
	END,
	DD_Old.[Dimension Code],
	CASE 
		WHEN DD_Old.[Dimension Code] IN ('CC','CP') THEN Dim_Map.[New Dimension Value Code]
		ELSE DD_Old.[Dimension Value Code]
	END,
	DD_Old.[Value Posting],
	DD_Old.[Multi Selection Action]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Default Dimension] AS DD_Old
	
LEFT JOIN [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Location] Loc_Old
	ON [Table ID] = 14 AND Loc_Old.[Code] = DD_Old.[No_]
LEFT JOIN [Bonava-Test].[dbo].[Bonava$Location Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] Loc_Map
	ON [Table ID] = 14 AND Loc_Map.[Old Location Code] = DD_Old.[No_] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLA_Map
	ON [Table ID] = 15 AND GLA_Map.[Old No_] = DD_Old.[No_] collate Cyrillic_General_100_CI_AS

LEFT JOIN [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Customer] Cust_Old
	ON [Table ID] = 18 AND Cust_Old.[No_] = DD_Old.[No_]
LEFT JOIN [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Vendor] Vend_Old
	ON [Table ID] = 23 AND Vend_Old.[No_] = DD_Old.[No_]
LEFT JOIN [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Vendor Agreement] VendAgr_Old
	ON [Table ID] = 14901 AND VendAgr_Old.[No_] = DD_Old.[No_]
LEFT JOIN [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Customer Agreement] CustAgr_Old
	ON [Table ID] = 14902 AND CustAgr_Old.[No_] = DD_Old.[No_]

LEFT JOIN [Bonava-Test].[dbo].[Bonava$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] Dim_Map
	ON Dim_Map.[Dimension Code] = DD_Old.[Dimension Code] collate Cyrillic_General_100_CI_AS
		AND Dim_Map.[Old Dimension Value Code] = DD_Old.[Dimension Value Code] collate Cyrillic_General_100_CI_AS

WHERE (DD_Old.[Dimension Code] in ('CC','CP','Õœ','Õ”-¬»ƒ','Õ”-Œ¡⁄≈ “','Õ”-–¿«Õ»÷¿','œ–»¡_”¡_œ–Œÿ_À≈“','»Õ∆—≈“‹')) 
	AND ([Table ID] IN (13,27,5200,5600,5800,14901,14902) 
		OR ([Table ID] = 14 AND Loc_Old.[Blocked] <> 1 AND NOT (Loc_Map.[Old Location Code] IS NULL))
		OR ([Table ID] = 15 AND NOT (GLA_Map.[New No_] IS NULL))
		OR ([Table ID] = 18 AND Cust_Old.Blocked <> 3) 
		OR ([Table ID] = 23 AND Vend_Old.Blocked <> 2)
		OR ([Table ID] = 14901 AND Vend_Old.Blocked <> 2 AND VendAgr_Old.Blocked <> 2)  
		OR ([Table ID] = 14902 AND Cust_Old.Blocked <> 3 AND CustAgr_Old.Blocked <> 2) )
	AND ( (DD_Old.[Dimension Code] IN ('CC','CP') AND NOT (Dim_Map.[Dimension Code] IS NULL)) OR NOT (DD_Old.[Dimension Code] IN ('CC','CP')) )

