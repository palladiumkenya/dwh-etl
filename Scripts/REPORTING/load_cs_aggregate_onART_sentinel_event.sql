IF OBJECT_ID(N'[HIVCaseSurveillance].[dbo].[CsAggregateOnARTSentinelEvent]', N'U') IS NOT NULL 
	drop TABLE [HIVCaseSurveillance].[dbo].[CsAggregateOnARTSentinelEvent]
GO


with confirmed_reported_cases_and_art as (
	select 
		art.PatientKey,
        patient.Gender,
		art.AgeLastVisit,
		art.FacilityKey,
		PartnerKey,
		AgencyKey,
		eomonth(confirmed_date.Date) as CohortYearMonth,
        eomonth(art_date.Date) as AsOfDate
	from NDWH.dbo.FACTART as art 
	left join NDWH.dbo.DimPatient as patient on patient.PatientKey = art.PatientKey
    left join NDWH.dbo.DimDate as confirmed_date on confirmed_date.DateKey = patient.DateConfirmedHIVPositiveKey
    left join NDWH.dbo.DimDate as art_date on art_date.DateKey = art.StartARTDateKey
)
select
	CohortYearMonth,
	AsOfDate,
	agegroup.DATIMAgeGroup as AgeGroup,
	confirmed_reported_cases_and_art.Gender,
	facility.FacilityName,
	facility.County,
	facility.SubCounty,
	partner.PartnerName,
	agency.AgencyName,
    sum(case when confirmed_reported_cases_and_art.CohortYearMonth is not null then 1 else 0 end) as ReportedCases,
	sum(case when confirmed_reported_cases_and_art.AsOfDate is not null then 1 else 0 end) as OnARTClients
into [HIVCaseSurveillance].[dbo].[CsAggregateOnARTSentinelEvent]
from confirmed_reported_cases_and_art
left join NDWH.dbo.DimAgeGroup as agegroup on agegroup.Age = confirmed_reported_cases_and_art.AgeLastVisit
left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = confirmed_reported_cases_and_art.FacilityKey
left join NDWH.dbo.DimPartner as partner on partner.PartnerKey = confirmed_reported_cases_and_art.PartnerKey
left join NDWH.dbo.DimAgency as agency on agency.AgencyKey = confirmed_reported_cases_and_art.AgencyKey
where CohortYearMonth is not null
group by
	AsOfDate,
	CohortYearMonth,	
	agegroup.DATIMAgeGroup,
	confirmed_reported_cases_and_art.Gender,
	facility.FacilityName,
	facility.County,
	facility.SubCounty,
	partner.PartnerName,
	agency.AgencyName