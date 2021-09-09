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
	FROM [NAV_Test].dbo.[NCC Construction$Purchase Header] PH  
	INNER JOIN [NAV_Test].dbo.[NCC Construction$Purchase Header Additional] PHA
		ON PHA.[Document Type] = PH.[Document Type] and PHA.[No_] = PH.[No_]
	WHERE PH.[Document Type] = 1 and PH.[Act Type] <> 0 --and PH.[Problem Document] = 0 and PHA.[Status App Act] between 2 and 5 and PH.Archival = 0




DROP TABLE #PivotDimDoc
DROP TABLE #DocList 