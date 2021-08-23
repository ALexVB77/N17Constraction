-- Item Unit of Measure
DELETE FROM [dbo].[Real Estate$Item Unit of Measure$437dbf0e-84ff-417a-965d-ed2bb9650972]

INSERT INTO [dbo].[Real Estate$Item Unit of Measure$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Item No_],
	[Code],
	[Qty_ per Unit of Measure],
	[Length],
	[Width],
	[Height],
	[Cubage],
	[Weight]
)
SELECT 
	[Item No_],
	[Code],
	[Qty_ per Unit of Measure],
	[Length],
	[Width],
	[Height],
	[Cubage],
	[Weight]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$Item Unit of Measure]