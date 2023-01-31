--begin tran
BEGIN
--truncate table [ODS].[dbo].[MNCH_AncVisits]

--;with cte AS  (
--	Select 
--	a.PatientPK
--	,a.Sitecode,
--	[PatientMnchID],
--	[ANCClinicNumber],
--	DateExtracted,
--	VisitID,
--	VisitDate,
--	ChronicIllness,

--	 ROW_NUMBER() OVER (PARTITION BY a.PatientPK,a.Sitecode,[PatientMnchID],[ANCClinicNumber],DateExtracted,VisitID,VisitDate,ChronicIllness ORDER BY  ---111,909
--	a.PatientPK,a.Sitecode) Row_Num
--	FROM  [MNCHCentral].[dbo].[AncVisits] (nolock)a
--	)
--delete  from cte 
--	Where Row_Num >1

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
					  ,[ClinicalNotes] ,[Date_Created],[Date_Last_Modified]
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
						INSERT(PatientMnchID,ANCClinicNumber,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,VisitID,VisitDate,ANCVisitNo,GestationWeeks,Height,[Weight],Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,BP,BreastExam,AntenatalExercises,FGM,FGMComplications,Haemoglobin,DiabetesTest,TBScreening,CACxScreen,CACxScreenMethod,WHOStaging,VLSampleTaken,VLDate,VLResult,SyphilisTreatment,HIVStatusBeforeANC,HIVTestingDone,HIVTestType,HIVTest1,HIVTest1Result,HIVTest2,HIVTest2Result,HIVTestFinalResult,SyphilisTestDone,SyphilisTestType,SyphilisTestResults,SyphilisTreated,MotherProphylaxisGiven,MotherGivenHAART,AZTBabyDispense,NVPBabyDispense,ChronicIllness,CounselledOn,PartnerHIVTestingANC,PartnerHIVStatusANC,PostParturmFP,Deworming,MalariaProphylaxis,TetanusDose,IronSupplementsGiven,ReceivedMosquitoNet,PreventiveServices,UrinalysisVariables,ReferredFrom,ReferredTo,ReferralReasons,NextAppointmentANC,ClinicalNotes,Date_Created,Date_Last_Modified) 
						VALUES(PatientMnchID,ANCClinicNumber,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,VisitID,VisitDate,ANCVisitNo,GestationWeeks,Height,[Weight],Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,BP,BreastExam,AntenatalExercises,FGM,FGMComplications,Haemoglobin,DiabetesTest,TBScreening,CACxScreen,CACxScreenMethod,WHOStaging,VLSampleTaken,VLDate,VLResult,SyphilisTreatment,HIVStatusBeforeANC,HIVTestingDone,HIVTestType,HIVTest1,HIVTest1Result,HIVTest2,HIVTest2Result,HIVTestFinalResult,SyphilisTestDone,SyphilisTestType,SyphilisTestResults,SyphilisTreated,MotherProphylaxisGiven,MotherGivenHAART,AZTBabyDispense,NVPBabyDispense,ChronicIllness,CounselledOn,PartnerHIVTestingANC,PartnerHIVStatusANC,PostParturmFP,Deworming,MalariaProphylaxis,TetanusDose,IronSupplementsGiven,ReceivedMosquitoNet,PreventiveServices,UrinalysisVariables,ReferredFrom,ReferredTo,ReferralReasons,NextAppointmentANC,ClinicalNotes,Date_Created,Date_Last_Modified)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.SyphilisTreatment	 =b.SyphilisTreatment;
END

--rollback tran