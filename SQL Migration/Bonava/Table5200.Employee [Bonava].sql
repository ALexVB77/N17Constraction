-- Employee

-- Base Table 
DELETE FROM [Bonava-Test].[dbo].[Bonava$Employee$437dbf0e-84ff-417a-965d-ed2bb9650972];
INSERT INTO [Bonava-Test].[dbo].[Bonava$Employee$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[No_],
	[First Name],
	[Middle Name],
	[Last Name],
	[Initials],
	[Job Title],
	[Search Name],
	[Address],
	[Address 2],
	[City],
	[Post Code],
	[County],
	[Phone No_],
	[Mobile Phone No_],
	[E-Mail],
	[Alt_ Address Code],
	[Alt_ Address Start Date],
	[Alt_ Address End Date],
	[Birth Date],
	[Social Security No_],
	[Union Code],
	[Union Membership No_],
	[Gender],
	[Country_Region Code],
	[Manager No_],
	[Emplymt_ Contract Code],
	[Statistics Group Code],
	[Employment Date],
	[Status],
	[Inactive Date],
	[Termination Date],
	[Grounds for Term_ Code],
	[Resource No_],
	[Last Date Modified],
	[Salespers__Purch_ Code],
	[No_ Series],
	[Short Name]
)
SELECT
	[No_],
	[First Name],
	[Middle Name],
	[Last Name],
	[Initials],
	SUBSTRING([Job Title], 1, 50) AS [Job Title],
	[Search Name],
	[Address],
	[Address 2],
	[City],
	[Post Code],
	[County],
	[Phone No_],
	[Mobile Phone No_],
	[E-Mail],
	[Alt_ Address Code],
	[Alt_ Address Start Date],
	[Alt_ Address End Date],
	[Birth Date],
	[Social Security No_],
	[Union Code],
	[Union Membership No_],
	[Gender],
	[Country_Region Code],
	[Manager No_],
	[Emplymt_ Contract Code],
	[Statistics Group Code],
	[Employment Date],
	[Status],
	[Inactive Date],
	[Termination Date],
	[Grounds for Term_ Code],
	[Resource No_],
	[Last Date Modified],
	[Salespers__Purch_ Code],
	[No_ Series],
	[Short Name]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Employee];

-- Table Extension
DELETE FROM [Bonava-Test].[dbo].[Bonava$Employee$2944687f-9cf8-4134-a24c-e21fb70a8b1a];
INSERT INTO [Bonava-Test].[dbo].[Bonava$Employee$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
(
	[No_],
	[Full Name Genitive],
	[Job Title Genitive]
)
SELECT
	[No_],
	[Full Name Genitive],
	[Job Title Genitive]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Employee];