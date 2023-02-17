BEGIN
    --truncate table [ODS].[dbo].[MNCH_MotherBabyPairs]
	MERGE [ODS].[dbo].[MNCH_MotherBabyPairs] AS a
			USING(
					SELECT P.ID,[PatientIDCCC],[PatientPk],[BabyPatientPK],[MotherPatientPK],[BabyPatientMncHeiID],[MotherPatientMncHeiID]
						  ,P.[SiteCode],F.Name FacilityName,P.[EMR],[Project],cast([DateExtracted] as date)[DateExtracted],[Date_Created]
						  ,[Date_Last_Modified],
					  convert(nvarchar(64), hashbytes('SHA2_256', cast(p.[PatientPk]  as nvarchar(36))), 2) PatientPKHash,  
					  convert(nvarchar(64), hashbytes('SHA2_256', cast(BabyPatientPK  as nvarchar(36))), 2)BabyPatientPKHash,
					    convert(nvarchar(64), hashbytes('SHA2_256', cast(MotherPatientPK  as nvarchar(36))), 2)MotherPatientPKHash,
						 convert(nvarchar(64), hashbytes('SHA2_256', cast(MotherPatientMncHeiID  as nvarchar(36))), 2)MotherPatientMncHeiIDHash,
						 convert(nvarchar(64), hashbytes('SHA2_256', cast(LTRIM(RTRIM(P.SiteCode))+'-'+LTRIM(RTRIM(p.PatientPk))   as nvarchar(36))), 2)CKVHash
					  FROM [MNCHCentral].[dbo].[MotherBabyPairs]P
					  INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID COLLATE SQL_Latin1_General_CP1_CI_AS = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(ID,PatientIDCCC,PatientPk,BabyPatientPK,MotherPatientPK,BabyPatientMncHeiID,MotherPatientMncHeiID,SiteCode,FacilityName,EMR,Project,DateExtracted,Date_Created,Date_Last_Modified ,PatientPKHash,BabyPatientPKHash,MotherPatientPKHash,MotherPatientMncHeiIDHash,CKVHash) 
						VALUES(ID,PatientIDCCC,PatientPk,BabyPatientPK,MotherPatientPK,BabyPatientMncHeiID,MotherPatientMncHeiID,SiteCode,FacilityName,EMR,Project,DateExtracted,Date_Created,Date_Last_Modified ,PatientPKHash,BabyPatientPKHash,MotherPatientPKHash,MotherPatientMncHeiIDHash,CKVHash)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.FacilityName	 =b.FacilityName;
END

