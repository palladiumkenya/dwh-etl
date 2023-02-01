BEGIN
--truncate table [ODS].[dbo].[PrEP_CareTermination]
MERGE [ODS].[dbo].[PrEP_CareTermination] AS a
	USING(SELECT a.[Id]
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
				  ,[ExitDate]
				  ,[ExitReason]
				  ,[DateOfLastPrepDose]
				  ,a.[Date_Created]
				  ,a.[Date_Last_Modified]
				  ,a.SiteCode +'-'+ a.PatientPK AS CKV
			  FROM [PREPCentral].[dbo].[PrepCareTerminations](NoLock)a
			  inner join    [PREPCentral].[dbo].[PrepPatients](NoLock) b
				on a.SiteCode = b.SiteCode and a.PatientPk =  b.PatientPk 
			 INNER JOIN (SELECT PatientPk, SiteCode, max(Created) AS maxCreated from [PREPCentral].[dbo].[PrepCareTerminations]
						group by PatientPk,SiteCode) tn
				ON a.PatientPk = tn.PatientPk and a.SiteCode = tn.SiteCode and a.Created = tn.maxCreated

			INNER JOIN (SELECT PatientPk, SiteCode, max(DateExtracted) AS maxDateExtracted from [PREPCentral].[dbo].[PrepCareTerminations]
						group by PatientPk,SiteCode) tm
			ON a.PatientPk = tm.PatientPk and a.SiteCode = tm.SiteCode and a.DateExtracted = tm.maxDateExtracted)AS b 
	 
			ON(
				--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
					a.PatientPK  = b.PatientPK						
				and a.SiteCode = b.SiteCode
				) 

	 WHEN NOT MATCHED THEN 
		  INSERT(RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,FacilityName,PrepNumber,HtsNumber
		  ,ExitDate,ExitReason,DateOfLastPrepDose,Date_Created,Date_Last_Modified,CKV)
		  

		  VALUES(RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,FacilityName,PrepNumber,HtsNumber,
          ExitDate,ExitReason,DateOfLastPrepDose,Date_Created,Date_Last_Modified,CKV) 

	  WHEN MATCHED THEN
				UPDATE SET 														
							a.Status=b.Status,
							a.StatusDate=b.StatusDate,						
						    a.ExitDate=b.ExitDate,
							a.ExitReason=b.ExitReason,
							a.Date_Created=b.Date_Created,
							a.DateOfLastPrepDose=b.DateOfLastPrepDose,
							a.Date_Last_Modified=b.Date_Last_Modified,
							a.EMR=b.EMR;				
																			
	END

					