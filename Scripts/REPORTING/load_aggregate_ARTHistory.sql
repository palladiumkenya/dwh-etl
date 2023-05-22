IF OBJECT_ID(N'[REPORTING].[dbo].AggregateARTHistory', N'U') IS NOT NULL 		
	truncate table [REPORTING].[dbo].AggregateARTHistory
GO

Insert into [REPORTING].[dbo].AggregateARTHistory
select 
    facility.MFLCode,
    facility.FacilityName,
    facility.SubCounty,
    facility.County,
    partner.PartnerName,
    agency.AgencyName,
    patient.Gender,
    count(*) NumOfPatients,
	ART.IsTXCurr,
	 AsOfDateKey,
    age_group.DATIMAgeGroup
  
from NDWH.dbo.FactARTHistory as ART
left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = ART.FacilityKey
left join NDWH.dbo.DimPartner as partner on partner.PartnerKey = ART.PartnerKey
left join NDWH.dbo.DimPatient as patient on patient.PatientKey = ART.PatientKey
left join NDWH.dbo.DimAgency as agency on agency.AgencyKey = ART.AgencyKey
left join NDWH.dbo.DimAgeGroup as age_group on age_group.AgeGroupKey = DATEDIFF(YY,patient.DOB,ART.AsOfDateKey)

group by 
    facility.MFLCode,
    facility.FacilityName,
    facility.SubCounty,
    facility.County,
    partner.PartnerName,
    agency.AgencyName,
    patient.Gender,
	ART.IsTXCurr,
	AsOfDateKey,
    DATIMAgeGroup



