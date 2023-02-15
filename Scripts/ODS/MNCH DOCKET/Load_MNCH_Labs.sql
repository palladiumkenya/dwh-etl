
BEGIN
    --truncate table [ODS].[dbo].[MNCH_Labs]
	MERGE [ODS].[dbo].[MNCH_Labs] AS a
			USING(
					SELECT  P.[Id],P.[RefId],P.[Created],[PatientPk],P.[SiteCode],P.[Emr],[Project],[Processed],[QueueId],[Status],[StatusDate],[DateExtracted]
						  ,[PatientMNCH_ID],[FacilityName],[SatelliteName],[VisitID],[OrderedbyDate],[ReportedbyDate],[TestName],[TestResult]
						  ,[LabReason],[Date_Created],[Date_Last_Modified],
					  convert(nvarchar(64), hashbytes('SHA2_256', cast(p.[PatientPk]  as nvarchar(36))), 2) PatientPKHash,
					  convert(nvarchar(64), hashbytes('SHA2_256', cast([PatientMNCH_ID]  as nvarchar(36))), 2)PatientMnchIDHash,
					  convert(nvarchar(64), hashbytes('SHA2_256', cast(LTRIM(RTRIM(P.SiteCode))+'-'+LTRIM(RTRIM(PatientPk))   as nvarchar(36))), 2) CKVHash
					  FROM [MNCHCentral].[dbo].[MnchLabs] P(NoLock)
					    INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id ) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID COLLATE SQL_Latin1_General_CP1_CI_AS = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,PatientMNCH_ID,FacilityName,SatelliteName,VisitID,OrderedbyDate,ReportedbyDate,TestName,TestResult,LabReason,Date_Created,Date_Last_Modified,PatientPKHash,PatientMnchIDHash,CKVHash) 
						VALUES(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,PatientMNCH_ID,FacilityName,SatelliteName,VisitID,OrderedbyDate,ReportedbyDate,TestName,TestResult,LabReason,Date_Created,Date_Last_Modified,PatientPKHash,PatientMnchIDHash,CKVHash)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.[Status]	 =b.[Status];
END
