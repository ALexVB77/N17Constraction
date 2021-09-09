SET NOCOUNT ON;

CREATE TABLE #DocList (
	[DocNo] NVARCHAR(20) NOT NULL, 
	PRIMARY KEY CLUSTERED ([DocNo] ASC) WITH (IGNORE_DUP_KEY = OFF))

CREATE TABLE #PivotDimDoc (
    [DocNo] NVARCHAR(20) NOT NULL,
	[D1VC] VARCHAR(20) COLLATE Cyrillic_General_100_CI_AS NOT NULL, 	
	[D2VC] VARCHAR(20) COLLATE Cyrillic_General_100_CI_AS NOT NULL, 	
	[D3VC] VARCHAR(20) COLLATE Cyrillic_General_100_CI_AS NOT NULL, 	
	[D4VC] VARCHAR(20) COLLATE Cyrillic_General_100_CI_AS NOT NULL, 	
	[D5VC] VARCHAR(20) COLLATE Cyrillic_General_100_CI_AS NOT NULL, 	
	[D6VC] VARCHAR(20) COLLATE Cyrillic_General_100_CI_AS NOT NULL, 	
	[D7VC] VARCHAR(20) COLLATE Cyrillic_General_100_CI_AS NOT NULL, 	
	[D8VC] VARCHAR(20) COLLATE Cyrillic_General_100_CI_AS NOT NULL, 	
	[D9VC] VARCHAR(20) COLLATE Cyrillic_General_100_CI_AS NOT NULL, 	
	[D10VC] VARCHAR(20) COLLATE Cyrillic_General_100_CI_AS NOT NULL, 
	[SQLDimSetID] INT NOT NULL,
	PRIMARY KEY CLUSTERED ([DocNo] ASC) WITH (IGNORE_DUP_KEY = OFF))

--

TRUNCATE TABLE #DocList 
TRUNCATE TABLE #PivotDimDoc

INSERT #DocList ([DocNo])
	SELECT PH.[No_]
	FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].dbo.[NCC Construction$Purchase Header] PH  
	INNER JOIN [VM-PRO-SQL007\NAV].[NAV_for_Developers].dbo.[NCC Construction$Purchase Header Additional] PHA
		ON PHA.[Document Type] = PH.[Document Type] and PHA.[No_] = PH.[No_]
	WHERE PH.[Document Type] = 1 and PH.[Act Type] <> 0 --and PH.[Problem Document] = 0 and PHA.[Status App Act] between 2 and 5 and PH.Archival = 0

DELETE FROM [VM-TST-SQL013].[Bonava-Test].dbo.[Bonava$ImportDimPivot$2944687f-9cf8-4134-a24c-e21fb70a8b1a] WHERE [TableID] IN (38,39) 
INSERT [VM-TST-SQL013].[Bonava-Test].dbo.[Bonava$ImportDimPivot$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
	(TableID,Dim1Code,Dim2Code,Dim3Code,Dim4Code,Dim5Code,Dim6Code,Dim7Code,Dim8Code,Dim9Code,Dim10Code)
	VALUES(38, 'CC','CP','CT','мо','мс-бхд','мс-назейр','рпд','','','') 
INSERT [VM-TST-SQL013].[Bonava-Test].dbo.[Bonava$ImportDimPivot$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
	(TableID,Dim1Code,Dim2Code,Dim3Code,Dim4Code,Dim5Code,Dim6Code,Dim7Code,Dim8Code,Dim9Code,Dim10Code)
	VALUES(39, 'ADDRESS','CC','CP','CT','демднй','хмфяерэ','мо','мс-бхд','мс-назейр','рпд')

;WITH PivotDimEntry AS (
	SELECT [Entry No_],[бхдш пюяунднб],[йнд онегдйх],[лемедфепш],[опнейр],[ярюрэъ гюрпюр],[жтн],[жтс],[чпкхжю] FROM (
		SELECT LED.[Dimension Value Code], LED.[Dimension Code], LED.[Entry No_] FROM [MSK10NAV65].[SimpleERPNAV2009].dbo.[' + @Company + '$Ledger Entry Dimension] LED	
		INNER JOIN #EntryListVend EL ON LED.[Table ID] = 25 AND LED.[Entry No_] = EL.EntryNo) SRC
	PIVOT (
		MIN([Dimension Value Code]) FOR [Dimension Code] IN ([бхдш пюяунднб],[йнд онегдйх],[лемедфепш],[опнейр],[ярюрэъ гюрпюр],[жтн],[жтс],[чпкхжю])) AS PVT)
INSERT #PivotDimEntryVend
	(EntryNo,SQLDimSetID,D1VC,D2VC,D3VC,D4VC,D5VC,D6VC,D7VC,D8VC,D9VC,D10VC)
SELECT [Entry No_],0,
	ISNULL([бхдш пюяунднб],''''),ISNULL([йнд онегдйх],''''),ISNULL([лемедфепш],''''),ISNULL([опнейр],''''),
	ISNULL([ярюрэъ гюрпюр],''''),ISNULL([жтн],''''),ISNULL([жтс],''''),ISNULL([чпкхжю],''''),'''',''''
FROM PivotDimEntry


DROP TABLE #PivotDimDoc
DROP TABLE #DocList 