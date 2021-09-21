--No Series Line

DELETE FROM [Bonava-Test].[dbo].[Bonava$No_ Series Line$437dbf0e-84ff-417a-965d-ed2bb9650972];
INSERT INTO [Bonava-Test].[dbo].[Bonava$No_ Series Line$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Series Code],
	[Line No_],
	[Starting Date],
	[Starting No_],
	[Ending No_],
	[Warning No_],
	[Increment-by No_],
	[Last No_ Used],
	[Open],
	[Last Date Used]
)
SELECT
	[Series Code],
	[Line No_],
	[Starting Date],
	[Starting No_],
	[Ending No_],
	[Warning No_],
	[Increment-by No_],
	[Last No_ Used],
	[Open],
	[Last Date Used]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$No_ Series Line];