
BEGIN
--truncate table [ODS].[dbo].[MNCH_AncVisits]
	MERGE [ODS].[dbo].[MNCH_AncVisits] AS a
		USING(
				SELECT  Distinct P.[PatientMnchID],[ANCClinicNumber], P.[PatientPk],F.[SiteCode], P.[FacilityName],P.[EMR], P.[Project]
					  ,[VisitID],cast(p.[VisitDate] as date)[VisitDate],[ANCVisitNo],[GestationWeeks],[Height],[Weight],[Temp],[PulseRate],[RespiratoryRate]
					  ,[OxygenSaturation],[MUAC],[BP],[BreastExam],[AntenatalExercises],[FGM],[FGMComplications],[Haemoglobin],[DiabetesTest],[TBScreening]
					  ,[CACxScreen],[CACxScreenMethod],[WHOStaging],[VLSampleTaken],[VLDate],[VLResult],[SyphilisTreatment],[HIVStatusBeforeANC]
					  ,[HIVTestingDone],[HIVTestType],[HIVTest1],[HIVTest1Result],[HIVTest2],[HIVTest2Result],[HIVTestFinalResult],[SyphilisTestDone]
					  ,[SyphilisTestType],[SyphilisTestResults],[SyphilisTreated],[MotherProphylaxisGiven],[MotherGivenHAART],[AZTBabyDispense]
					  ,[NVPBabyDispense],[ChronicIllness],[CounselledOn],[PartnerHIVTestingANC],[PartnerHIVStatusANC],[PostParturmFP],[Deworming]
					  ,[MalariaProphylaxis],[TetanusDose],[IronSupplementsGiven],[ReceivedMosquitoNet],[PreventiveServices],[UrinalysisVariables]
					  ,[ReferredFrom],[ReferredTo],[ReferralReasons],cast([NextAppointmentANC] as date)[NextAppointmentANC]
					  ,[ClinicalNotes] , P.[Date_Last_Modified]
				  FROM [MNCHCentral].[dbo].[AncVisits] (NoLock) P
					inner join (select tn.PatientPK,tn.SiteCode,tn.VisitDate,max(tn.DateExtracted)MaxDateExtracted 
									FROM [MNCHCentral].[dbo].[AncVisits] (NoLock)tn
									group by tn.PatientPK,tn.SiteCode,tn.VisitDate
								)tm
					on P.PatientPk = tm.PatientPk and p.SiteCode = tm.SiteCode
					and p.VisitDate = tm.VisitDate  and p.DateExtracted = tm.MaxDateExtracted
					INNER JOIN  [MNCHCentral].[dbo].[MnchPatients](NOLOCK)  Mnchp
					on P.PatientPK = Mnchp.patientPK and P.SiteCode = Mnchp.Sitecode
					INNER JOIN [MNCHCentral].[dbo].[Facilities](NoLock) F ON P.[FacilityId] = F.Id ) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						--and a.[PatientMnchID]  = b.[PatientMnchID]
						--and a.[ANCClinicNumber]  = b.[ANCClinicNumber]
						--and a.DateExtracted = b.DateExtracted
						and a.VisitID = b.VisitID
						and a.VisitDate = b.VisitDate  
						--and a.ChronicIllness  = b.ChronicIllness

						)
					WHEN NOT MATCHED THEN 
						INSERT(PatientMnchID,ANCClinicNumber,PatientPk,SiteCode,FacilityName,EMR,Project,VisitID,VisitDate,ANCVisitNo,GestationWeeks,Height,[Weight],Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,BP,BreastExam,AntenatalExercises,FGM,FGMComplications,Haemoglobin,DiabetesTest,TBScreening,CACxScreen,CACxScreenMethod,WHOStaging,VLSampleTaken,VLDate,VLResult,SyphilisTreatment,HIVStatusBeforeANC,HIVTestingDone,HIVTestType,HIVTest1,HIVTest1Result,HIVTest2,HIVTest2Result,HIVTestFinalResult,SyphilisTestDone,SyphilisTestType,SyphilisTestResults,SyphilisTreated,MotherProphylaxisGiven,MotherGivenHAART,AZTBabyDispense,NVPBabyDispense,ChronicIllness,CounselledOn,PartnerHIVTestingANC,PartnerHIVStatusANC,PostParturmFP,Deworming,MalariaProphylaxis,TetanusDose,IronSupplementsGiven,ReceivedMosquitoNet,PreventiveServices,UrinalysisVariables,ReferredFrom,ReferredTo,ReferralReasons,NextAppointmentANC,ClinicalNotes,Date_Last_Modified) 
						VALUES(PatientMnchID,ANCClinicNumber,PatientPk,SiteCode,FacilityName,EMR,Project,VisitID,VisitDate,ANCVisitNo,GestationWeeks,Height,[Weight],Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,BP,BreastExam,AntenatalExercises,FGM,FGMComplications,Haemoglobin,DiabetesTest,TBScreening,CACxScreen,CACxScreenMethod,WHOStaging,VLSampleTaken,VLDate,VLResult,SyphilisTreatment,HIVStatusBeforeANC,HIVTestingDone,HIVTestType,HIVTest1,HIVTest1Result,HIVTest2,HIVTest2Result,HIVTestFinalResult,SyphilisTestDone,SyphilisTestType,SyphilisTestResults,SyphilisTreated,MotherProphylaxisGiven,MotherGivenHAART,AZTBabyDispense,NVPBabyDispense,ChronicIllness,CounselledOn,PartnerHIVTestingANC,PartnerHIVStatusANC,PostParturmFP,Deworming,MalariaProphylaxis,TetanusDose,IronSupplementsGiven,ReceivedMosquitoNet,PreventiveServices,UrinalysisVariables,ReferredFrom,ReferredTo,ReferralReasons,NextAppointmentANC,ClinicalNotes,Date_Last_Modified)
																																																																																	
					WHEN MATCHED THEN
						UPDATE SET 
							a.SyphilisTreatment	 =b.SyphilisTreatment;


					with cte AS (
						Select
						Sitecode,
						PatientPK,
						VisitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,VisitDate ORDER BY
						PatientPK,Sitecode,VisitDate) Row_Num
						FROM  [ODS].[dbo].[MNCH_AncVisits](NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;


END



