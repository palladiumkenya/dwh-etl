IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateCovid]', N'U') IS NOT NULL 
	TRUNCATE TABLE [REPORTING].[dbo].[AggregateCovid]
GO

INSERT INTO REPORTING.dbo.AggregateCovid (MFLCode,FacilityName,County,SubCounty, PartnerName, AgencyName,Gender, AgeGroup,VaccinationStatus,PatientStatus,AdmissionStatus,AdmissionUnit,EverCOVID19Positive,MissedAppointmentDueToCOVID19,adults_count)
SELECT DISTINCT
MFLCode,
f.FacilityName,
County,
SubCounty,
p.PartnerName,
a.AgencyName,
Gender,
age.DATIMAgeGroup as AgeGroup,
cov.VaccinationStatus,
cov.PatientStatus,
cov.AdmissionStatus,
cov.AdmissionUnit,
cov.EverCOVID19Positive,
cov.MissedAppointmentDueToCOVID19,
Count(*) adults_count

FROM NDWH.dbo.FactCovid cov
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = cov.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = cov.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = cov.PatientKey
INNER join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey = cov.AgeGroupKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = cov.PartnerKey
WHERE age.Age >= 12 AND pat.IsTXCurr = 1
GROUP BY MFLCode, f.FacilityName, County, SubCounty, p.PartnerName, a.AgencyName, Gender, age.DATIMAgeGroup,cov.VaccinationStatus, cov.PatientStatus, cov.AdmissionStatus, cov.AdmissionUnit, cov.EverCOVID19Positive, cov.MissedAppointmentDueToCOVID19
