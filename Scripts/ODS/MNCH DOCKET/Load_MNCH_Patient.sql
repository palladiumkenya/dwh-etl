
BEGIN
    --truncate table [ODS].[dbo].[MNCH_Patient]
	MERGE [ODS].[dbo].[MNCH_Patient] AS a
			USING(
					SELECT P.[Id],P.[RefId],P.[Created],[PatientPk],P.[SiteCode],P.[Emr],[Project],[Processed],[QueueId],[Status],[StatusDate],[DateExtracted]
						  ,[FacilityId],[FacilityName],[Pkv],[PatientMnchID],[PatientHeiID],[Gender],[DOB],[FirstEnrollmentAtMnch],[Occupation]
						  ,[MaritalStatus],[EducationLevel],[PatientResidentCounty],[PatientResidentSubCounty],[PatientResidentWard],[InSchool]
						  ,[Date_Created],[Date_Last_Modified],[NUPI],
					  convert(nvarchar(64), hashbytes('SHA2_256', cast(p.[PatientPk]  as nvarchar(36))), 2) PatientPKHash,
					  convert(nvarchar(64), hashbytes('SHA2_256', cast([PatientMnchID]  as nvarchar(36))), 2)PatientMnchIDHash
					  FROM [MNCHCentral].[dbo].[MnchPatients] P
					  INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID COLLATE SQL_Latin1_General_CP1_CI_AS = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityName,Pkv,PatientMnchID,PatientHeiID,Gender,DOB,FirstEnrollmentAtMnch,Occupation,MaritalStatus,EducationLevel,PatientResidentCounty,PatientResidentSubCounty,PatientResidentWard,InSchool,Date_Created,Date_Last_Modified,NUPI,PatientPKHash,PatientMnchIDHash) 
						VALUES(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityName,Pkv,PatientMnchID,PatientHeiID,Gender,DOB,FirstEnrollmentAtMnch,Occupation,MaritalStatus,EducationLevel,PatientResidentCounty,PatientResidentSubCounty,PatientResidentWard,InSchool,Date_Created,Date_Last_Modified,NUPI,PatientPKHash,PatientMnchIDHash)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.[Status]	 =b.[Status];
END

