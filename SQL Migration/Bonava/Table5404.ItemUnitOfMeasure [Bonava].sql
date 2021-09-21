-- Item Unit of Measure

delete from [dbo].[Bonava$Item Unit of Measure$437dbf0e-84ff-417a-965d-ed2bb9650972];
insert into [dbo].[Bonava$Item Unit of Measure$437dbf0e-84ff-417a-965d-ed2bb9650972]
(
[Item No_]
      ,[Code]
      ,[Qty_ per Unit of Measure]
      ,[Length]
      ,[Width]
      ,[Height]
      ,[Cubage]
      ,[Weight]
)
select [Item No_]
      ,[Code]
      ,[Qty_ per Unit of Measure]
      ,[Length]
      ,[Width]
      ,[Height]
      ,[Cubage]
      ,[Weight]
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Item Unit of Measure];