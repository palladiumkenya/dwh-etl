
TRUNCATE TABLE [REPORTING].[dbo].LinelistAppointments;

INSERT INTO  [REPORTING].[dbo].LinelistAppointments(PatientIDHash,PatientPKHash,NUPI,DOB,MaritalStatus,MFLCode,FacilityName,SubCounty,County,PartnerName,AgencyName,Gender,ExpectedNextAppointmentDate,LastEncounterDate,DiffExpectedTCADateLastEncounter,AppointmentStatus,AsOfDate,DATIMAgeGroup,LatestDSDModel,LoadDate)
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
  NULL LatestDSDModel ,
  --dsd_models.DifferentiatedCare as LatestDSDModel,
  CAST(GETDATE() AS DATE) AS LoadDate 
from NDWH.dbo.FACTAppointments(NOLOCK) as apt
left join NDWH.dbo.DimFacility(NOLOCK) as facility on facility.FacilityKey = apt.FacilityKey
left join NDWH.dbo.DimPartner(NOLOCK) as partner on partner.PartnerKey = apt.PartnerKey
left join NDWH.dbo.DimPatient(NOLOCK) as patient on patient.PatientKey = apt.PatientKey
left join NDWH.dbo.DimAgency(NOLOCK) as agency on agency.AgencyKey = apt.AgencyKey
left join NDWH.dbo.DimAgeGroup(NOLOCK) as age_group on age_group.AgeGroupKey = DATEDIFF(YY,patient.DOB,apt.AsOfDate)
--left join dsd_models on dsd_models.PatientKey = apt.PatientKey
where AsOfDate >='2017-01-31'
