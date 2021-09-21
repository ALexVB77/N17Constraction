--Contact

-- Base Table
DELETE FROM [Bonava-Test].[dbo].[Bonava$Contact$437dbf0e-84ff-417a-965d-ed2bb9650972];
INSERT INTO [Bonava-Test].[dbo].[Bonava$Contact$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[No_],
	[Name],
	[Search Name],
	[Name 2],
	[Address],
	[Address 2],
	[City],
	[Phone No_],
	[Telex No_],
	[Territory Code],
	[Currency Code],
	[Language Code],
	[Salesperson Code],
	[Country_Region Code],
	[Last Date Modified],
	[Fax No_],
	[Telex Answer Back],
	[VAT Registration No_],
	[Picture],
	[Post Code],
	[County],
	[E-Mail],
	[Home Page],
	[No_ Series],
	[Type],
	[Company No_],
	[Company Name],
	[Lookup Contact No_],
	[First Name],
	[Middle Name],
	[Surname],
	[Job Title],
	[Initials],
	[Extension No_],
	[Mobile Phone No_],
	[Pager],
	[Organizational Level Code],
	[Exclude from Segment],
	[External ID],
	[Correspondence Type],
	[Salutation Code],
	[Search E-Mail],
	[Last Time Modified],
	[E-Mail 2]
)
SELECT 
	Contact.[No_],
	Contact.[Name],
	Contact.[Search Name],
	Contact.[Name 2],
	SUBSTRING(Contact.[Address], 1, 100),
	Contact.[Address 2],
	Contact.[City],
	Contact.[Phone No_],
	'' AS [Telex No_],
	'' AS [Territory Code],
	'' AS [Currency Code],
	'' AS [Language Code],
	Contact.[Salesperson Code],
	Contact.[Country_Region Code],
	Contact.[Last Date Modified],
	Contact.[Fax No_],
	'' AS [Telex Answer Back],
	Contact.[VAT Registration No_],
	Contact.[Picture],
	Contact.[Post Code],
	'' AS [County],
	Contact.[E-Mail],
	'' AS [Home Page],
	Contact.[No_ Series],
	Contact.[Type],
	Contact.[Company No_],
	Contact.[Company Name],
	Contact.[Lookup Contact No_],
	Contact.[First Name],
	Contact.[Middle Name],
	Contact.[Surname],
	'' AS [Job Title],
	Contact.[Initials],
	'' AS [Extension No_],
	Contact.[Mobile Phone No_],
	Contact.[Pager],
	'' AS [Organizational Level Code],
	'' AS [Exclude from Segment],
	'' AS [External ID],
	'' AS [Correspondence Type],
	Contact.[Salutation Code],
	Contact.[Search E-Mail],
	Contact.[Last Time Modified],
	Contact.[E-Mail 2]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Contact] AS Contact
INNER JOIN [Bonava-Test].[dbo].[Bonava$Contact Business Relation$437dbf0e-84ff-417a-965d-ed2bb9650972] CBR
ON CBR.[Contact No_] = Contact.[No_] collate Cyrillic_General_100_CI_AS;

-- Table Extension
DELETE FROM [Bonava-Test].[dbo].[Bonava$Contact$2944687f-9cf8-4134-a24c-e21fb70a8b1a];
INSERT INTO [Bonava-Test].[dbo].[Bonava$Contact$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
(
	[No_],
	[Delivery of passport],
	[Passport No_],
	[Passport Series],
	[Registration]
)
SELECT 
	Contact.[No_],
	Contact.[Delivery of passport],
	Contact.[Passport No_],
	Contact.[Passport Series],
	Contact.[Registration]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Contact] AS Contact
INNER JOIN [Bonava-Test].[dbo].[Bonava$Contact Business Relation$437dbf0e-84ff-417a-965d-ed2bb9650972] CBR
ON CBR.[Contact No_] = Contact.[No_] collate Cyrillic_General_100_CI_AS;