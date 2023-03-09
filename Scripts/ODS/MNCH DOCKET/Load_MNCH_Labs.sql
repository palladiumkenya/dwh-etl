
BEGIN
    --truncate table [ODS].[dbo].[MNCH_Labs]
	MERGE [ODS].[dbo].[MNCH_Labs] AS a
			USING(
					SELECT  distinct P.[PatientPk],P.[SiteCode],P.[Emr],P.[Project],P.[Processed],P.[QueueId],P.[Status],P.[StatusDate],P.[DateExtracted]
						  ,[PatientMNCH_ID],P.[FacilityName],[SatelliteName],[VisitID],[OrderedbyDate],[ReportedbyDate],[TestName],[TestResult]
						  ,[LabReason],P.[Date_Last_Modified]
					  FROM [MNCHCentral].[dbo].[MnchLabs] P(NoLock)
					  inner join (select tn.PatientPK,tn.SiteCode,max(tn.DateExtracted)MaxDateExtracted FROM [MNCHCentral].[dbo].[MnchLabs] (NoLock)tn
					group by tn.PatientPK,tn.SiteCode)tm
					on P.PatientPk = tm.PatientPk and p.SiteCode = tm.SiteCode and p.DateExtracted = tm.MaxDateExtracted
					   INNER JOIN  [MNCHCentral].[dbo].[MnchPatients] MnchP(Nolock)
						on P.patientPK = MnchP.patientPK and P.Sitecode = MnchP.Sitecode
					    INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id ) AS b 
						ON(

						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.[VisitID] = b.[VisitID]
						and a.[TestName] = b.[TestName]
						and a.[TestResult] = b.[TestResult]
	
							)
					WHEN NOT MATCHED THEN 
						INSERT(PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,PatientMNCH_ID,FacilityName,SatelliteName,VisitID,OrderedbyDate,ReportedbyDate,TestName,TestResult,LabReason,Date_Last_Modified) 
						VALUES(PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,PatientMNCH_ID,FacilityName,SatelliteName,VisitID,OrderedbyDate,ReportedbyDate,TestName,TestResult,LabReason,Date_Last_Modified)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.[Status]	 =b.[Status];
END
