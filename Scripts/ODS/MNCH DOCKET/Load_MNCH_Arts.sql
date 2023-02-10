
BEGIN
    --truncate table [ODS].[dbo].[MNCH_Arts]
	MERGE [ODS].[dbo].[MNCH_Arts] AS a
			USING(
					SELECT  P.[Id],P.[RefId],P.[Created],[PatientPk],P.[SiteCode],P.[Emr],[Project],[Processed],[QueueId],[Status],[StatusDate],[DateExtracted]
						  ,[Pkv],[PatientMnchID],[PatientHeiID],[FacilityName],[RegistrationAtCCC],[StartARTDate],[StartRegimen]
						  ,[StartRegimenLine],[StatusAtCCC],[LastARTDate],[LastRegimen],[LastRegimenLine],[Date_Created],[Date_Last_Modified]
					      ,[PatientPk]+'-'+P.[SiteCode] AS CKV,
					  convert(nvarchar(64), hashbytes('SHA2_256', cast(p.[PatientPk]  as nvarchar(36))), 2) PatientPKHash,
					  convert(nvarchar(64), hashbytes('SHA2_256', cast([PatientMnchID]  as nvarchar(36))), 2)PatientMnchIDHash,
					  convert(nvarchar(64), hashbytes('SHA2_256', cast(LTRIM(RTRIM(STR([PatientPk]))) + '-' + LTRIM(RTRIM(P.[SiteCode]))  as nvarchar(36))), 2) CKVHash

					  FROM [MNCHCentral].[dbo].[MnchArts] P(NoLock) 
					    INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id ) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID COLLATE SQL_Latin1_General_CP1_CI_AS = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,CKV,PatientMnchID,PatientHeiID,FacilityName,RegistrationAtCCC,StartARTDate,StartRegimen,StartRegimenLine,StatusAtCCC,LastARTDate,LastRegimen,LastRegimenLine,Date_Created,Date_Last_Modified,PatientPKHash,PatientMnchIDHash,CKVHash) 
						VALUES(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,CKV,PatientMnchID,PatientHeiID,FacilityName,RegistrationAtCCC,StartARTDate,StartRegimen,StartRegimenLine,StatusAtCCC,LastARTDate,LastRegimen,LastRegimenLine,Date_Created,Date_Last_Modified,PatientPKHash,PatientMnchIDHash,CKVHash)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.[Status]	 =b.[Status];
END




