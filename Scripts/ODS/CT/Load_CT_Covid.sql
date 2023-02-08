BEGIN
		DECLARE	@MaxCovid19AssessmentDate_Hist			DATETIME,
				    @Covid19AssessmentDate					DATETIME
				
		SELECT @MaxCovid19AssessmentDate_Hist =  MAX(MaxCovid19AssessmentDate) FROM [ODS].[dbo].[CT_Covid_Log]  (NoLock)
		SELECT @Covid19AssessmentDate = MAX(Covid19AssessmentDate) FROM [DWAPICentral].[dbo].[CovidExtract](NoLock)		
					
		INSERT INTO  [ODS].[dbo].[CT_Covid_Log](MaxCovid19AssessmentDate,LoadStartDateTime)
		VALUES(@MaxCovid19AssessmentDate_Hist,GETDATE())

			--CREATE INDEX CT_Covid ON [ODS].[dbo].[CT_Covid] (sitecode,PatientPK);
	       ---- Refresh [ODS].[dbo].[CT_Covid]
			MERGE [ODS].[dbo].[CT_Covid] AS a
				USING(SELECT P.[PatientPID] AS PatientPK
							,P.[PatientCccNumber] AS PatientID
							,P.[Emr]
							,P.[Project]
							,F.Code AS SiteCode
							,F.Name AS FacilityName ,[VisitID]
							,Cast([Covid19AssessmentDate] as Date)[Covid19AssessmentDate]
							,[ReceivedCOVID19Vaccine]
							,Cast([DateGivenFirstDose] as date) [DateGivenFirstDose]
							,[FirstDoseVaccineAdministered]
							,Cast([DateGivenSecondDose] as Date)[DateGivenSecondDose]
							,[SecondDoseVaccineAdministered]
							,[VaccinationStatus],[VaccineVerification],[BoosterGiven],[BoosterDose]
							,Cast([BoosterDoseDate] as Date)[BoosterDoseDate]
							,[EverCOVID19Positive]
							,Cast([COVID19TestDate] as Date) [COVID19TestDate],[PatientStatus],[AdmissionStatus],[AdmissionUnit],[MissedAppointmentDueToCOVID19]
							,[COVID19PositiveSinceLasVisit]
							,Cast([COVID19TestDateSinceLastVisit] as Date)[COVID19TestDateSinceLastVisit]
							,[PatientStatusSinceLastVisit]
							,[AdmissionStatusSinceLastVisit]
							,Cast([AdmissionStartDate] as Date)[AdmissionStartDate]
							,Cast([AdmissionEndDate] as Date)[AdmissionEndDate]
							,[AdmissionUnitSinceLastVisit]
							,[SupplementalOxygenReceived]
							,[PatientVentilated]
							,[TracingFinalOutcome]
							,[CauseOfDeath]
							,LTRIM(RTRIM(STR(F.Code)))+'-'+LTRIM(RTRIM(P.[PatientCccNumber]))+'-'+LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV
						,getdate() as [DateImported]
						,BoosterDoseVerified
						,[Sequence]
						,COVID19TestResult
						,P.ID as PatientUnique_ID
						,C.PatientId as UniquePatientCovidId
						,C.ID as CovidUnique_ID
						FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
						INNER JOIN [DWAPICentral].[dbo].[CovidExtract](NoLock) C  ON C.[PatientId]= P.ID AND C.Voided=0
						INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id  AND F.Voided=0
					WHERE P.gender != 'Unknown') AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.visitID = b.visitID
						AND a.Covid19AssessmentDate = b.Covid19AssessmentDate
						and a.PatientUnique_ID =b.UniquePatientCovidId
						--and a.CovidUnique_ID = b.CovidUnique_ID
						)

					WHEN NOT MATCHED THEN 
						INSERT(PatientPK,PatientID,Emr,Project,SiteCode,FacilityName,VisitID,Covid19AssessmentDate,ReceivedCOVID19Vaccine,DateGivenFirstDose,FirstDoseVaccineAdministered,DateGivenSecondDose,SecondDoseVaccineAdministered,VaccinationStatus,VaccineVerification,BoosterGiven,BoosterDose,BoosterDoseDate,EverCOVID19Positive,COVID19TestDate,PatientStatus,AdmissionStatus,AdmissionUnit,MissedAppointmentDueToCOVID19,COVID19PositiveSinceLasVisit,COVID19TestDateSinceLastVisit,PatientStatusSinceLastVisit,AdmissionStatusSinceLastVisit,AdmissionStartDate,AdmissionEndDate,AdmissionUnitSinceLastVisit,SupplementalOxygenReceived,PatientVentilated,TracingFinalOutcome,CauseOfDeath,CKV,DateImported,BoosterDoseVerified,Sequence,COVID19TestResult,PatientUnique_ID,CovidUnique_ID) 
						VALUES(PatientPK,PatientID,Emr,Project,SiteCode,FacilityName,VisitID,Covid19AssessmentDate,ReceivedCOVID19Vaccine,DateGivenFirstDose,FirstDoseVaccineAdministered,DateGivenSecondDose,SecondDoseVaccineAdministered,VaccinationStatus,VaccineVerification,BoosterGiven,BoosterDose,BoosterDoseDate,EverCOVID19Positive,COVID19TestDate,PatientStatus,AdmissionStatus,AdmissionUnit,MissedAppointmentDueToCOVID19,COVID19PositiveSinceLasVisit,COVID19TestDateSinceLastVisit,PatientStatusSinceLastVisit,AdmissionStatusSinceLastVisit,AdmissionStartDate,AdmissionEndDate,AdmissionUnitSinceLastVisit,SupplementalOxygenReceived,PatientVentilated,TracingFinalOutcome,CauseOfDeath,CKV,DateImported,BoosterDoseVerified,Sequence,COVID19TestResult,PatientUnique_ID,CovidUnique_ID)
				
					WHEN MATCHED THEN
						UPDATE SET 						
						a.Emr								=b.Emr,
						a.Project							=b.Project,
						a.FacilityName						=b.FacilityName,
						a.VisitID							=b.VisitID,
						a.ReceivedCOVID19Vaccine			=b.ReceivedCOVID19Vaccine,
						a.DateGivenFirstDose				=b.DateGivenFirstDose,
						a.FirstDoseVaccineAdministered		=b.FirstDoseVaccineAdministered,
						a.DateGivenSecondDose				=b.DateGivenSecondDose,
						a.SecondDoseVaccineAdministered		=b.SecondDoseVaccineAdministered,
						a.VaccinationStatus					=b.VaccinationStatus,
						a.VaccineVerification				=b.VaccineVerification,
						a.BoosterGiven						=b.BoosterGiven,
						a.BoosterDose						=b.BoosterDose,
						a.BoosterDoseDate					=b.BoosterDoseDate,
						a.EverCOVID19Positive				=b.EverCOVID19Positive,
						a.COVID19TestDate					=b.COVID19TestDate,
						a.PatientStatus						=b.PatientStatus,
						a.AdmissionStatus					=b.AdmissionStatus,
						a.AdmissionUnit						=b.AdmissionUnit,
						a.MissedAppointmentDueToCOVID19		=b.MissedAppointmentDueToCOVID19,
						a.COVID19PositiveSinceLasVisit		=b.COVID19PositiveSinceLasVisit,
						a.COVID19TestDateSinceLastVisit		=b.COVID19TestDateSinceLastVisit,
						a.PatientStatusSinceLastVisit		=b.PatientStatusSinceLastVisit,
						a.AdmissionStatusSinceLastVisit		=b.AdmissionStatusSinceLastVisit,
						a.AdmissionStartDate				=b.AdmissionStartDate,
						a.AdmissionEndDate					=b.AdmissionEndDate,
						a.AdmissionUnitSinceLastVisit		=b.AdmissionUnitSinceLastVisit,
						a.SupplementalOxygenReceived		=b.SupplementalOxygenReceived,
						a.PatientVentilated					=b.PatientVentilated,
						a.TracingFinalOutcome				=b.TracingFinalOutcome,
						a.CauseOfDeath						=b.CauseOfDeath,
						a.CKV								=b.CKV,
						a.DateImported						=b.DateImported,
						a.BoosterDoseVerified				=b.BoosterDoseVerified,
						a.[Sequence]						=b.[Sequence],
						a.COVID19TestResult					=b.COVID19TestResult;
						
					--WHEN NOT MATCHED BY SOURCE 
					--	THEN
					--	/* The Record is in the target table but doen't exit on the source table*/
					--		Delete;

					--		WITH CTE AS   
					--(  
					--	SELECT [PatientPK],[SiteCode],VisitID,Covid19AssessmentDate,ROW_NUMBER() 
					--	OVER (PARTITION BY [PatientPK],[SiteCode],VisitID,Covid19AssessmentDate
					--	ORDER BY [PatientPK],[SiteCode],VisitID,Covid19AssessmentDate) AS dump_ 
					--	FROM [ODS].[dbo].[CT_Covid] 
					--	)  
			
				--DELETE FROM CTE WHERE dump_ >1;

				UPDATE [ODS].[dbo].[CT_Covid_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxCovid19AssessmentDate = @MaxCovid19AssessmentDate_Hist;

				INSERT INTO [ODS].[dbo].[CT_CovidCount_Log]([SiteCode],[CreatedDate],[CovidCount])
				SELECT SiteCode,GETDATE(),COUNT(SiteCode) AS CovidCount 
				FROM [ODS].[dbo].[CT_Covid] 
				--WHERE @MaxCreatedDate  > @MaxCreatedDate
				GROUP BY SiteCode;

				--DROP INDEX CT_Covid ON [ODS].[dbo].[CT_Covid];
				---Remove any duplicate from [ODS].[dbo].[CT_Covid]


	END
