DELETE FROM [Bonava-Test].[dbo].[CRM Company$2944687f-9cf8-4134-a24c-e21fb70a8b1a];

-- CRM Company
INSERT INTO [Bonava-Test].[dbo].[CRM Company$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
(
	[Project Guid],
	[Project Name],
	[Company Name]
)
SELECT
	[Project Guid],
	[Project Name],
	CASE WHEN [NCC Company] = 'NCC Real Estate' THEN 'Real Estate' ELSE [NCC Company] END AS [NCC Company]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[NavCRM Companies];