BEGIN
	       DECLARE @MaxCovid19AssessmentDate_Hist			DATETIME,
				   @Covid19AssessmentDate					DATETIME
				
		SELECT @MaxCovid19AssessmentDate_Hist =  MAX(MaxCovid19AssessmentDate) FROM [ODS].[dbo].[CT_Covid_Log]  (NoLock)
		SELECT @Covid19AssessmentDate = MAX(Covid19AssessmentDate) FROM [DWAPICentral].[dbo].[CovidExtract](NoLock)
		
		IF (SELECT COUNT(1) FROM [ODS].[dbo].[CT_Covid_Log](NoLock) WHERE MaxCovid19AssessmentDate = @MaxCovid19AssessmentDate_Hist) > 0
		RETURN

			ELSE
				BEGIN
					
					INSERT INTO  [ODS].[dbo].[CT_Covid_Log](MaxCovid19AssessmentDate,LoadStartDateTime)
					VALUES(@MaxCovid19AssessmentDate_Hist,GETDATE())

					INSERT INTO [ODS].[dbo].[CT_Covid](PatientPK,PatientID,Emr,Project,SiteCode,FacilityName,VisitID,
					Covid19AssessmentDate,ReceivedCOVID19Vaccine,DateGivenFirstDose,FirstDoseVaccineAdministered,DateGivenSecondDose,
					SecondDoseVaccineAdministered,VaccinationStatus,VaccineVerification,BoosterGiven,BoosterDose,BoosterDoseDate,
					EverCOVID19Positive,COVID19TestDate,PatientStatus,AdmissionStatus,AdmissionUnit,MissedAppointmentDueToCOVID19,
					COVID19PositiveSinceLasVisit,COVID19TestDateSinceLastVisit,PatientStatusSinceLastVisit,AdmissionStatusSinceLastVisit,AdmissionStartDate,AdmissionEndDate,AdmissionUnitSinceLastVisit,SupplementalOxygenReceived,PatientVentilated,TracingFinalOutcome,CauseOfDeath,CKV,DateImported,BoosterDoseVerified
						,[Sequence]
						,COVID19TestResult)
					SELECT P.[PatientPID] AS PatientPK
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
						FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
						INNER JOIN [DWAPICentral].[dbo].[CovidExtract](NoLock) C  ON C.[PatientId]= P.ID AND C.Voided=0
						INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id  AND F.Voided=0
					WHERE P.gender != 'Unknown'    and Covid19AssessmentDate > @MaxCovid19AssessmentDate_Hist					

					UPDATE [ODS].[dbo].[CT_Covid_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxCovid19AssessmentDate = @MaxCovid19AssessmentDate_Hist;

			END
			---Remove any duplicate from [ODS].[dbo].[CT_Covid]
			;WITH CTE AS   
				(  
					SELECT [PatientPK],[SiteCode],ROW_NUMBER() 
					OVER (PARTITION BY [PatientPK],[SiteCode]
					ORDER BY [PatientPK],[SiteCode]) AS dump_ 
					FROM [ODS].[dbo].[CT_Covid]
					)  
			
			DELETE FROM CTE WHERE dump_ >1;

			
	END