BEGIN
    --truncate table [ODS].[dbo].[MNCH_MotherBabyPairs]
	MERGE [ODS].[dbo].[MNCH_MotherBabyPairs] AS a
			USING(
					SELECT P.ID,[PatientIDCCC],[PatientPk],[BabyPatientPK],[MotherPatientPK],[BabyPatientMncHeiID],[MotherPatientMncHeiID]
						  ,P.[SiteCode],F.Name FacilityName,P.[EMR],[Project],cast([DateExtracted] as date)[DateExtracted],[Date_Created]
						  ,[Date_Last_Modified]
					  FROM [MNCHCentral].[dbo].[MotherBabyPairs]P
					  INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID COLLATE SQL_Latin1_General_CP1_CI_AS = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(ID,PatientIDCCC,PatientPk,BabyPatientPK,MotherPatientPK,BabyPatientMncHeiID,MotherPatientMncHeiID,SiteCode,FacilityName,EMR,Project,DateExtracted,Date_Created,Date_Last_Modified) 
						VALUES(ID,PatientIDCCC,PatientPk,BabyPatientPK,MotherPatientPK,BabyPatientMncHeiID,MotherPatientMncHeiID,SiteCode,FacilityName,EMR,Project,DateExtracted,Date_Created,Date_Last_Modified)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.FacilityName	 =b.FacilityName;
END
