
--begin tran
BEGIN
--truncate table [ODS].[dbo].[MNCH_AncVisits]
	MERGE [ODS].[dbo].[MNCH_AncVisits] AS a
		USING(
				SELECT  Distinct [PatientMnchID],[ANCClinicNumber],[PatientPk],F.[SiteCode],[FacilityName],P.[EMR],[Project],cast([DateExtracted] as date)[DateExtracted]
					  ,[VisitID],cast([VisitDate] as date)[VisitDate],[ANCVisitNo],[GestationWeeks],[Height],[Weight],[Temp],[PulseRate],[RespiratoryRate]
					  ,[OxygenSaturation],[MUAC],[BP],[BreastExam],[AntenatalExercises],[FGM],[FGMComplications],[Haemoglobin],[DiabetesTest],[TBScreening]
					  ,[CACxScreen],[CACxScreenMethod],[WHOStaging],[VLSampleTaken],[VLDate],[VLResult],[SyphilisTreatment],[HIVStatusBeforeANC]
					  ,[HIVTestingDone],[HIVTestType],[HIVTest1],[HIVTest1Result],[HIVTest2],[HIVTest2Result],[HIVTestFinalResult],[SyphilisTestDone]
					  ,[SyphilisTestType],[SyphilisTestResults],[SyphilisTreated],[MotherProphylaxisGiven],[MotherGivenHAART],[AZTBabyDispense]
					  ,[NVPBabyDispense],[ChronicIllness],[CounselledOn],[PartnerHIVTestingANC],[PartnerHIVStatusANC],[PostParturmFP],[Deworming]
					  ,[MalariaProphylaxis],[TetanusDose],[IronSupplementsGiven],[ReceivedMosquitoNet],[PreventiveServices],[UrinalysisVariables]
					  ,[ReferredFrom],[ReferredTo],[ReferralReasons],cast([NextAppointmentANC] as date)[NextAppointmentANC]
					  ,[ClinicalNotes] ,[Date_Created],[Date_Last_Modified],
					  convert(nvarchar(64), hashbytes('SHA2_256', cast(p.[PatientPk]  as nvarchar(36))), 2) PatientPKHash,
					  convert(nvarchar(64), hashbytes('SHA2_256', cast([PatientMnchID]  as nvarchar(36))), 2)PatientMnchIDHash,
					  convert(nvarchar(64), hashbytes('SHA2_256', cast(LTRIM(RTRIM(P.SiteCode))+'-'+LTRIM(RTRIM(p.PatientPk))   as nvarchar(36))), 2) CKVHash

				  FROM [MNCHCentral].[dbo].[AncVisits] (NoLock) P
				  INNER JOIN [MNCHCentral].[dbo].[Facilities](NoLock) F ON P.[FacilityId] = F.Id  ) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.[PatientMnchID] COLLATE Latin1_General_CI_AS = b.[PatientMnchID]
						and a.[ANCClinicNumber] COLLATE Latin1_General_CI_AS = b.[ANCClinicNumber]
						and a.DateExtracted = b.DateExtracted
						and a.VisitID = b.VisitID
						and a.VisitDate = b.VisitDate  
						and a.ChronicIllness COLLATE Latin1_General_CI_AS = b.ChronicIllness

						)
					WHEN NOT MATCHED THEN 
						INSERT(PatientMnchID,ANCClinicNumber,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,VisitID,VisitDate,ANCVisitNo,GestationWeeks,Height,[Weight],Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,BP,BreastExam,AntenatalExercises,FGM,FGMComplications,Haemoglobin,DiabetesTest,TBScreening,CACxScreen,CACxScreenMethod,WHOStaging,VLSampleTaken,VLDate,VLResult,SyphilisTreatment,HIVStatusBeforeANC,HIVTestingDone,HIVTestType,HIVTest1,HIVTest1Result,HIVTest2,HIVTest2Result,HIVTestFinalResult,SyphilisTestDone,SyphilisTestType,SyphilisTestResults,SyphilisTreated,MotherProphylaxisGiven,MotherGivenHAART,AZTBabyDispense,NVPBabyDispense,ChronicIllness,CounselledOn,PartnerHIVTestingANC,PartnerHIVStatusANC,PostParturmFP,Deworming,MalariaProphylaxis,TetanusDose,IronSupplementsGiven,ReceivedMosquitoNet,PreventiveServices,UrinalysisVariables,ReferredFrom,ReferredTo,ReferralReasons,NextAppointmentANC,ClinicalNotes,Date_Created,Date_Last_Modified ,PatientPKHash,PatientMnchIDHash,CKVHash) 
						VALUES(PatientMnchID,ANCClinicNumber,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,VisitID,VisitDate,ANCVisitNo,GestationWeeks,Height,[Weight],Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,BP,BreastExam,AntenatalExercises,FGM,FGMComplications,Haemoglobin,DiabetesTest,TBScreening,CACxScreen,CACxScreenMethod,WHOStaging,VLSampleTaken,VLDate,VLResult,SyphilisTreatment,HIVStatusBeforeANC,HIVTestingDone,HIVTestType,HIVTest1,HIVTest1Result,HIVTest2,HIVTest2Result,HIVTestFinalResult,SyphilisTestDone,SyphilisTestType,SyphilisTestResults,SyphilisTreated,MotherProphylaxisGiven,MotherGivenHAART,AZTBabyDispense,NVPBabyDispense,ChronicIllness,CounselledOn,PartnerHIVTestingANC,PartnerHIVStatusANC,PostParturmFP,Deworming,MalariaProphylaxis,TetanusDose,IronSupplementsGiven,ReceivedMosquitoNet,PreventiveServices,UrinalysisVariables,ReferredFrom,ReferredTo,ReferralReasons,NextAppointmentANC,ClinicalNotes,Date_Created,Date_Last_Modified ,PatientPKHash,PatientMnchIDHash,CKVHash)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.SyphilisTreatment	 =b.SyphilisTreatment;
END

--rollback tran

