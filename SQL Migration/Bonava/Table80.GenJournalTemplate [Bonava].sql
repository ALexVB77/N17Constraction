-- Gen. Journal Template

DELETE FROM [Bonava-Test].[dbo].[Bonava$Gen_ Journal Template$437dbf0e-84ff-417a-965d-ed2bb9650972];
INSERT INTO [Bonava-Test].[dbo].[Bonava$Gen_ Journal Template$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
	[Name],
	[Description],
	[Test Report ID],
	[Page ID],
	[Posting Report ID],
	[Force Posting Report],
	[Type],
	[Source Code],
	[Reason Code],
	[Recurring],
	[Force Doc_ Balance],
	[Bal_ Account Type],
	[Bal_ Account No_],
	[No_ Series],
	[Posting No_ Series],
	[Copy VAT Setup to Jnl_ Lines],
	[Allow VAT Difference],
	[Cust_ Receipt Report ID],
	[Vendor Receipt Report ID],
	[Archive]
)
SELECT
	[Name],
	[Description],
	[Test Report ID],
	[Form ID],
	[Posting Report ID],
	[Force Posting Report],
	[Type],
	[Source Code],
	[Reason Code],
	[Recurring],
	[Force Doc_ Balance],
	[Bal_ Account Type],
	[Bal_ Account No_],
	[No_ Series],
	[Posting No_ Series],
	[Copy VAT Setup to Jnl_ Lines],
	[Allow VAT Difference],
	[Cust_ Receipt Report ID],
	[Vendor Receipt Report ID],
	[Archive]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Gen_ Journal Template];