BEGIN
    --truncate table [ODS].[dbo].[MNCH_Patient]
	MERGE [ODS].[dbo].[MNCH_Patient] AS a
			USING(
					SELECT [Id],[RefId],[Created],[PatientPk],[SiteCode],[Emr],[Project],[Processed],[QueueId],[Status],[StatusDate],[DateExtracted]
						  ,[FacilityId],[FacilityName],[Pkv],[PatientMnchID],[PatientHeiID],[Gender],[DOB],[FirstEnrollmentAtMnch],[Occupation]
						  ,[MaritalStatus],[EducationLevel],[PatientResidentCounty],[PatientResidentSubCounty],[PatientResidentWard],[InSchool]
						  ,[Date_Created],[Date_Last_Modified],[NUPI]
					  FROM [MNCHCentral].[dbo].[MnchPatients]) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID COLLATE SQL_Latin1_General_CP1_CI_AS = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityName,Pkv,PatientMnchID,PatientHeiID,Gender,DOB,FirstEnrollmentAtMnch,Occupation,MaritalStatus,EducationLevel,PatientResidentCounty,PatientResidentSubCounty,PatientResidentWard,InSchool,Date_Created,Date_Last_Modified,NUPI) 
						VALUES(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityName,Pkv,PatientMnchID,PatientHeiID,Gender,DOB,FirstEnrollmentAtMnch,Occupation,MaritalStatus,EducationLevel,PatientResidentCounty,PatientResidentSubCounty,PatientResidentWard,InSchool,Date_Created,Date_Last_Modified,NUPI)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.[Status]	 =b.[Status];
END