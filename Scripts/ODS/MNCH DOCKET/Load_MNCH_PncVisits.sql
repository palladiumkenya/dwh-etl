
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
						  ,[Date_Created],[Date_Last_Modified],
					  convert(nvarchar(64), hashbytes('SHA2_256', cast(p.[PatientPk]  as nvarchar(36))), 2) PatientPKHash,
					  convert(nvarchar(64), hashbytes('SHA2_256', cast([PatientMnchID]  as nvarchar(36))), 2)PatientMnchIDHash,
					  convert(nvarchar(64), hashbytes('SHA2_256', cast(LTRIM(RTRIM(P.SiteCode))+'-'+LTRIM(RTRIM(PatientPk))   as nvarchar(36))), 2)CKVHash
					  FROM [MNCHCentral].[dbo].[PncVisits]P
					  INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id ) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID COLLATE SQL_Latin1_General_CP1_CI_AS = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(ID,PatientMnchID,PatientPk,PNCRegisterNumber,SiteCode,EMR,FacilityName,Project,DateExtracted,VisitID,VisitDate,PNCVisitNo,DeliveryDate,ModeOfDelivery,PlaceOfDelivery,Height,Weight,Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,BP,BreastExam,GeneralCondition,HasPallor,Pallor,Breast,PPH,CSScar,UterusInvolution,Episiotomy,Lochia,Fistula,MaternalComplications,TBScreening,ClientScreenedCACx,CACxScreenMethod,CACxScreenResults,PriorHIVStatus,HIVTestingDone,HIVTest1,HIVTest1Result,HIVTest2,HIVTest2Result,HIVTestFinalResult,InfantProphylaxisGiven,MotherProphylaxisGiven,CoupleCounselled,PartnerHIVTestingPNC,PartnerHIVResultPNC,CounselledOnFP,ReceivedFP,HaematinicsGiven,DeliveryOutcome,BabyConditon,BabyFeeding,UmbilicalCord,Immunization,InfantFeeding,PreventiveServices,ReferredFrom,ReferredTo,NextAppointmentPNC,ClinicalNotes,Date_Created,Date_Last_Modified,PatientPKHash,PatientMnchIDHash,CKVHash) 
						VALUES(ID,PatientMnchID,PatientPk,PNCRegisterNumber,SiteCode,EMR,FacilityName,Project,DateExtracted,VisitID,VisitDate,PNCVisitNo,DeliveryDate,ModeOfDelivery,PlaceOfDelivery,Height,Weight,Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,BP,BreastExam,GeneralCondition,HasPallor,Pallor,Breast,PPH,CSScar,UterusInvolution,Episiotomy,Lochia,Fistula,MaternalComplications,TBScreening,ClientScreenedCACx,CACxScreenMethod,CACxScreenResults,PriorHIVStatus,HIVTestingDone,HIVTest1,HIVTest1Result,HIVTest2,HIVTest2Result,HIVTestFinalResult,InfantProphylaxisGiven,MotherProphylaxisGiven,CoupleCounselled,PartnerHIVTestingPNC,PartnerHIVResultPNC,CounselledOnFP,ReceivedFP,HaematinicsGiven,DeliveryOutcome,BabyConditon,BabyFeeding,UmbilicalCord,Immunization,InfantFeeding,PreventiveServices,ReferredFrom,ReferredTo,NextAppointmentPNC,ClinicalNotes,Date_Created,Date_Last_Modified,PatientPKHash,PatientMnchIDHash,CKVHash)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.ClinicalNotes	 =b.ClinicalNotes;
END
