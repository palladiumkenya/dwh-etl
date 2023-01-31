BEGIN
--truncate table [ODS].[dbo].[PrEP_AdverseEvent]
MERGE [ODS].[dbo].[PrEP_AdverseEvent] AS a
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
      ,[AdverseEvent]
      ,[AdverseEventStartDate]
      ,[AdverseEventEndDate]
      ,[Severity]
      ,[VisitDate]
      ,[AdverseEventActionTaken]
      ,[AdverseEventClinicalOutcome]
      ,[AdverseEventIsPregnant]
      ,[AdverseEventCause]
      ,[AdverseEventRegimen]
      ,a.[Date_Created]
      ,a.[Date_Last_Modified]
	  ,a.SiteCode +'-'+ a.PatientPK AS CKV
  FROM [PREPCentral].[dbo].[PrepAdverseEvents](NoLock) a
       INNER JOIN 
           [PREPCentral].[dbo].[PrepPatients](NoLock) b
	         on 		 
		    a.SiteCode = b.SiteCode 
			and a.PatientPk =  b.PatientPk
			)
			AS b 
	 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK						
						and a.SiteCode = b.SiteCode
						) 
 


WHEN NOT MATCHED THEN 

		  INSERT( Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,
		  FacilityId,FacilityName,PrepNumber,AdverseEvent,AdverseEventStartDate,AdverseEventEndDate,Severity,VisitDate,
		  AdverseEventActionTaken,AdverseEventClinicalOutcome,AdverseEventIsPregnant,AdverseEventCause,
		  AdverseEventRegimen,Date_Created,Date_Last_Modified,CKV) 

		  VALUES(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,FacilityId,
		  FacilityName,PrepNumber,AdverseEvent,AdverseEventStartDate,AdverseEventEndDate,Severity,VisitDate,
		  AdverseEventActionTaken,AdverseEventClinicalOutcome,AdverseEventIsPregnant,AdverseEventCause,AdverseEventRegimen,
		  Date_Created,Date_Last_Modified,CKV) 

WHEN MATCHED THEN UPDATE SET 
							
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
				a.AdverseEvent					=b.AdverseEvent,
				a.AdverseEventStartDate			=b.AdverseEventStartDate,
				a.AdverseEventEndDate			=b.AdverseEventEndDate,
				a.Severity						=b.Severity,
				a.AdverseEventCause				=b.AdverseEventCause,
				a.AdverseEventRegimen			=b.AdverseEventRegimen,
				a.AdverseEventActionTaken		=b.AdverseEventActionTaken,
				a.AdverseEventClinicalOutcome	=b.AdverseEventClinicalOutcome,
				a.AdverseEventIsPregnant		=b.AdverseEventIsPregnant,
				a.Date_Created                  =b.Date_Created,
				a.Date_Last_Modified            =b.Date_Last_Modified;			
						


END

					