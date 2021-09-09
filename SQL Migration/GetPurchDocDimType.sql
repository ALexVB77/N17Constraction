select distinct [Dimension Code] from [NCC Construction$Document Dimension]
where [Table ID] in (38,39)
union
select distinct [Dimension Code] from [NCC Real Estate$Document Dimension]
where [Table ID] in (38,39)