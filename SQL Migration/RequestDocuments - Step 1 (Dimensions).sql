SET NOCOUNT ON;

CREATE TABLE #DocList (
	[DocType] INT NOT NULL,  
	[DocNo] NVARCHAR(20) NOT NULL, 
	PRIMARY KEY CLUSTERED ([DocType] ASC, [DocNo] ASC) WITH (IGNORE_DUP_KEY = OFF))

CREATE TABLE #PivotDimDoc (
    [TableID] INT NOT NULL, 
	[DocType] INT NOT NULL, 
	[DocNo] NVARCHAR(20) NOT NULL,
	[DocLineNo] INT NOT NULL, 
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
	PRIMARY KEY CLUSTERED ([TableID] ASC, [DocType] ASC, [DocNo] ASC, [DocLineNo] ASC) WITH (IGNORE_DUP_KEY = OFF))

--

TRUNCATE TABLE #DocList 
TRUNCATE TABLE #PivotDimDoc

INSERT #DocList ([DocType],[DocNo])
	SELECT PH.[Document Type], PH.[No_]
	FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].dbo.[NCC Construction$Purchase Header] PH  
	INNER JOIN [VM-PRO-SQL007\NAV].[NAV_for_Developers].dbo.[NCC Construction$Purchase Header Additional] PHA
		ON PHA.[Document Type] = PH.[Document Type] and PHA.[No_] = PH.[No_]
	WHERE PH.[Document Type] = 1 and PH.[Act Type] <> 0 --and PH.[Problem Document] = 0 and PHA.[Status App Act] between 2 and 5 and PH.Archival = 0

DELETE FROM [VM-TST-SQL013].[Bonava-Test].dbo.[Bonava$ImportDimPivot$2944687f-9cf8-4134-a24c-e21fb70a8b1a] WHERE [TableID] IN (38,39) 
DELETE FROM [VM-TST-SQL013].[Bonava-Test].dbo.[Bonava$ImportDimDocPivot$2944687f-9cf8-4134-a24c-e21fb70a8b1a] WHERE [TableID] IN (38,39) 


INSERT [VM-TST-SQL013].[Bonava-Test].dbo.[Bonava$ImportDimPivot$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
	(TableID,Dim1Code,Dim2Code,Dim3Code,Dim4Code,Dim5Code,Dim6Code,Dim7Code,Dim8Code,Dim9Code,Dim10Code)
	VALUES(38, 'ADDRESS','CC','CP','CT','демднй','хмфяерэ','мо','мс-бхд','мс-назейр','рпд') 
INSERT [VM-TST-SQL013].[Bonava-Test].dbo.[Bonava$ImportDimPivot$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
	(TableID,Dim1Code,Dim2Code,Dim3Code,Dim4Code,Dim5Code,Dim6Code,Dim7Code,Dim8Code,Dim9Code,Dim10Code)
	VALUES(39, 'ADDRESS','CC','CP','CT','демднй','хмфяерэ','мо','мс-бхд','мс-назейр','рпд')

;WITH PivotDimDoc AS (
	SELECT [Table ID],[Document Type],[Document No_],[Line No_],[ADDRESS],[CC],[CP],[CT],[демднй],[хмфяерэ],[мо],[мс-бхд],[мс-назейр],[рпд] FROM (
		SELECT DD.[Table ID], DD.[Dimension Value Code], DD.[Dimension Code], DD.[Document Type], DD.[Document No_], DD.[Line No_]
		FROM [VM-PRO-SQL007\NAV].[NAV_for_Developers].dbo.[NCC Construction$Document Dimension] DD
		INNER JOIN #DocList DL ON DD.[Table ID] in (38,39) AND DD.[Document Type] = DL.DocType AND DD.[Document No_] = DL.DocNo COLLATE Cyrillic_General_CI_AS) SRC
	PIVOT (
		MIN([Dimension Value Code]) FOR [Dimension Code] IN ([ADDRESS],[CC],[CP],[CT],[демднй],[хмфяерэ],[мо],[мс-бхд],[мс-назейр],[рпд])) AS PVT)
INSERT #PivotDimDoc
	(TableID,DocType,DocNo,DocLineNo,SQLDimSetID,D1VC,D2VC,D3VC,D4VC,D5VC,D6VC,D7VC,D8VC,D9VC,D10VC)
	SELECT [Table ID],[Document Type],[Document No_],[Line No_],0,
		ISNULL([ADDRESS],''),ISNULL([CC],''),ISNULL([CP],''),ISNULL([CT],''),ISNULL([демднй],''),ISNULL([хмфяерэ],''),ISNULL([мо],''),ISNULL([мс-бхд],''),ISNULL([мс-назейр],''),ISNULL([рпд],'')
	FROM PivotDimDoc

CREATE NONCLUSTERED INDEX IX1 ON #PivotDimDoc (D1VC ASC,D2VC ASC,D3VC ASC,D4VC ASC,D5VC ASC,D6VC ASC,D7VC ASC,D8VC ASC,D9VC ASC,D10VC ASC) 

;WITH DimComb AS (
	SELECT ROW_NUMBER() OVER 
		(ORDER BY D1VC ASC,D2VC ASC,D3VC ASC,D4VC ASC,D5VC ASC,D6VC ASC,D7VC ASC,D8VC,D9VC,D10VC ASC) SQLDimSetID, D1VC,D2VC,D3VC,D4VC,D5VC,D6VC,D7VC,D8VC,D9VC,D10VC
	FROM (SELECT DISTINCT D1VC,D2VC,D3VC,D4VC,D5VC,D6VC,D7VC,D8VC,D9VC,D10VC FROM #PivotDimDoc) AS PS)
UPDATE PDE
	SET SQLDimSetID =
		(SELECT TOP 1 SQLDimSetID FROM DimComb DC WHERE 
			DC.D1VC = PDE.D1VC AND DC.D2VC = PDE.D2VC AND DC.D3VC = PDE.D3VC AND DC.D4VC = PDE.D4VC AND 
			DC.D5VC = PDE.D5VC AND DC.D6VC = PDE.D6VC AND DC.D7VC = PDE.D7VC AND DC.D8VC = PDE.D8VC)
	FROM #PivotDimDoc PDE

INSERT [VM-TST-SQL013].[Bonava-Test].dbo.[Bonava$ImportDimDocPivot$2944687f-9cf8-4134-a24c-e21fb70a8b1a]
	([TableID],[DocType],[DocNo],[DocLineNo],[SQLDimSetID],[NAVDimSetID],
		[Dim1ValueCode],[Dim2ValueCode],[Dim3ValueCode],[Dim4ValueCode],[Dim5ValueCode],[Dim6ValueCode],[Dim7ValueCode],[Dim8ValueCode],[Dim9ValueCode],[Dim10ValueCode])
SELECT TableID,DocType,DocNo,DocLineNo,SQLDimSetID,0,D1VC,D2VC,D3VC,D4VC,D5VC,D6VC,D7VC,D8VC,D9VC,D10VC FROM #PivotDimDoc

DROP INDEX IX1 ON #PivotDimDoc

DROP TABLE #PivotDimDoc
DROP TABLE #DocList 





select * from [VM-TST-SQL013].[Bonava-Test].dbo.[Bonava$ImportDimDocPivot$2944687f-9cf8-4134-a24c-e21fb70a8b1a]





