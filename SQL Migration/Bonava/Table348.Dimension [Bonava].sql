DELETE FROM [Bonava-Test].[dbo].[Bonava$Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972];

--Dimension
INSERT INTO [Bonava-Test].[dbo].[Bonava$Dimension$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Code],
	[Name],
	[Code Caption],
	[Filter Caption],
	[Description],
	[Blocked],
	[Consolidation Code],
	[Map-to IC Dimension Code]
)
SELECT
	[Code],
	[Name],
	[Code Caption],
	[Filter Caption],
	[Description],
	[Blocked],
	[Consolidation Code],
	[Map-to IC Dimension Code]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Dimension]
WHERE [Code] = 'CC' OR 
	  [Code] = 'CP' OR
	  [Code] = 'НП' OR
	  [Code] = 'НУ-ВИД' OR
	  [Code] = 'НУ-ОБЪЕКТ' OR
	  [Code] = 'НУ-РАЗНИЦА' OR
	  [Code] = 'ПРИБ_УБ_ПРОШ_ЛЕТ' OR 
	  [Code] = 'ИНЖСЕТЬ';