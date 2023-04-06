
BEGIN
    --truncate table [ODS].[dbo].[MNCH_PncVisits]
	MERGE [ODS].[dbo].[MNCH_PncVisits] AS a
			USING(
					SELECT distinct P.[PatientMnchID],P.[PatientPk],[PNCRegisterNumber],P.[SiteCode],P.[EMR],F.Name FacilityName,P.[Project]
						  ,cast(P.[DateExtracted] as date)[DateExtracted],p.[VisitID],cast(p.[VisitDate] as date)[VisitDate] ,[PNCVisitNo]
						  ,cast([DeliveryDate] as date)[DeliveryDate],[ModeOfDelivery],[PlaceOfDelivery],[Height],[Weight],[Temp]
						  ,[PulseRate],[RespiratoryRate],[OxygenSaturation],[MUAC],[BP],[BreastExam],[GeneralCondition],[HasPallor]
						  ,[Pallor],[Breast],[PPH],[CSScar],[UterusInvolution],[Episiotomy],[Lochia],[Fistula],[MaternalComplications]
						  ,[TBScreening],[ClientScreenedCACx],[CACxScreenMethod],[CACxScreenResults],[PriorHIVStatus],[HIVTestingDone]
						  ,[HIVTest1],[HIVTest1Result],[HIVTest2],[HIVTest2Result],[HIVTestFinalResult],[InfantProphylaxisGiven],[MotherProphylaxisGiven]
						  ,[CoupleCounselled],[PartnerHIVTestingPNC],[PartnerHIVResultPNC],[CounselledOnFP],[ReceivedFP],[HaematinicsGiven]
						  ,[DeliveryOutcome],[BabyConditon],[BabyFeeding],[UmbilicalCord],[Immunization],[InfantFeeding],[PreventiveServices]
						  ,[ReferredFrom],[ReferredTo],cast([NextAppointmentPNC] as date)[NextAppointmentPNC],[ClinicalNotes]
						  ,P.[Date_Last_Modified]

					  FROM [MNCHCentral].[dbo].[PncVisits] P (nolock)
					  inner join (select tn.PatientPK,tn.SiteCode,tn.visitID,tn.visitDate,max(tn.DateExtracted)MaxDateExtracted FROM [MNCHCentral].[dbo].[PncVisits] (NoLock)tn
						group by tn.PatientPK,tn.SiteCode,tn.visitID,tn.visitDate)tm
					on P.PatientPk = tm.PatientPk and p.SiteCode = tm.SiteCode
						 and P.VisitDate = tm.VisitDate 
						 and P.VisitID = tm.VisitID  and p.DateExtracted = tm.MaxDateExtracted
					   INNER JOIN  [MNCHCentral].[dbo].[MnchPatients] MnchP(Nolock)
							on P.patientPK = MnchP.patientPK and P.Sitecode = MnchP.Sitecode
					  INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id ) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.visitID = b.visitID
						and a.visitDate = b.visitDate
							)
					WHEN NOT MATCHED THEN 
						INSERT(PatientMnchID,PatientPk,PNCRegisterNumber,SiteCode,EMR,FacilityName,Project,DateExtracted,VisitID,VisitDate,PNCVisitNo,DeliveryDate,ModeOfDelivery,PlaceOfDelivery,Height,Weight,Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,BP,BreastExam,GeneralCondition,HasPallor,Pallor,Breast,PPH,CSScar,UterusInvolution,Episiotomy,Lochia,Fistula,MaternalComplications,TBScreening,ClientScreenedCACx,CACxScreenMethod,CACxScreenResults,PriorHIVStatus,HIVTestingDone,HIVTest1,HIVTest1Result,HIVTest2,HIVTest2Result,HIVTestFinalResult,InfantProphylaxisGiven,MotherProphylaxisGiven,CoupleCounselled,PartnerHIVTestingPNC,PartnerHIVResultPNC,CounselledOnFP,ReceivedFP,HaematinicsGiven,DeliveryOutcome,BabyConditon,BabyFeeding,UmbilicalCord,Immunization,InfantFeeding,PreventiveServices,ReferredFrom,ReferredTo,NextAppointmentPNC,ClinicalNotes,Date_Last_Modified) 
						VALUES(PatientMnchID,PatientPk,PNCRegisterNumber,SiteCode,EMR,FacilityName,Project,DateExtracted,VisitID,VisitDate,PNCVisitNo,DeliveryDate,ModeOfDelivery,PlaceOfDelivery,Height,Weight,Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,BP,BreastExam,GeneralCondition,HasPallor,Pallor,Breast,PPH,CSScar,UterusInvolution,Episiotomy,Lochia,Fistula,MaternalComplications,TBScreening,ClientScreenedCACx,CACxScreenMethod,CACxScreenResults,PriorHIVStatus,HIVTestingDone,HIVTest1,HIVTest1Result,HIVTest2,HIVTest2Result,HIVTestFinalResult,InfantProphylaxisGiven,MotherProphylaxisGiven,CoupleCounselled,PartnerHIVTestingPNC,PartnerHIVResultPNC,CounselledOnFP,ReceivedFP,HaematinicsGiven,DeliveryOutcome,BabyConditon,BabyFeeding,UmbilicalCord,Immunization,InfantFeeding,PreventiveServices,ReferredFrom,ReferredTo,NextAppointmentPNC,ClinicalNotes,Date_Last_Modified)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.ClinicalNotes	 =b.ClinicalNotes;
END
