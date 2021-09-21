--CRM Integration Setup

DELETE FROM [Bonava-Test].[dbo].[Bonava$CRM Integration Setup$2944687f-9cf8-4134-a24c-e21fb70a8b1a];
INSERT INTO [Bonava-Test].[dbo].[Bonava$CRM Integration Setup$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
(
	[Primary Key],
	[Customer Posting Group],
	[Gen_ Bus_ Posting Group],
	[VAT Bus_ Posting Group]
)
SELECT
	[Primary Key],
	ISNULL(GLAccMapping.[New No_], '') AS [Customer Posting Group],
	[Gen_ Bus_ Posting Group],
	[VAT Bus_ Posting Group]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$NavCRM Setup]
LEFT JOIN [Bonava-Test].[dbo].[Bonava$G_L Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] GLAccMapping
ON GLAccMapping.[Old No_] = [Customer Posting Group] collate Cyrillic_General_100_CI_AS;