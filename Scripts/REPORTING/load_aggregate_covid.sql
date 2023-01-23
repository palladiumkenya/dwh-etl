Go
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AggregateCovid]') AND type in (N'U'))
TRUNCATE TABLE [dbo].[AggregateCovid]
GO

INSERT INTO REPORTING.dbo.AggregateCovid
SELECT DISTINCT
MFLCode,
f.FacilityName,
County,
SubCounty,
p.PartnerName as CTPartner,
a.AgencyName as CTAgency,
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