DELETE FROM [Bonava-Test].[dbo].[Bonava$Item Charge$437dbf0e-84ff-417a-965d-ed2bb9650972];

--Item Charge
INSERT INTO [Bonava-Test].[dbo].[Bonava$Item Charge$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[No_],
	[Description],
	[Gen_ Prod_ Posting Group],
	[VAT Prod_ Posting Group],
	[Search Description],
	[Exclude Cost for TA]
)
SELECT
	[No_],
	[Description],
	[Gen_ Prod_ Posting Group],
	[VAT Prod_ Posting Group],
	[Search Description],
	[Exclude Cost for TA]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Item Charge];