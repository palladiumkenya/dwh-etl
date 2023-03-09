
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
				  
			FROM [PREPCentral].[dbo].[PrepAdverseEvents](NoLock) a
			inner join    [PREPCentral].[dbo].[PrepPatients](NoLock) b
		on a.SiteCode = b.SiteCode 
		and a.PatientPk =  b.PatientPk
		and a.[PrepNumber] = b.[PrepNumber]
		) AS b 	 
		ON(

			a.PatientPK  = b.PatientPK						
			and a.SiteCode = b.SiteCode
		)  
	WHEN NOT MATCHED THEN 

		  INSERT( Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,
		  FacilityId,FacilityName,PrepNumber,AdverseEvent,AdverseEventStartDate,AdverseEventEndDate,Severity,VisitDate,
		  AdverseEventActionTaken,AdverseEventClinicalOutcome,AdverseEventIsPregnant,AdverseEventCause,
		  AdverseEventRegimen,Date_Created,Date_Last_Modified) 

		  VALUES(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,FacilityId,
		  FacilityName,PrepNumber,AdverseEvent,AdverseEventStartDate,AdverseEventEndDate,Severity,VisitDate,
		  AdverseEventActionTaken,AdverseEventClinicalOutcome,AdverseEventIsPregnant,AdverseEventCause,AdverseEventRegimen,
		  Date_Created,Date_Last_Modified) 

	WHEN MATCHED THEN UPDATE SET 															 								
		a.AdverseEvent					=b.AdverseEvent,
		a.Severity						=b.Severity,
		a.AdverseEventCause				=b.AdverseEventCause,
		a.AdverseEventRegimen			=b.AdverseEventRegimen,
		a.AdverseEventActionTaken		=b.AdverseEventActionTaken,
		a.AdverseEventClinicalOutcome	=b.AdverseEventClinicalOutcome,
		a.AdverseEventIsPregnant		=b.AdverseEventIsPregnant,
		a.Date_Last_Modified            =b.Date_Last_Modified;			
						
END

					