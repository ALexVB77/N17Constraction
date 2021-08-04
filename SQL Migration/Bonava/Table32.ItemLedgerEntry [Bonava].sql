

select item,uom,loc,cp,cc,np,nuvid,nuobj,UnitCost,sum(qty) qty

from (

select [Item No_] item,[Unit of Measure Code] uom,lm.[New Location Code] loc,lednpm.[New Dimension Value Code] cp, ''''+ile.[Global Dimension 2 Code] cc,
isnull(ledNp.[Dimension Value Code],'') NP,
isnull(ledNuVid.[Dimension Value Code],'') NuVid,
isnull(ledNuObj.[Dimension Value Code],'') NuObj,
   [Remaining Quantity] qty,
   itm.[Unit Cost] UnitCost
FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Item Ledger Entry] ile
  left join [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Ledger Entry Dimension] ledNP
  on (ledNP.[Entry No_]=ile.[Entry No_]) and (ledNp.[Table Id]=32) and (ledNp.[Dimension Code]='мо')

  left join  [dbo].[Bonava$Dimension Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] ledNpm
  on (ledNpm.[Dimension Code]='CP' collate cyrillic_general_100_ci_as) and (lednpm.[Old Dimension Value Code]=ile.[Global Dimension 1 Code] collate cyrillic_general_100_ci_as)

  left join [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Ledger Entry Dimension] ledNuVid
  on (ledNuVid.[Entry No_]=ile.[Entry No_]) and (ledNuVid.[Table Id]=32) and (ledNuVid.[Dimension Code]='мс-бхд')

  left join [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Ledger Entry Dimension] ledNuObj
  on (ledNuObj.[Entry No_]=ile.[Entry No_]) and (ledNuObj.[Table Id]=32) and (ledNuObj.[Dimension Code]='мс-назейр')

  left join [VM-PRO-SQL007\NAV].[NAV_for_Developers].[dbo].[Bonava$Item] itm
  on (itm.[No_]=ile.[Item No_])
  
  join [dbo].[Bonava$Location Mapping$2944687f-9cf8-4134-a24c-e21fb70a8b1a] lm
  on lm.[Old Location Code]=ile.[Location Code] collate cyrillic_general_100_ci_as
Where (ile.[Open]=1)
) src
group by 
item,uom,loc,cp,cc,np,nuvid,nuobj,UnitCost