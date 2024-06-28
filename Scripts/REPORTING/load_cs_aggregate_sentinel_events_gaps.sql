IF OBJECT_ID(N'[HIVCaseSurveillance].[dbo].[CsAggegateSentinelEventsGaps]', N'U') IS NOT NULL 
	drop TABLE [HIVCaseSurveillance].[dbo].[CsAggegateSentinelEventsGaps]
GO


with vl_indicators as (
    select 
        distinct PatientKey,
		FacilityKey,
		EligibleVL,
        case 
			when HasValidVL = 0  and EligibleVL = 1 then 1 
			else 0 
		end as InvalidVL,
		case when ValidVLSup = 0  and HasValidVL = 1 then 1 
			else 0
		end as ValidVLUnSupressed
    from NDWH.dbo.FactViralLoads
),
art_indicators as (
    select 
        distinct PatientKey,
        FacilityKey,
		PartnerKey,
		AgencyKey,
		AgeLastVisit,
        case 
			when[StartARTDateKey] is not null then 1 
			else 0
		end as OnART,
		case 
			when outcome.ARTOutcomeDescription = 'DIED' then 1 
			else 0
		end as IsMortality,
		case 
			when outcome.ARTOutcomeDescription IN ('LOSS TO FOLLOW UP', 'UNDOCUMENTED LOSS') then 1 
			else 0
		end as IsIIT,
		case 
			when WhoStage = 4 then 1
			else 0
		end as IsStage4
    from NDWH.dbo.FACTART as art
    left join NDWH.dbo.DimARTOutcome as outcome on outcome.ARTOutcomeKey = art.ARTOutcomeKey
),
prep_turned_positive as (
    select 
        distinct tests.FacilityKey,
		tests.PatientKey
    from NDWH.dbo.FactHTSClientTests as tests
    left join NDWH.dbo.FactPrepAssessments as assessments on assessments.PatientKey = tests.PatientKey
	left join NDWH.dbo.DimPatient as patient on patient.PatientKey = tests.PatientKey
	where FinalTestResult = 'Positive'
        and patient.PrepEnrollmentDateKey is not null
)
select 
	case 
		when eomonth(dim_date.date) is null then cast('1900-01-01' as Date)
		else eomonth(dim_date.date) 
	end as CohortYearMonth,
	agegroup.DATIMAgeGroup as AgeGroup,
	patient.Gender,
	facility.FacilityName,
	facility.County,
	facility.SubCounty,
	partner.PartnerName,
	agency.AgencyName,
	sum(case when patient.DateConfirmedHIVPositiveKey is not null then 1 else 0 end) as ReportedCases,
	sum(OnART) as OnART,
	sum(EligibleVL) as EligibleVL,
	sum(InvalidVL) as InvalidVL,
	sum(ValidVLUnSupressed) as ValidVLUnSupressed,
	sum(IsMortality) as Mortality,
	sum(IsIIT) as IIT,
	sum(IsStage4) as WHOStage4,
	count(distinct prep_turned_positive.PatientKey) as Seroconversion
into [HIVCaseSurveillance].[dbo].[CsAggegateSentinelEventsGaps]
from art_indicators 
left join vl_indicators on vl_indicators.PatientKey = art_indicators.PatientKey
left join NDWH.dbo.DimPatient as patient on patient.PatientKey = art_indicators.PatientKey
left join prep_turned_positive on prep_turned_positive.PatientKey = patient.PatientKey
left join NDWH.dbo.DimDate as dim_date on dim_date.DateKey = patient.DateConfirmedHIVPositiveKey
left join NDWH.dbo.DimAgeGroup as agegroup on agegroup.Age = art_indicators.AgeLastVisit
left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = art_indicators.FacilityKey
left join NDWH.dbo.DimPartner as partner on partner.PartnerKey = art_indicators.PartnerKey
left join NDWH.dbo.DimAgency as agency on agency.AgencyKey = art_indicators.AgencyKey
group by
	case 
		when eomonth(dim_date.date) is null then cast('1900-01-01' as Date)
		else eomonth(dim_date.date) 
	end,
	agegroup.DATIMAgeGroup,
	Gender,
	facility.FacilityName,
	facility.County,
	facility.SubCounty,
	partner.PartnerName,
	agency.AgencyName