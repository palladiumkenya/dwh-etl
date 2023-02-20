
BEGIN
    --truncate table [ODS].[dbo].[MNCH_Labs]
	MERGE [ODS].[dbo].[MNCH_Labs] AS a
			USING(
					SELECT  P.[Id],P.[RefId],P.[Created],[PatientPk],P.[SiteCode],P.[Emr],[Project],[Processed],[QueueId],[Status],[StatusDate],[DateExtracted]
						  ,[PatientMNCH_ID],[FacilityName],[SatelliteName],[VisitID],[OrderedbyDate],[ReportedbyDate],[TestName],[TestResult]
						  ,[LabReason],[Date_Created],[Date_Last_Modified]
					  FROM [MNCHCentral].[dbo].[MnchLabs] P(NoLock)
					    INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id ) AS b 
						ON(

						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID  = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,PatientMNCH_ID,FacilityName,SatelliteName,VisitID,OrderedbyDate,ReportedbyDate,TestName,TestResult,LabReason,Date_Created,Date_Last_Modified) 
						VALUES(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,PatientMNCH_ID,FacilityName,SatelliteName,VisitID,OrderedbyDate,ReportedbyDate,TestName,TestResult,LabReason,Date_Created,Date_Last_Modified)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.[Status]	 =b.[Status];
END
