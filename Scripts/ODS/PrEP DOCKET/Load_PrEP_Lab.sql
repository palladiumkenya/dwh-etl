BEGIN
--truncate table [ODS].[dbo].[PrEP_Lab]
MERGE [ODS].[dbo].[PrEP_Lab] AS a
	USING(SELECT	
	           a.ID
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
		INNER JOIN  [PREPCentral].[dbo].[PrepPatients](NoLock) b	
		ON a.sitecode = b.sitecode
		and a.patientPK = b.patientPK
		and a.[PrepNumber] = b.[PrepNumber]
		)AS b 	 
			ON(
			--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
				a.PatientPK  = b.PatientPK						
			and a.SiteCode = b.SiteCode
			and a.PrepNumber COLLATE SQL_Latin1_General_CP1_CI_AS= b.PrepNumber
			and a.ID = b.ID
			) 
	 WHEN NOT MATCHED THEN 
		  INSERT(ID,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,FacilityName,PrepNumber,HtsNumber
				,VisitID,TestName,TestResult,SampleDate,TestResultDate,Reason,Date_Created,Date_Last_Modified,CKV) 
		  VALUES(ID,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,FacilityName,PrepNumber,HtsNumber,
				  VisitID,TestName,TestResult,SampleDate,TestResultDate,Reason,Date_Created,Date_Last_Modified,CKV) 
	  WHEN MATCHED THEN
				UPDATE SET 							
					a.Created = b.Created,				 						
					a.Project=b.Project,
					a.Status=b.Status,
					a.StatusDate=b.StatusDate,					
					a.TestName=b.TestName,
					a.TestResult=b.TestResult,
					a.SampleDate=b.SampleDate,
					a.TestResultDate=b.TestResultDate,
					a.Reason=b.Reason,
					a.Date_Created=b.Date_Created,
					a.Date_Last_Modified=b.Date_Last_Modified,
					a.EMR =b.EMR;						

	END

					