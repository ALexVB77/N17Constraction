DELETE FROM [Bonava-Test].[dbo].[Real Estate$No_ Series Relationship$437dbf0e-84ff-417a-965d-ed2bb9650972];

--No Series Relationship
INSERT INTO [Bonava-Test].[dbo].[Real Estate$No_ Series Relationship$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Code],
	[Series Code]
)
SELECT
	[Code],
	[Series Code]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$No_ Series Relationship];