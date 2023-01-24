MERGE [NDWH].[dbo].[DimPatient] AS a
	USING(SELECT DISTINCT patients.PatientID,patients.PatientPK,patients.SiteCode,Gender,DOB,MaritalStatus,Nupi,PatientType,PatientSource,eWHO,eWHODate,bWHO,bWHODate
				 FROM [ODS].[dbo].[CT_Patient] patients
				 left join ODS.dbo.CT_PatientBaselines as wabwhocd4 on patients.PatientPK = wabwhocd4.PatientPK
				 WHERE patients.SiteCode >0
				 
) AS b 
	ON( a.PatientPK collate SQL_Latin1_General_CP1_CI_AS= b.PatientPK  collate SQL_Latin1_General_CP1_CI_AS
	AND a.siteCode collate SQL_Latin1_General_CP1_CI_AS= b.SiteCode collate SQL_Latin1_General_CP1_CI_AS)
	--WHEN MATCHED THEN
 --   UPDATE SET 
 --   a.Gender = B.Gender 
	WHEN NOT MATCHED THEN 
	INSERT(PatientID,PatientPK,SiteCode,Gender,DOB,MaritalStatus,Nupi,PatientType,PatientSource/*,eWHO,eWHODate,bWHO,bWHODate*/) 
	VALUES(PatientID,PatientPK,SiteCode,Gender,DOB,MaritalStatus,Nupi,PatientType,PatientSource/*,eWHO,eWHODate,bWHO,bWHODate*/);

	--		WITH CTE AS   
	--		(  
	--			SELECT [PatientPK],[SiteCode],ROW_NUMBER() 
	--			OVER (PARTITION BY [PatientPK],[SiteCode]
	--			ORDER BY [PatientPK],[SiteCode]) AS dump_ 
	--			FROM [NDWH].[dbo].[DimPatient]
	--			)  
			
	--DELETE FROM CTE WHERE dump_ >1;