IF OBJECT_ID(N'REPORTING.[dbo].[LineListCovid]', N'U') IS NOT NULL 		

	drop TABLE REPORTING.[dbo].[LineListCovid]
GO

SELECT DISTINCT
MFLCode,
f.FacilityName,
County,
SubCounty,
p.PartnerName,
a.AgencyName,
Gender,
age.DATIMAgeGroup as AgeGroup,
Covid19AssessmentDateKey,
ReceivedCOVID19Vaccine,
cast(cast(DateGivenFirstDoseKey as char) as date) as DateGivenFirstDoseKey,
FirstDoseVaccineAdministered,
cast(cast(DateGivenSecondDoseKey as char) as date) as DateGivenSecondDoseKey,
SecondDoseVaccineAdministered,
VaccinationStatus,
VaccineVerification,
BoosterGiven,
BoosterDose,
BoosterDoseDateKey,
EverCOVID19Positive,
COVID19TestDateKey,
PatientStatus,
AdmissionStatus,
AdmissionUnit,
MissedAppointmentDueToCOVID19,
COVID19PositiveSinceLasVisit,
COVID19TestDateSinceLastVisit,
PatientStatusSinceLastVisit,
AdmissionStatusSinceLastVisit,
AdmissionStartDateKey,
AdmissionEndDateKey,
AdmissionUnitSinceLastVisit,
SupplementalOxygenReceived,
PatientVentilated,
TracingFinalOutcome,
CauseOfDeath,
CAST(GETDATE() AS DATE) AS LoadDate 
INTO REPORTING.dbo.LineListCovid 

FROM NDWH.dbo.FactCovid cov
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = cov.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = cov.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = cov.PatientKey
INNER join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=cov.AgeGroupKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = cov.PartnerKey
WHERE age.Age >= 12 AND pat.IsTXCurr = 1
