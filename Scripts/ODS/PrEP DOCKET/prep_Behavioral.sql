BEGIN
--truncate table [ODS].[dbo].[PrEP_BehaviourRisk]
MERGE [ODS].[dbo].[PrEP_BehaviourRisk] AS a
	USING(SELECT distinct
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
      ,[VisitDate]
      ,[VisitID]
      ,[SexPartnerHIVStatus]
      ,[IsHIVPositivePartnerCurrentonART]
      ,[IsPartnerHighrisk]
      ,[PartnerARTRisk]
      ,[ClientAssessments]
      ,[ClientRisk]
      ,[ClientWillingToTakePrep]
      ,[PrEPDeclineReason]
      ,[RiskReductionEducationOffered]
      ,[ReferralToOtherPrevServices]
      ,[FirstEstablishPartnerStatus]
      ,[PartnerEnrolledtoCCC]
      ,[HIVPartnerCCCnumber]
      ,[HIVPartnerARTStartDate]
      ,[MonthsknownHIVSerodiscordant]
      ,[SexWithoutCondom]
      ,[NumberofchildrenWithPartner]
      ,a.[Date_Created]
      ,a.[Date_Last_Modified]
	  ,a.SiteCode +'-'+ a.PatientPK AS CKV
  FROM [PREPCentral].[dbo].[PrepBehaviourRisks](NoLock)a

  inner join    [PREPCentral].[dbo].[PrepPatients](NoLock) b

on a.SiteCode = b.SiteCode and a.PatientPk =  b.PatientPk
)
AS b    			ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK						
						and a.SiteCode = b.SiteCode
						) 


	 WHEN NOT MATCHED THEN 
		  INSERT(RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,FacilityName,PrepNumber,HtsNumber
		  ,VisitDate,VisitID,SexPartnerHIVStatus,IsHIVPositivePartnerCurrentonART,IsPartnerHighrisk,
		  PartnerARTRisk,ClientAssessments,ClientRisk,ClientWillingToTakePrep,PrEPDeclineReason,
		  RiskReductionEducationOffered,ReferralToOtherPrevServices,FirstEstablishPartnerStatus,PartnerEnrolledtoCCC,HIVPartnerCCCnumber,
		  HIVPartnerARTStartDate,MonthsknownHIVSerodiscordant,SexWithoutCondom,NumberofchildrenWithPartner,Date_Created,Date_Last_Modified,CKV)
		  

		  VALUES(RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,FacilityName,PrepNumber,HtsNumber,
          VisitDate,VisitID,SexPartnerHIVStatus,IsHIVPositivePartnerCurrentonART,IsPartnerHighrisk,
		  PartnerARTRisk,ClientAssessments,ClientRisk,ClientWillingToTakePrep,PrEPDeclineReason,
		  RiskReductionEducationOffered,ReferralToOtherPrevServices,FirstEstablishPartnerStatus,PartnerEnrolledtoCCC,HIVPartnerCCCnumber,
		  HIVPartnerARTStartDate,MonthsknownHIVSerodiscordant,SexWithoutCondom,NumberofchildrenWithPartner,Date_Created,Date_Last_Modified,CKV) 

	  WHEN MATCHED THEN
						UPDATE SET 
							a.IsPartnerHighrisk=b.IsPartnerHighrisk,
							a.PartnerARTRisk=b.PartnerARTRisk,
							a.ClientAssessments=b.ClientRisk,
							a.ClientRisk=b.ClientRisk,
							a.ClientWillingToTakePrep=b.ClientWillingToTakePrep,
							a.PrEPDeclineReason=b.PrEPDeclineReason,
							a.RiskReductionEducationOffered=b.RiskReductionEducationOffered,
							a.ReferralToOtherPrevServices=b.ReferralToOtherPrevServices,
							a.FirstEstablishPartnerStatus=b.FirstEstablishPartnerStatus,
							a.PartnerEnrolledtoCCC=b.PartnerEnrolledtoCCC,
							a.HIVPartnerCCCnumber=b.HIVPartnerCCCnumber,
							a.HIVPartnerARTStartDate=b.HIVPartnerARTStartDate,
							a.MonthsknownHIVSerodiscordant=b.MonthsknownHIVSerodiscordant,
							a.SexWithoutCondom=b.SexWithoutCondom,
							a.NumberofchildrenWithPartner=b.NumberofchildrenWithPartner,
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
							a.VisitDate=b.VisitDate,
							a.SexPartnerHIVStatus=b.SexPartnerHIVStatus,
						    a.VisitID = b.VisitID,
							a.IsHIVPositivePartnerCurrentonART=b.IsHIVPositivePartnerCurrentonART,
							a.Date_Created=b.Date_Created,							
							a.Date_Last_Modified=b.Date_Last_Modified,							
							a.EMR							=b.EMR;						
						
							
				

END

					