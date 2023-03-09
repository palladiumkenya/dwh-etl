
--begin tran
BEGIN
--truncate table [ODS].[dbo].[MNCH_AncVisits]
	MERGE [ODS].[dbo].[MNCH_AncVisits] AS a
		USING(
				SELECT  Distinct P.[PatientMnchID],[ANCClinicNumber], P.[PatientPk],F.[SiteCode], P.[FacilityName],P.[EMR], P.[Project],cast( P.[DateExtracted] as date)[DateExtracted]
					  ,[VisitID],cast([VisitDate] as date)[VisitDate],[ANCVisitNo],[GestationWeeks],[Height],[Weight],[Temp],[PulseRate],[RespiratoryRate]
					  ,[OxygenSaturation],[MUAC],[BP],[BreastExam],[AntenatalExercises],[FGM],[FGMComplications],[Haemoglobin],[DiabetesTest],[TBScreening]
					  ,[CACxScreen],[CACxScreenMethod],[WHOStaging],[VLSampleTaken],[VLDate],[VLResult],[SyphilisTreatment],[HIVStatusBeforeANC]
					  ,[HIVTestingDone],[HIVTestType],[HIVTest1],[HIVTest1Result],[HIVTest2],[HIVTest2Result],[HIVTestFinalResult],[SyphilisTestDone]
					  ,[SyphilisTestType],[SyphilisTestResults],[SyphilisTreated],[MotherProphylaxisGiven],[MotherGivenHAART],[AZTBabyDispense]
					  ,[NVPBabyDispense],[ChronicIllness],[CounselledOn],[PartnerHIVTestingANC],[PartnerHIVStatusANC],[PostParturmFP],[Deworming]
					  ,[MalariaProphylaxis],[TetanusDose],[IronSupplementsGiven],[ReceivedMosquitoNet],[PreventiveServices],[UrinalysisVariables]
					  ,[ReferredFrom],[ReferredTo],[ReferralReasons],cast([NextAppointmentANC] as date)[NextAppointmentANC]
					  ,[ClinicalNotes] , P.[Date_Created], P.[Date_Last_Modified]
				  FROM [MNCHCentral].[dbo].[AncVisits] (NoLock) P
					inner join (select tn.PatientPK,tn.SiteCode,max(tn.DateExtracted)MaxDateExtracted 
									FROM [MNCHCentral].[dbo].[AncVisits] (NoLock)tn
									group by tn.PatientPK,tn.SiteCode
								)tm
					on P.PatientPk = tm.PatientPk and p.SiteCode = tm.SiteCode and p.DateExtracted = tm.MaxDateExtracted
					INNER JOIN  [MNCHCentral].[dbo].[MnchPatients](NOLOCK)  Mnchp
					on P.PatientPK = Mnchp.patientPK and P.SiteCode = Mnchp.Sitecode
					INNER JOIN [MNCHCentral].[dbo].[Facilities](NoLock) F ON P.[FacilityId] = F.Id ) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.[PatientMnchID]  = b.[PatientMnchID]
						and a.[ANCClinicNumber]  = b.[ANCClinicNumber]
						and a.DateExtracted = b.DateExtracted
						and a.VisitID = b.VisitID
						and a.VisitDate = b.VisitDate  
						and a.ChronicIllness  = b.ChronicIllness

						)
					WHEN NOT MATCHED THEN 
						INSERT(PatientMnchID,ANCClinicNumber,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,VisitID,VisitDate,ANCVisitNo,GestationWeeks,Height,[Weight],Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,BP,BreastExam,AntenatalExercises,FGM,FGMComplications,Haemoglobin,DiabetesTest,TBScreening,CACxScreen,CACxScreenMethod,WHOStaging,VLSampleTaken,VLDate,VLResult,SyphilisTreatment,HIVStatusBeforeANC,HIVTestingDone,HIVTestType,HIVTest1,HIVTest1Result,HIVTest2,HIVTest2Result,HIVTestFinalResult,SyphilisTestDone,SyphilisTestType,SyphilisTestResults,SyphilisTreated,MotherProphylaxisGiven,MotherGivenHAART,AZTBabyDispense,NVPBabyDispense,ChronicIllness,CounselledOn,PartnerHIVTestingANC,PartnerHIVStatusANC,PostParturmFP,Deworming,MalariaProphylaxis,TetanusDose,IronSupplementsGiven,ReceivedMosquitoNet,PreventiveServices,UrinalysisVariables,ReferredFrom,ReferredTo,ReferralReasons,NextAppointmentANC,ClinicalNotes,Date_Created,Date_Last_Modified ) 
						VALUES(PatientMnchID,ANCClinicNumber,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,VisitID,VisitDate,ANCVisitNo,GestationWeeks,Height,[Weight],Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,BP,BreastExam,AntenatalExercises,FGM,FGMComplications,Haemoglobin,DiabetesTest,TBScreening,CACxScreen,CACxScreenMethod,WHOStaging,VLSampleTaken,VLDate,VLResult,SyphilisTreatment,HIVStatusBeforeANC,HIVTestingDone,HIVTestType,HIVTest1,HIVTest1Result,HIVTest2,HIVTest2Result,HIVTestFinalResult,SyphilisTestDone,SyphilisTestType,SyphilisTestResults,SyphilisTreated,MotherProphylaxisGiven,MotherGivenHAART,AZTBabyDispense,NVPBabyDispense,ChronicIllness,CounselledOn,PartnerHIVTestingANC,PartnerHIVStatusANC,PostParturmFP,Deworming,MalariaProphylaxis,TetanusDose,IronSupplementsGiven,ReceivedMosquitoNet,PreventiveServices,UrinalysisVariables,ReferredFrom,ReferredTo,ReferralReasons,NextAppointmentANC,ClinicalNotes,Date_Created,Date_Last_Modified )
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.SyphilisTreatment	 =b.SyphilisTreatment;
END


