IF OBJECT_ID(N'[ODS].[dbo].[Intermediate_ARTOutcomes]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[dbo].[Intermediate_ARTOutcomes];

BEGIN
    --- Declare variables
		Declare @emonth						datetime2,
				@FirstDayOfReportingMonth	datetime,
				@LastDayOfReportingMonth	datetime,
				@IITDays					int 

		set @IITDays = 30  ---To be stored in table
		set @emonth = ( select 
							case 
								when day(getdate()) >= 1 and day(getdate()) <= 15 then eomonth(getdate(), -2)
								else eomonth (getdate(), -1) 
							end as emonth_calc
						);

		set @FirstDayOfReportingMonth = 
										( select 
												case 
													when day(getdate()) >= 1 and day(getdate()) <= 15 then  DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)
													else DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)
												end as emonth_calc
										);
		set @LastDayOfReportingMonth = 
										( select 
												case 
													when day(getdate()) >= 1 and day(getdate()) <= 15 then  DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-2, -1)
													else DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1)
												end as emonth_calc
										);
	--- End

	;With Exits As (
						SELECT 
							ROW_NUMBER() over (PARTITION by PatientPk, Sitecode ORDER by ExitDate DESC) as RowNum,
							PatientPK,
							SiteCode,
							ExitDate,
							ExitReason,
							ExitDescription,
							EffectiveDiscontinuationDate,
							ReasonForDeath,
							ReEnrollmentDate
						FROM ODS.dbo.CT_PatientStatus
						WHERE VOIDED=0
				),
    Latestexits As (
						SELECT 
							PatientPK,
							SiteCode,
							ExitDate,
							ExitReason,
							ExitDescription,
							EffectiveDiscontinuationDate,
							ReEnrollmentDate,
							ReasonForDeath
						FROM Exits As Exits
						WHERE RowNum=1 and ExitDate  <= @emonth--EOMONTH(DATEADD(mm,-1,GETDATE()))
					),
    
    ARTOutcomes AS (
					SELECT DISTINCT	 
						Patients.PatientID, 
						Patients.PatientPK,		
						ART.startARTDate,
						YEAR(ART.startARTDate) AS Cohort,
						LatestExits.ExitReason,
						LatestExits.ExitDate,
						LastPatientEncounter.LastEncounterDate,
						LastPatientEncounter.NextAppointmentDate,
						CASE
							WHEN  Latestexits.ExitReason  in ('DIED','dead','Death','Died') THEN 'D'--1
							WHEN DATEDIFF( dd, ISNULL(LastPatientEncounter.NextAppointmentDate,ART.ExpectedReturn),@emonth  ) > @IITDays and LatestExits.ExitReason is null 
								THEN 'uL'--Date diff btw TCA  and Last day of Previous month--2
							WHEN  LatestExits.ExitDate IS NOT NULL and LatestExits.ExitReason not in ('DIED','dead','Death','Died') and  Latestexits.ReEnrollmentDate between  @FirstDayOfReportingMonth and @LastDayOfReportingMonth  
								THEN 'V'--3
							WHEN  LatestExits.ExitDate IS NOT NULL and LatestExits.ExitReason not in ('DIED','dead','Death','Died') and  Latestexits.EffectiveDiscontinuationDate >= @emonth 
								THEN 'V'--4
 							WHEN  ART.startARTDate> @LastDayOfReportingMonth 
								THEN 'NP'--5
							WHEN  LatestExits.ExitDate IS NOT NULL and LatestExits.ExitReason not in ('DIED','dead','Death','Died') and LatestExits.EffectiveDiscontinuationDate between @FirstDayOfReportingMonth  and @LastDayOfReportingMonth  
								THEN SUBSTRING(LatestExits.ExitReason,1,1)--When a TO and LFTU has an discontinuationdate during the reporting Month --6
							WHEN  LatestExits.ExitDate IS NOT NULL and LatestExits.ExitReason not in ('DIED','dead','Death','Died') and  LastPatientEncounter.NextAppointmentDate > @emonth   
								THEN 'V'--7
							WHEN  DATEDIFF( dd, LastPatientEncounter.NextAppointmentDate, @emonth) <= @IITDays 
								THEN 'V'-- Date diff btw TCA  and LAst day of Previous month-- must not be late by 30 days -- 8
							WHEN  LastPatientEncounter.NextAppointmentDate > @emonth    
								Then 'V' --9
							WHEN  LatestExits.EffectiveDiscontinuationDate is not null and Latestexits.ReEnrollmentDate is Null 
								THEN SUBSTRING(LatestExits.ExitReason,1,1) --10
							WHEN LastPatientEncounter.NextAppointmentDate IS NULL 
								THEN 'NV' --11
							ELSE SUBSTRING(LatestExits.ExitReason,1,1)
						END	AS ARTOutcome, 
						cast (Patients.SiteCode as nvarchar) As SiteCode,
						Patients.Emr,
						Patients.Project,
						Latestexits.ReEnrollmentDate,
						Latestexits.EffectiveDiscontinuationDate
					FROM ODS.dbo.CT_Patient Patients
						INNER JOIN ODS.dbo.CT_ARTPatients  ART  
							ON  Patients.PatientPK=ART.PatientPK and 
								Patients.Sitecode=ART.Sitecode
						Left JOIN ODS.dbo.Intermediate_LastPatientEncounter  LastPatientEncounter 
							ON   Patients.PatientPK =LastPatientEncounter.PatientPK   AND 
								Patients.SiteCode	=LastPatientEncounter.SiteCode
						LEFT JOIN  LatestExits   
							ON  Patients.PatientPK=Latestexits.PatientPK  and 
								Patients.Sitecode=Latestexits.Sitecode

					WHERE  ART.startARTDate IS NOT NULL AND  ART.VOIDED=0
				),
	LatestUpload AS (
						SELECT 
							cast (SiteCode as nvarchar)As SiteCode ,
							Max(DateRecieved) As DateUploaded
						FROM ODS.dbo.CT_FacilityManifest
						group by SiteCode
					),

	LatestVisits AS (
						SELECT DISTINCT
							sitecode,
							Max(Visitdate) As SiteAbstractionDate
						FROM ODS.dbo.CT_PatientVisits
						WHERE VOIDED=0
						group by SiteCode
                    )
	Select 
			ARTOutcomes.PatientID, 
			ARTOutcomes.PatientPK,
			cast( '' as nvarchar(100)) PatientPKHash,
			cast( '' as nvarchar(100)) PatientIDHash,
			ARTOutcomes.startARTDate,
			YEAR(ARTOutcomes.startARTDate) AS Cohort,
			ARTOutcomes.ExitReason,
			ARTOutcomes.ExitDate,
			ARTOutcomes.LastEncounterDate,
			ARTOutcomes.NextAppointmentDate,
			ARTOutcomes.ARTOutcome, 
			ARTOutcomes.SiteCode,
			ARTOutcomes.Emr,
			ARTOutcomes.Project,
			LatestUpload.DateUploaded,
			LatestVisits.SiteAbstractionDate,
            ReEnrollmentDate,
           EffectiveDiscontinuationDate,
			cast(getdate() as date) as LoadDate
			INTO  [ODS].[dbo].[Intermediate_ARTOutcomes]
	 from ARTOutcomes
		left join LatestUpload 
			ON LatestUpload.SiteCode = ARTOutcomes.SiteCode 
		left  join  LatestVisits  
			ON  LatestVisits.SiteCode = ARTOutcomes.SiteCode

END