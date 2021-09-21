-- Comment Line

DELETE FROM [Bonava-Test].[dbo].[Bonava$Comment Line$437dbf0e-84ff-417a-965d-ed2bb9650972];
INSERT INTO [Bonava-Test].[dbo].[Bonava$Comment Line$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Table Name],
	[No_],
	[Line No_],
	[Date],
	[Comment]
)
SELECT
	[Table Name],
	[No_],
	[Line No_],
	[Date],
	[Comment]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Comment Line];