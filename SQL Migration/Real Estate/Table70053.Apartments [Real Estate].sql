DELETE FROM [Bonava-Test].[dbo].[Real Estate$Apartments$2944687f-9cf8-4134-a24c-e21fb70a8b1a];

--Apartments
INSERT INTO [Bonava-Test].[dbo].[Real Estate$Apartments$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
(
	[Object No_],
	[Description],
	[Total Area (Project)],
	[Type]
)
SELECT
	[Object No_],
	[Descriotion],
	[Total Area (Project)],
	[Type]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NCC Real Estate$Apartments]