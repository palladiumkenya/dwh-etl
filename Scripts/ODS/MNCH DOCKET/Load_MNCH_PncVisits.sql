
BEGIN
    --truncate table [ODS].[dbo].[MNCH_PncVisits]
	MERGE [ODS].[dbo].[MNCH_PncVisits] AS a
			USING(
					SELECT P.ID,[PatientMnchID],[PatientPk],[PNCRegisterNumber],P.[SiteCode],P.[EMR],F.Name FacilityName,[Project]
						  ,cast([DateExtracted] as date)[DateExtracted],[VisitID],cast([VisitDate] as date)[VisitDate] ,[PNCVisitNo]
						  ,cast([DeliveryDate] as date)[DeliveryDate],[ModeOfDelivery],[PlaceOfDelivery],[Height],[Weight],[Temp]
						  ,[PulseRate],[RespiratoryRate],[OxygenSaturation],[MUAC],[BP],[BreastExam],[GeneralCondition],[HasPallor]
						  ,[Pallor],[Breast],[PPH],[CSScar],[UterusInvolution],[Episiotomy],[Lochia],[Fistula],[MaternalComplications]
						  ,[TBScreening],[ClientScreenedCACx],[CACxScreenMethod],[CACxScreenResults],[PriorHIVStatus],[HIVTestingDone]
						  ,[HIVTest1],[HIVTest1Result],[HIVTest2],[HIVTest2Result],[HIVTestFinalResult],[InfantProphylaxisGiven],[MotherProphylaxisGiven]
						  ,[CoupleCounselled],[PartnerHIVTestingPNC],[PartnerHIVResultPNC],[CounselledOnFP],[ReceivedFP],[HaematinicsGiven]
						  ,[DeliveryOutcome],[BabyConditon],[BabyFeeding],[UmbilicalCord],[Immunization],[InfantFeeding],[PreventiveServices]
						  ,[ReferredFrom],[ReferredTo],cast([NextAppointmentPNC] as date)[NextAppointmentPNC],[ClinicalNotes]
						  ,[Date_Created],[Date_Last_Modified]

					  FROM [MNCHCentral].[dbo].[PncVisits]P
					  INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id ) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID  = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(ID,PatientMnchID,PatientPk,PNCRegisterNumber,SiteCode,EMR,FacilityName,Project,DateExtracted,VisitID,VisitDate,PNCVisitNo,DeliveryDate,ModeOfDelivery,PlaceOfDelivery,Height,Weight,Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,BP,BreastExam,GeneralCondition,HasPallor,Pallor,Breast,PPH,CSScar,UterusInvolution,Episiotomy,Lochia,Fistula,MaternalComplications,TBScreening,ClientScreenedCACx,CACxScreenMethod,CACxScreenResults,PriorHIVStatus,HIVTestingDone,HIVTest1,HIVTest1Result,HIVTest2,HIVTest2Result,HIVTestFinalResult,InfantProphylaxisGiven,MotherProphylaxisGiven,CoupleCounselled,PartnerHIVTestingPNC,PartnerHIVResultPNC,CounselledOnFP,ReceivedFP,HaematinicsGiven,DeliveryOutcome,BabyConditon,BabyFeeding,UmbilicalCord,Immunization,InfantFeeding,PreventiveServices,ReferredFrom,ReferredTo,NextAppointmentPNC,ClinicalNotes,Date_Created,Date_Last_Modified) 
						VALUES(ID,PatientMnchID,PatientPk,PNCRegisterNumber,SiteCode,EMR,FacilityName,Project,DateExtracted,VisitID,VisitDate,PNCVisitNo,DeliveryDate,ModeOfDelivery,PlaceOfDelivery,Height,Weight,Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,BP,BreastExam,GeneralCondition,HasPallor,Pallor,Breast,PPH,CSScar,UterusInvolution,Episiotomy,Lochia,Fistula,MaternalComplications,TBScreening,ClientScreenedCACx,CACxScreenMethod,CACxScreenResults,PriorHIVStatus,HIVTestingDone,HIVTest1,HIVTest1Result,HIVTest2,HIVTest2Result,HIVTestFinalResult,InfantProphylaxisGiven,MotherProphylaxisGiven,CoupleCounselled,PartnerHIVTestingPNC,PartnerHIVResultPNC,CounselledOnFP,ReceivedFP,HaematinicsGiven,DeliveryOutcome,BabyConditon,BabyFeeding,UmbilicalCord,Immunization,InfantFeeding,PreventiveServices,ReferredFrom,ReferredTo,NextAppointmentPNC,ClinicalNotes,Date_Created,Date_Last_Modified)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.ClinicalNotes	 =b.ClinicalNotes;
END
