-- Unit of Measure

delete from [dbo].[Bonava$Unit of Measure$437dbf0e-84ff-417a-965d-ed2bb9650972];
insert into [dbo].[Bonava$Unit of Measure$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
		[Code]
      ,[Description]
      ,[International Standard Code]
      ,[Symbol]
      ,[Last Modified Date Time]
      ,[Id]
      ,[OKEI Code]

)
select 
		[Code]
      ,[Description]
      ,''--[International Standard Code]
      ,''--[Symbol]
      ,'1753-01-01 0:00:00.000'--[Last Modified Date Time]
      ,newid()--[Id]
      ,[OKEI Code]
  FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Unit of Measure];