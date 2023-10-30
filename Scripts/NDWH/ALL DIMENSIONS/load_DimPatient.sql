MERGE [NDWH].[DBO].[DimPatient] AS a
    USING   (   SELECT DISTINCT   patients.PatientIDHash,
                        patients.PatientPKHash,
                        NULL AS HTSNumberHash,
                        NULL AS PrepNumber,
                        patients.PatientID,
                        patients.PatientPK,
                        patients.SiteCode,
		                NULL AS PrepEnrollmentDate,
                        Gender,
                        CAST(DOB AS DATE) AS DOB,
                        MaritalStatus,
                        NupiHash,
                        PatientType AS ClientType,
                        PatientSource,
                        baselines.eWHO AS EnrollmentWHOKey,
                        CAST(FORMAT(COALESCE(eWHODate, '1900-01-01'),'yyyyMMdd') AS INT) AS DateEnrollmentWHOKey,
                        bWHO AS BaseLineWHOKey,
                        CAST(FORMAT(COALESCE(bWHODate, '1900-01-01'),'yyyyMMdd') AS INT) AS DateBaselineWHOKey,
                        CASE 
                            WHEN outcomes.ARTOutcome =  'V' THEN 1
                            ELSE 0
                        END AS IsTXCurr,
                        CAST(GETDATE() AS DATE) AS LoadDate
                FROM ODS.dbo.CT_Patient AS patients
                    LEFT JOIN ODS.dbo.CT_PatientBaselines AS baselines 
			            ON  patients.PatientPKHash = baselines.PatientPKHash AND 
                            patients.SiteCode = baselines.SiteCode
                    LEFT JOIN ODS.dbo.Intermediate_ARTOutcomes AS outcomes 
			            ON  outcomes.PatientPKHash = patients.PatientPKHash AND 
                            outcomes.SiteCode = patients.SiteCode
                WHERE patients.VOIDED = 0

            UNION

		    SELECT  DISTINCT 
		                NULL AS PatientIDHash,
                        clients.PatientPKHash,
		                HTSNumberHash,
		                NULL AS PrepNumber,
                        NULL AS PatientID,
                        clients.PatientPK,
                        clients.SiteCode,
		                NULL AS PrepEnrollmentDate,
                        Gender,
                        CAST(DOB AS DATE) AS DOB,
                        MaritalStatus,
                        NupiHash,
                        NULL AS ClientType,
                        NULL AS PatientSource,
                        NULL AS EnrollmentWHOKey,
                        NULL AS DateEnrollmentWHOKey,
                        NULL AS BaseLineWHOKey,
                        NULL AS DateBaselineWHOKey,
                        NULL AS IsTXCurr,
                        NULL AS LoadDate
            FROM ODS.dbo.HTS_clients AS clients
            WHERE clients.VOIDED = 0

		    UNION

		    SELECT DISTINCT 
		                NULL AS PatientIDHash,
                        PrEP.PatientPKHash,
		                NULL AS HTSNumberHash,
		                PrEP.PrepNumber,
                        NULL AS PatientID,
                        PrEP.PatientPK,
                        PrEP.SiteCode,
		                PrEP.PrepEnrollmentDate,
                        PrEP.Sex,
                        CAST(DateofBirth AS DATE) AS DOB,
                        PrEP.MaritalStatus,
                        NULL AS NupiHash,
                        PrEP.ClientType AS ClientType,
                        NULL AS PatientSource,
                        NULL AS EnrollmentWHOKey,
                        NULL AS DateEnrollmentWHOKey,
                        NULL AS BaseLineWHOKey,
                        NULL AS DateBaselineWHOKey,
                        NULL AS IsTXCurr,
                        NULL AS LoadDate
            FROM ODS.dbo.PrEP_Patient PrEP 
            WHERE PrEP.VOIDED = 0
        ) AS b
		    ON (    
                a.siteCode = b.siteCode AND
			    a.PatientPKHash= b.PatientPKHash
                )
    WHEN NOT MATCHED THEN
                    INSERT(PatientIDHash,PatientPKHash,HtsNumberHash,PrepNumber,SiteCode,NUPI,DOB,MaritalStatus,Gender,ClientType,PatientSource,EnrollmentWHOKey,DateBaselineWHOKey,BaseLineWHOKey,/*PrepEnrollmentDateKey,*/IsTXCurr,LoadDate)
                    VALUES(PatientIDHash,PatientPKHash,HtsNumberHash,PrepNumber,SiteCode,NUPIHash,DOB,MaritalStatus,Gender,ClientType,PatientSource,EnrollmentWHOKey,DateBaselineWHOKey,BaseLineWHOKey,/*PrepEnrollmentDateKey,*/IsTXCurr,LoadDate)
    WHEN MATCHED THEN
	    UPDATE 
            SET a.MaritalStatus	= b.MaritalStatus,
				a.ClientType	= b.ClientType,
				a.PatientSource	= b.PatientSource;
