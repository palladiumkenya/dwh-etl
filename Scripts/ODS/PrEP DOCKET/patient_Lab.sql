BEGIN
--truncate table [ODS].[dbo].[PrEP_Lab]
MERGE [ODS].[dbo].[PrEP_Lab] AS a
	USING(SELECT  
	   a.[Id]
      ,a.[RefId]
      ,a.[Created]
      ,a.[PatientPk]
      ,a.[SiteCode]
      ,a.[Emr]
      ,a.[Project]
      ,a.[Processed]
      ,a.[QueueId]
      ,a.[Status]
      ,a.[StatusDate]
      ,a.[DateExtracted]
      ,a.[FacilityId]
      ,a.[FacilityName]
      ,a.[PrepNumber]
      ,a.[HtsNumber]
      ,[VisitID]
      ,[TestName]
      ,[TestResult]
      ,[SampleDate]
      ,[TestResultDate]
      ,[Reason]
      ,a.[Date_Created]
      ,a.[Date_Last_Modified]
	  ,a.SiteCode +'-'+ a.PatientPK AS CKV
FROM [PREPCentral].[dbo].[PrepLabs](NoLock) a
  inner join    [PREPCentral].[dbo].[PrepPatients](NoLock) b
on a.SiteCode = b.SiteCode and a.PatientPk =  b.PatientPk
)
AS b 
	 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK						
						and a.SiteCode = b.SiteCode
						) 


	 WHEN NOT MATCHED THEN 
		  INSERT(RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,FacilityName,PrepNumber,HtsNumber
		  ,VisitID,TestName,TestResult,SampleDate,TestResultDate,Reason,Date_Created,Date_Last_Modified,CKV) 
		  VALUES(RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,FacilityName,PrepNumber,HtsNumber,
           VisitID,TestName,TestResult,SampleDate,TestResultDate,Reason,Date_Created,Date_Last_Modified,CKV) 

	  WHEN MATCHED THEN
						UPDATE SET 
							
							a.RefId = b.RefId,
							a.Created = b.Created,				 
							a.SiteCode=b.SiteCode,						
							a.Project=b.Project,
							a.Processed=b.Processed,
							a.QueueId=b.QueueId,
							a.Status=b.Status,
							a.StatusDate=b.StatusDate,
							a.DateExtracted=b.DateExtracted,
							a.FacilityId=b.FacilityId,
							a.FacilityName=b.FacilityName,
							a.PrepNumber=b.PrepNumber,
							a.HtsNumber=b.HtsNumber,
							a.VisitID=b.VisitID,
							a.TestName=b.TestName,
							a.TestResult=b.TestResult,
							a.SampleDate=b.SampleDate,
							a.TestResultDate=b.TestResultDate,
							a.Reason=b.Reason,
							a.Date_Created=b.Date_Created,
							a.Date_Last_Modified=b.Date_Last_Modified,
							a.EMR							=b.EMR;						
						
							
							--WHEN NOT MATCHED BY SOURCE 
					--	THEN
					--	/* The Record is in the target table but doen't exit on the source table*/
				--	--		Delete;

				--UPDATE [ODS].[dbo].[CT_AdverseEvent_Log]
				--  SET LoadEndDateTime = GETDATE()
				--  WHERE MaxAdverseEventStartDate = @AdverseEventStartDate;

				----truncate table [ODS].[dbo].[CT_AdverseEventCount_Log]
				--INSERT INTO [ODS].[dbo].[CT_AdverseEventCount_Log]([SiteCode],[CreatedDate],[AdverseEventCount])
				--SELECT SiteCode,GETDATE(),COUNT(CKV) AS AdverseEventCount 
				--FROM [ODS].[dbo].[CT_AdverseEvents] 
				----WHERE @MaxCreatedDate  > @MaxCreatedDate
				--GROUP BY SiteCode;


							

					--DROP INDEX CT_AdverseEvents ON [ODS].[dbo].[CT_AdverseEvents];
					---Remove any duplicate from [ODS].[dbo].[CT_Patient]
			--	with cte AS (
			--	Select
			--	Patientpk,
			--	SiteCode
			--	,VisitDate,
			--	 ROW_NUMBER() OVER (PARTITION BY Patientpk,SiteCode,VisitDate ORDER BY
			--	Patientpk,SiteCode,VisitDate ) Row_Num
			--	FROM [ODS].[dbo].[CT_AdverseEvents]
			--	)
			--delete  from cte 
			--	Where Row_Num >1

	END

					