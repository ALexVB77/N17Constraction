DELETE FROM [Bonava-Test].[dbo].[Real Estate$Contact Business Relation$437dbf0e-84ff-417a-965d-ed2bb9650972];

--Contact Business Relation
INSERT INTO [Bonava-Test].[dbo].[Real Estate$Contact Business Relation$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Contact No_],
	[Business Relation Code],
	[Link to Table],
	[No_]
)
SELECT 
	CBR.[Contact No_],
	CBR.[Business Relation Code],
	CBR.[Link to Table],
	CBR.[No_]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$Contact Business Relation] AS CBR
INNER JOIN [Bonava-Test].[dbo].[Real Estate$Customer$437dbf0e-84ff-417a-965d-ed2bb9650972] Customer
ON Customer.[No_] = CBR.[No_] collate Cyrillic_General_100_CI_AS