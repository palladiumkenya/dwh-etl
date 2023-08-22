MERGE [NDWH].[DBO].[DimPatient] AS a
USING(SELECT   DISTINCT
         patients.PatientIDHash,
         patients.PatientPKHash,
		 NULL HTSNumberHash,
		 NULL PrepNumber,
         patients.PatientID,
         patients.PatientPK,
         patients.SiteCode,
		 NULL PrepEnrollmentDate,
         Gender,
         CAST(DOB AS DATE) AS DOB,
         MaritalStatus,
         NupiHash,
         PatientType ClientType,
         PatientSource,
         baselines.eWHO AS EnrollmentWHOKey,
         CAST(FORMAT(COALESCE(eWHODate, '1900-01-01'),'yyyyMMdd') AS INT) AS DateEnrollmentWHOKey,
         bWHO as BaseLineWHOKey,
         CAST(FORMAT(COALESCE(bWHODate, '1900-01-01'),'yyyyMMdd') AS INT) AS DateBaselineWHOKey,
         CASE 
             WHEN outcomes.ARTOutcome =  'V' THEN 1
             ELSE 0
         END AS IsTXCurr,
         CAST(GETDATE() AS DATE) AS LoadDate
        FROM 
        ODS.dbo.CT_Patient AS patients
        LEFT JOIN ODS.dbo.CT_PatientBaselines AS baselines 
			ON patients.PatientPKHash = baselines.PatientPKHash AND patients.SiteCode = baselines.SiteCode
        LEFT JOIN ODS.dbo.Intermediate_ARTOutcomes AS outcomes 
			ON outcomes.PatientPKHash = patients.PatientPKHash AND outcomes.SiteCode = patients.SiteCode
		UNION
		SELECT DISTINCT 
		 NULL PatientIDHash,
         clients.PatientPKHash,
		 HTSNumberHash,
		 NULL PrepNumber,
         NULL PatientID,
         clients.PatientPK,
         clients.SiteCode,
		 NULL PrepEnrollmentDate,
         Gender,
         CAST(DOB AS DATE) AS DOB,
         MaritalStatus,
         NupiHash,
         NULL ClientType,
         NULL PatientSource,
         NULL EnrollmentWHOKey,
         NULL DateEnrollmentWHOKey,
         NULL BaseLineWHOKey,
         NULL DateBaselineWHOKey,
         NULL IsTXCurr,
         NULL LoadDate
        FROM ODS.dbo.HTS_clients AS clients
		UNION
		SELECT DISTINCT 
		 NULL PatientIDHash,
         PrEP.PatientPKHash,
		 NULL HTSNumberHash,
		 PrEP.PrepNumber,
         NULL PatientID,
         PrEP.PatientPK,
         PrEP.SiteCode,
		 PrEP.PrepEnrollmentDate,
         PrEP.Sex,
         CAST(DateofBirth AS DATE) AS DOB,
         PrEP.MaritalStatus,
         NULL NupiHash,
         PrEP.ClientType AS ClientType,
         NULL PatientSource,
         NULL EnrollmentWHOKey,
         NULL DateEnrollmentWHOKey,
         NULL BaseLineWHOKey,
         NULL DateBaselineWHOKey,
         NULL IsTXCurr,
         NULL LoadDate
        FROM ODS.dbo.PrEP_Patient PrEP ) AS b
		ON (a.siteCode = b.siteCode
			AND a.PatientPKHash= b.PatientPKHash)
WHEN NOT MATCHED THEN
	INSERT(PatientIDHash,PatientPKHash,HtsNumberHash,PrepNumber,SiteCode,NUPI,DOB,MaritalStatus,Gender,ClientType,PatientSource,EnrollmentWHOKey,DateBaselineWHOKey,BaseLineWHOKey,/*PrepEnrollmentDateKey,*/IsTXCurr,LoadDate)
	VALUES(PatientIDHash,PatientPKHash,HtsNumberHash,PrepNumber,SiteCode,NUPIHash,DOB,MaritalStatus,Gender,ClientType,PatientSource,EnrollmentWHOKey,DateBaselineWHOKey,BaseLineWHOKey,/*PrepEnrollmentDateKey,*/IsTXCurr,LoadDate)
WHEN MATCHED THEN
	UPDATE SET 
				a.MaritalStatus	= b.MaritalStatus,
				a.ClientType	= b.ClientType,
				a.PatientSource	= b.PatientSource;