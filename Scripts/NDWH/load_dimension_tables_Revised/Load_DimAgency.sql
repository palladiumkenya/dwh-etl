MERGE [NDWH].[dbo].[DimAgency] AS a
	USING(SELECT DISTINCT [SDP Agency] as Agency 
		  FROM [ODS].[dbo].[ALL_EMRSites] WHERE [SDP Agency] <>'NULL' OR [SDP Agency] IS NOT NULL  OR [SDP Agency]<>''
		 ) AS b 
	ON(a.AgencyName =b.Agency)
	WHEN NOT MATCHED THEN 
		INSERT(AgencyName) VALUES(Agency)
	  WHEN MATCHED THEN
		UPDATE SET 
			a.AgencyName = B.Agency
	  		
	WHEN NOT MATCHED BY SOURCE 
		THEN
		/* The Record is in the target table but doen't exit on the source table*/
		Delete;
		
	UPDATE [NDWH].[dbo].[DimAgency]
	SET AgencyName = UPPER(AgencyName);