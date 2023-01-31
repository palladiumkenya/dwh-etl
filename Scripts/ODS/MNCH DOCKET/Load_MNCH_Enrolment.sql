BEGIN
    --truncate table [ODS].[dbo].[MNCH_Enrolment]
	MERGE [ODS].[dbo].[MNCH_Enrolment] AS a
			USING(
					SELECT  [Id],[RefId],[Created],[PatientPk],[SiteCode],[Emr],[Project],[Processed],[QueueId],[Status],[StatusDate],[DateExtracted]
						  ,[FacilityId],[PatientMnchID],[FacilityName],[ServiceType],[EnrollmentDateAtMnch],[MnchNumber],[FirstVisitAnc],[Parity]
						  ,[Gravidae],[LMP],[EDDFromLMP],[HIVStatusBeforeANC],[HIVTestDate],[PartnerHIVStatus],[PartnerHIVTestDate],[BloodGroup]
						  ,[StatusAtMnch],[Date_Created],[Date_Last_Modified]
					 FROM [MNCHCentral].[dbo].[MnchEnrolments] ) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID COLLATE SQL_Latin1_General_CP1_CI_AS = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,PatientMnchID,FacilityName,ServiceType,EnrollmentDateAtMnch,MnchNumber,FirstVisitAnc,Parity,Gravidae,LMP,EDDFromLMP,HIVStatusBeforeANC,HIVTestDate,PartnerHIVStatus,PartnerHIVTestDate,BloodGroup,StatusAtMnch,Date_Created,Date_Last_Modified) 
						VALUES(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,PatientMnchID,FacilityName,ServiceType,EnrollmentDateAtMnch,MnchNumber,FirstVisitAnc,Parity,Gravidae,LMP,EDDFromLMP,HIVStatusBeforeANC,HIVTestDate,PartnerHIVStatus,PartnerHIVTestDate,BloodGroup,StatusAtMnch,Date_Created,Date_Last_Modified)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.[Status]	 =b.[Status];
END