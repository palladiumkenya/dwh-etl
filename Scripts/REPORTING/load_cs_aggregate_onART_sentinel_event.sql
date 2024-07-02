IF OBJECT_ID(N'[HIVCaseSurveillance].[dbo].[CsAggegateOnARTSentinelEvent]', N'U') IS NOT NULL 
	drop TABLE [HIVCaseSurveillance].[dbo].[CsAggegateOnARTSentinelEvent]
GO

with art_start_indicators as (
    select 
        distinct art.PatientKey,
		patient.Gender,
        FacilityKey,
		PartnerKey,
		AgencyKey,
		AgeLastVisit,
		eomonth(art_date.Date) as AsOfDate,
		eomonth(date_confirmed_positive.Date) as CohortMonth
    from NDWH.dbo.FACTART as art
    left join NDWH.dbo.DimARTOutcome as outcome on outcome.ARTOutcomeKey = art.ARTOutcomeKey
	left join NDWH.dbo.DimDate as art_date on art_date.DateKey = art.StartARTDateKey
	left join NDWH.dbo.DimPatient as patient on patient.PatientKey = art.PatientKey
	left join NDWH.dbo.DimDate as date_confirmed_positive on date_confirmed_positive.DateKey = patient.DateConfirmedHIVPositiveKey
)
select
	CohortMonth,
	AsOfDate,
	agegroup.DATIMAgeGroup as AgeGroup,
	art_start_indicators.Gender,
	facility.FacilityName,
	facility.County,
	facility.SubCounty,
	partner.PartnerName,
	agency.AgencyName,
	count(*) as CountPatients
into [HIVCaseSurveillance].[dbo].[CsAggegateOnARTSentinelEvent]
from art_start_indicators 
left join NDWH.dbo.DimAgeGroup as agegroup on agegroup.Age = art_start_indicators.AgeLastVisit
left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = art_start_indicators.FacilityKey
left join NDWH.dbo.DimPartner as partner on partner.PartnerKey = art_start_indicators.PartnerKey
left join NDWH.dbo.DimAgency as agency on agency.AgencyKey = art_start_indicators.AgencyKey
group by
	AsOfDate,
	CohortMonth,	
	agegroup.DATIMAgeGroup,
	Gender,
	facility.FacilityName,
	facility.County,
	facility.SubCounty,
	partner.PartnerName,
	agency.AgencyName