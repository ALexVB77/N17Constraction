-- План счетов

delete from [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$IFRS Account$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
insert [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$IFRS Account$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
	([No_]
	,[Name]
	,[Account Type]
	,[Default Cost Place]
	,[Default Cost Code]
	,[Blocked]
	,[Indentation]
	,[Last Modified Date Time]
	,[Totaling])
select [No_]
      ,[Name]
      ,[Account Type]
      ,''
      ,''
      ,[Blocked]
      ,[Indentation]
      ,'1753-01-01'
      ,[Totaling]
from [VM-PRO-SQL007\NAV].[NAV_for_Developers].dbo.[Bonava (IFRS)$G_L Account]

-- Учетные периоды

delete from [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$IFRS Accounting Period$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
INSERT [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$IFRS Accounting Period$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
	([Starting Date]
	,[Name]
	,[Period Closed]
	,[Last Modified Date Time]
	,[Last Modified User ID])
select 
	 [Starting Date]
	,[Name]
	,case 
		when [Closed] = 1 then 1
		when [Date Locked] = 1 then 1
		else 0
	 end
	,'1753-01-01'
	,''
from [VM-PRO-SQL007\NAV].[NAV_for_Developers].dbo.[Bonava (IFRS)$Accounting Period]

-- Настройки мепиинга

delete from [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$IFRS Statutory Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
INSERT [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$IFRS Statutory Account Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
	([Code]
	,[Description]
	,[Creation Date])
select 
	[Code]
	,[Description]
	,[Creation Date]
from [VM-PRO-SQL007\NAV].[NAV_for_Developers].dbo.[Bonava (IFRS)$IFRS Statutory Account Mapping]

delete from [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$IFRS Stat_ Acc_ Map_ Vers_$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
INSERT [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$IFRS Stat_ Acc_ Map_ Vers_$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
    ([IFRS Stat_ Acc_ Mapping Code]
    ,[Code]
    ,[Comment]
	,[Version ID])
select 
	[IFRS Stat_ Acc_ Mapping Code]
	,[Code]
	,[Comment]
	,NEWID()
from [VM-PRO-SQL007\NAV].[NAV_for_Developers].dbo.[Bonava (IFRS)$IFRS Stat_ Acc_ Map_ Vers_]

delete from [dbo].[Bonava$IFRS Stat_ Acc_ Map_ Vers_Line$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
INSERT [dbo].[Bonava$IFRS Stat_ Acc_ Map_ Vers_Line$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
	([Version ID]
	,[Line No_]
	,[Stat_ Acc_ Account No_]
	,[Cost Place Code]
	,[Cost Code Code]
	,[IFRS Account No_]
	,[Rule ID])
select 
	NEW_VER.[Version ID]
	,0
	,''
	,''
	,''
	,''
	,NEWID()
from [VM-PRO-SQL007\NAV].[NAV_for_Developers].dbo.[Bonava (IFRS)$IFRS Stat_ Acc_ Map_ Vers_Line] OLD_VER_LINE
inner join [VM-TST-SQL013].[Bonava-Test].[dbo].[Bonava$IFRS Stat_ Acc_ Map_ Vers_$2944687f-9cf8-4134-a24c-e21fb70a8b1a] NEW_VER
	ON NEW_VER.[IFRS Stat_ Acc_ Mapping Code] = OLD_VER_LINE.[IFRS Stat_ Acc_ Mapping Code] collate Cyrillic_General_100_CI_AS
		and  NEW_VER.[Code] = OLD_VER_LINE.[Version Code] collate Cyrillic_General_100_CI_AS
	