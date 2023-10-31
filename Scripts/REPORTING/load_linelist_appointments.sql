IF OBJECT_ID(N'[REPORTING].[dbo].LinelistAppointments', N'U') IS NOT NULL 		
drop table [REPORTING].[dbo].LinelistAppointments

GO

with dsd_models as (
	select 
		PatientKey,
		DifferentiatedCare
	from NDWH.dbo.FactLatestObs
)
select 
  Patient.PatientIDHash,
  Patient.PatientPKHash,
  Patient.NUPI,
  Patient.DOB,
  Patient.MaritalStatus,
  facility.MFLCode,
  facility.FacilityName,
  facility.SubCounty,
  facility.County,
  partner.PartnerName,
  agency.AgencyName,
  patient.Gender,
  ExpectedNextAppointmentDate,
  LastEncounterDate,
  DiffExpectedTCADateLastEncounter,
  apt.AppointmentStatus,
  apt.AsOfDate,
  age_group.DATIMAgeGroup,
  dsd_models.DifferentiatedCare as LatestDSDModel,
  CAST(GETDATE() AS DATE) AS LoadDate 
into [REPORTING].[dbo].LinelistAppointments
from NDWH.dbo.FACTAppointments as apt
left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = apt.FacilityKey
left join NDWH.dbo.DimPartner as partner on partner.PartnerKey = apt.PartnerKey
left join NDWH.dbo.DimPatient as patient on patient.PatientKey = apt.PatientKey
left join NDWH.dbo.DimAgency as agency on agency.AgencyKey = apt.AgencyKey
left join NDWH.dbo.DimAgeGroup as age_group on age_group.AgeGroupKey = DATEDIFF(YY,patient.DOB,apt.AsOfDate)
left join dsd_models on dsd_models.PatientKey = apt.PatientKey
where AsOfDate >='2017-01-31'


