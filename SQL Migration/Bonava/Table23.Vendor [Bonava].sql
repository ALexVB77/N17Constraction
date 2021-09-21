--Vendor

-- Base Table
DELETE FROM [Bonava-Test].[dbo].[Bonava$Vendor$437dbf0e-84ff-417a-965d-ed2bb9650972];
INSERT INTO [Bonava-Test].[dbo].[Bonava$Vendor$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	 [No_],
     [Name],
     [Search Name],
     [Name 2],
     [Address],
	 [Address 2],
     [City],
     [Phone No_],
     [Vendor Posting Group],
     [Currency Code],
	 [Purchaser Code],
	 [Invoice Disc_ Code],
	 [Blocked],
	 [Last Date Modified],
	 [VAT Registration No_],
	 [Gen_ Bus_ Posting Group],
	 [Post Code],
	 [E-Mail],
	 [No_ Series],
	 [VAT Bus_ Posting Group],
	 [Location Code],
	 [OKPO Code],
	 [Customer No_],
	 [Employee No_],
	 [Full Name],
	 [VAT Agent],
	 [VAT Agent Prod_ Posting Group],
	 [VAT Agent Type],
	 [Tax Authority No_],
	 [Vendor Type],
	 [KPP Code],
	 [Agreement Posting],
	 [Agreement Nos_]	
)
SELECT
	 Vendor.[No_],
     Vendor.[Name],
     Vendor.[Search Name],
     Vendor.[Name 2],
     Vendor.[Address],
	 Vendor.[Address 2],
     Vendor.[City],
     Vendor.[Phone No_],
     ISNULL(GLAccMapping.[New No_], '') AS [Vendor Posting Group],
     Vendor.[Currency Code],
	 Vendor.[Purchaser Code],
	 Vendor.[Invoice Disc_ Code],
	 Vendor.[Blocked],
	 Vendor.[Last Date Modified],
	 Vendor.[VAT Registration No_],
	 Vendor.[Gen_ Bus_ Posting Group],
	 Vendor.[Post Code],
	 Vendor.[E-Mail],
	 Vendor.[No_ Series],
	 Vendor.[VAT Bus_ Posting Group],
	 ISNULL(LocationMapping.[New Location Code], '') AS [Location Code],
	 Vendor.[OKPO Code],
	 Vendor.[Customer No_],
	 Vendor.[Employee No_],
	 Vendor.[Full Name],
	 Vendor.[VAT Agent],
	 Vendor.[VAT Agent Prod_ Posting Group],
	 Vendor.[VAT Agent Type],
	 Vendor.[Tax Authority No_],
	 Vendor.[Vendor Type],
	 Vendor.[KPP Code],
	 Vendor.[Agreement Posting],
	 Vendor.[Agreement Nos_]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Vendor] AS Vendor
LEFT JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping
ON GLAccMapping.[Old No_] = Vendor.[Vendor Posting Group] collate Cyrillic_General_100_CI_AS
LEFT JOIN [Bonava-Test].[dbo].[Bonava$Location Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] LocationMapping
ON LocationMapping.[Old Location Code] = Vendor.[Location Code] collate Cyrillic_General_100_CI_AS
WHERE [Blocked] <> '2';

-- Table Extension
DELETE FROM [Bonava-Test].[dbo].[Bonava$Vendor$2944687f-9cf8-4134-a24c-e21fb70a8b1a];
INSERT INTO [Bonava-Test].[dbo].[Bonava$Vendor$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
(
	[No_],
    [Vat Agent Posting Group],
    [Giv_ Manuf_ Location Code],
    [Giv_ Manuf_ Bin Code]
)
SELECT 
	[No_],
	ISNULL(GLAccMapping.[New No_], '') AS [Vat Agent Posting Group],
    [Giv_ Manuf_ Location Code],
    [Giv_ Manuf_ Bin Code]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Vendor]
LEFT JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping
ON GLAccMapping.[Old No_] = [Vat Agent Posting Group] collate Cyrillic_General_100_CI_AS
WHERE [Blocked] <> '2';