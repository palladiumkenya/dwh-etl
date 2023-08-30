IF OBJECT_ID(
  N '[REPORTING].[dbo].AggregateAppointments', 
  N 'U'
) IS NOT NULL 
drop 
  table [REPORTING].[dbo].AggregateAppointments GO WITH Bookings AS (
    SELECT 
      Facilitykey, 
      AsofDateKey, 
      EOMONTH(ExpectedNextAppointmentDate) AS EndOfMonth, 
      PartnerKey, 
      Gender, 
      AgencyKey, 
      COUNT(DISTINCT PatientKey) AS NumBooked 
    FROM 
      NDWH.dbo.FACTAppointments apt 
    GROUP BY 
      Facilitykey, 
      AsofDateKey, 
      EOMONTH(ExpectedNextAppointmentDate), 
      PartnerKey, 
      Gender, 
      AgencyKey
  ), 
  Summary as (
    select 
      facility.MFLCode, 
      facility.FacilityKey, 
      facility.FacilityName, 
      facility.SubCounty, 
      facility.County, 
      partner.PartnerName, 
      Partner.PartnerKey, 
      agency.AgencyName, 
      agency.AgencyKey, 
      patient.Gender, 
      AppointmentStatus, 
      count(*) NumOfPatients, 
      --NumBooked,
      age_group.DATIMAgeGroup, 
      apt.AsOfDateKey, 
      cast(
        getdate() as date
      ) as LoadDate 
    from 
      NDWH.dbo.FACTAppointments as apt 
      left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = apt.FacilityKey 
      left join NDWH.dbo.DimPartner as partner on partner.PartnerKey = apt.PartnerKey 
      left join NDWH.dbo.DimPatient as patient on patient.PatientKey = apt.PatientKey 
      left join NDWH.dbo.DimAgency as agency on agency.AgencyKey = apt.AgencyKey 
      left join NDWH.dbo.DimAgeGroup as age_group on age_group.AgeGroupKey = DATEDIFF(YY, patient.DOB, apt.AsOfDate) 
      left join Bookings on Bookings.FacilityKey = apt.FacilityKey 
      and bookings.AsOfDateKey = apt.AsOfDateKey 
    group by 
      facility.MFLCode, 
      facility.FacilityKey, 
      facility.FacilityName, 
      facility.SubCounty, 
      facility.County, 
      partner.PartnerName, 
      Partner.PartnerKey, 
      agency.AgencyName, 
      agency.AgencyKey, 
      patient.Gender, 
      AppointmentStatus, 
      apt.AsOfDateKey, 
      age_group.DATIMAgeGroup
  ) 
Select 
  Summary.MFLCode, 
  Summary.FacilityKey, 
  Summary.FacilityName, 
  Summary.SubCounty, 
  Summary.County, 
  Summary.PartnerName, 
  Summary.PartnerKey, 
  Summary.AgencyName, 
  Summary.AgencyKey, 
  Summary.Gender, 
  AppointmentStatus, 
  NumOfPatients, 
  Bookings.NumBooked, 
  Summary.DATIMAgeGroup, 
  Summary.AsOfDateKey, 
  cast(
    getdate() as date
  ) as LoadDate into [REPORTING].[dbo].AggregateAppointments 
from 
  Summary 
  left join Bookings AS Bookings on Bookings.AsOfDateKey = Summary.AsofDatekey 
  and bookings.FacilityKey = Summary.FacilityKey 
  and Bookings.PartnerKey = Summary.PartnerKey 
  and Bookings.Gender = Summary.Gender 
  and Bookings.AgencyKey = Summary.AgencyKey
