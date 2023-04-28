
BEGIN
    --truncate table [ODS].[dbo].[MNCH_Enrolments]
	MERGE [ODS].[dbo].[MNCH_Enrolments] AS a
			USING(
					SELECT distinct p.[PatientMnchID],p.[PatientPk],P.[SiteCode],p.[FacilityName],P.EMR,p.[Project],cast(p.[DateExtracted] as date)[DateExtracted]
						  ,[ServiceType],cast([EnrollmentDateAtMnch] as date) [EnrollmentDateAtMnch],[MnchNumber],[FirstVisitAnc],[Parity],[Gravidae]
						  ,[LMP],[EDDFromLMP],[HIVStatusBeforeANC],cast([HIVTestDate]as date)[HIVTestDate],[PartnerHIVStatus]
						  ,cast([PartnerHIVTestDate] as date)[PartnerHIVTestDate],[BloodGroup],[StatusAtMnch],p.[Date_Last_Modified]
					  FROM [MNCHCentral].[dbo].[MnchEnrolments]P (nolock)
					  inner join (select tn.PatientPK,tn.SiteCode,max(tn.DateExtracted)MaxDateExtracted FROM [MNCHCentral].[dbo].[MnchEnrolments] (NoLock)tn
						group by tn.PatientPK,tn.SiteCode)tm
						on P.PatientPk = tm.PatientPk and p.SiteCode = tm.SiteCode and p.DateExtracted = tm.MaxDateExtracted
					 --  INNER JOIN  [MNCHCentral].[dbo].[MnchPatients] MnchP(Nolock)  -- to be reviwed later
						--on P.patientPK = MnchP.patientPK and P.Sitecode = MnchP.Sitecode
					  INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
							)
					WHEN NOT MATCHED THEN 
						INSERT(PatientMnchID,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,ServiceType,EnrollmentDateAtMnch,MnchNumber,FirstVisitAnc,Parity,Gravidae,LMP,EDDFromLMP,HIVStatusBeforeANC,HIVTestDate,PartnerHIVStatus,PartnerHIVTestDate,BloodGroup,StatusAtMnch,Date_Last_Modified) 
						VALUES(PatientMnchID,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,ServiceType,EnrollmentDateAtMnch,MnchNumber,FirstVisitAnc,Parity,Gravidae,LMP,EDDFromLMP,HIVStatusBeforeANC,HIVTestDate,PartnerHIVStatus,PartnerHIVTestDate,BloodGroup,StatusAtMnch,Date_Last_Modified)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.ServiceType	 =b.ServiceType;

				with cte AS (
						Select
						Sitecode,
						PatientPK,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode ORDER BY
						PatientPK,Sitecode) Row_Num
						FROM  [ODS].[dbo].[MNCH_Enrolments] (NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;
END


