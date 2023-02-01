BEGIN
    --truncate table [ODS].[dbo].[MNCH_Enrolments]
	MERGE [ODS].[dbo].[MNCH_Enrolments] AS a
			USING(
					SELECT P.ID,[PatientMnchID],[PatientPk],P.[SiteCode],[FacilityName],P.EMR,[Project],cast([DateExtracted] as date)[DateExtracted]
						  ,[ServiceType],cast([EnrollmentDateAtMnch] as date) [EnrollmentDateAtMnch],[MnchNumber],[FirstVisitAnc],[Parity],[Gravidae]
						  ,[LMP],[EDDFromLMP],[HIVStatusBeforeANC],cast([HIVTestDate]as date)[HIVTestDate],[PartnerHIVStatus]
						  ,cast([PartnerHIVTestDate] as date)[PartnerHIVTestDate],[BloodGroup],[StatusAtMnch],[Date_Created],[Date_Last_Modified]
					  FROM [MNCHCentral].[dbo].[MnchEnrolments]P
					  INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID COLLATE SQL_Latin1_General_CP1_CI_AS = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(ID,PatientMnchID,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,ServiceType,EnrollmentDateAtMnch,MnchNumber,FirstVisitAnc,Parity,Gravidae,LMP,EDDFromLMP,HIVStatusBeforeANC,HIVTestDate,PartnerHIVStatus,PartnerHIVTestDate,BloodGroup,StatusAtMnch,Date_Created,Date_Last_Modified) 
						VALUES(ID,PatientMnchID,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,ServiceType,EnrollmentDateAtMnch,MnchNumber,FirstVisitAnc,Parity,Gravidae,LMP,EDDFromLMP,HIVStatusBeforeANC,HIVTestDate,PartnerHIVStatus,PartnerHIVTestDate,BloodGroup,StatusAtMnch,Date_Created,Date_Last_Modified)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.ServiceType	 =b.ServiceType;
END