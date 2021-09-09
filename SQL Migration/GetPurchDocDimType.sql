;with PreSel AS (
	select distinct [Table ID],[Dimension Code] from [NCC Construction$Document Dimension]
	where [Table ID] in (38,39)
	union
	select distinct [Table ID],[Dimension Code] from [NCC Real Estate$Document Dimension]
	where [Table ID] in (38,39) )
select * from PreSel order by [Table ID],[Dimension Code]
