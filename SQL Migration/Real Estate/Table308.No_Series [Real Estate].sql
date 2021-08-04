DELETE FROM [Bonava-Test].[dbo].[Real Estate$No_ Series$437dbf0e-84ff-417a-965d-ed2bb9650972];

-- No Series
INSERT INTO [Bonava-Test].[dbo].[Real Estate$No_ Series$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Code],
	[Description],
	[Default Nos_],
	[Manual Nos_],
	[Date Order]
)
SELECT
	[Code],
	[Description],
	[Default Nos_],
	[Manual Nos_],
	[Date Order]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$No_ Series];