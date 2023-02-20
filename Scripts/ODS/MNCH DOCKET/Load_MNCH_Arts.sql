BEGIN
    --truncate table [ODS].[dbo].[MNCH_Arts]
	MERGE [ODS].[dbo].[MNCH_Arts] AS a
			USING(
					SELECT  P.[Id],P.[RefId],P.[Created],[PatientPk],P.[SiteCode],P.[Emr],[Project],[Processed],[QueueId],[Status],[StatusDate],[DateExtracted]
						  ,[Pkv],[PatientMnchID],[PatientHeiID],[FacilityName],[RegistrationAtCCC],[StartARTDate],[StartRegimen]
						  ,[StartRegimenLine],[StatusAtCCC],[LastARTDate],[LastRegimen],[LastRegimenLine],[Date_Created],[Date_Last_Modified]
					      
					  FROM [MNCHCentral].[dbo].[MnchArts] P(NoLock) 
					    INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id ) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID  = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,PatientMnchID,PatientHeiID,FacilityName,RegistrationAtCCC,StartARTDate,StartRegimen,StartRegimenLine,StatusAtCCC,LastARTDate,LastRegimen,LastRegimenLine,Date_Created,Date_Last_Modified) 
						VALUES(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,PatientMnchID,PatientHeiID,FacilityName,RegistrationAtCCC,StartARTDate,StartRegimen,StartRegimenLine,StatusAtCCC,LastARTDate,LastRegimen,LastRegimenLine,Date_Created,Date_Last_Modified)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.[Status]	 =b.[Status];
END



