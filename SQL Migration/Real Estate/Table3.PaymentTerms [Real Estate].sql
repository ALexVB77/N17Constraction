DELETE FROM [Bonava-Test].[dbo].[Real Estate$Payment Terms$437dbf0e-84ff-417a-965d-ed2bb9650972];

--Payment Terms
INSERT INTO [Bonava-Test].[dbo].[Real Estate$Payment Terms$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Code],
	[Due Date Calculation],
	[Discount Date Calculation],
	[Discount _],
	[Description]
)
SELECT
	[Code],
	[Due Date Calculation],
	[Discount Date Calculation],
	[Discount %],
	[Description]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$Payment Terms];