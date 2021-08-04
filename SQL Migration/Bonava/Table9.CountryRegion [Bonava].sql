DELETE FROM [Bonava-Test].[dbo].[Bonava$Country_Region$437dbf0e-84ff-417a-965d-ed2bb9650972];

--Country\Region
INSERT INTO [Bonava-Test].[dbo].[Bonava$Country_Region$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Code],
	[Name],
	[EU Country_Region Code],
	[Intrastat Code],
	[Address Format],
	[Contact Address Format],
	[Local Name]
)
SELECT
	[Code],
	[Name],
	[EU Country_Region Code],
	[Intrastat Code],
	[Address Format],
	[Contact Address Format],
	[Local Name]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Country_Region];