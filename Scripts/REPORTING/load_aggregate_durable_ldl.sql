IF OBJECT_ID(N'REPORTING.dbo.AggregateLDLDurable', N'U') IS NOT NULL 
	DROP TABLE REPORTING.dbo.AggregateLDLDurable;

with pbfw_patient as (
	select 
		distinct PatientKey
	from NDWH.dbo.factpbfw
),
base_data as (
select
	ART.FacilityKey,
	ART.PartnerKey,
	ART.AgencyKey,
	ART.PatientKey,
	ART.AgeGroupKey,
	'Non PBFW' as PBFWCategory,
	vl.ValidVLResultCategory1 as ValidVLResultCategory,
	IsTXCurr  AS IsTXCurr,
	EligibleVL,
	HasValidVL AS HasValidVL
from NDWH.dbo.FactART  ART 
left join NDWH.dbo.FactViralLoads vl on vl.patientkey=ART.Patientkey
left join NDWH.dbo.DimPatient pat ON pat.PatientKey = vl.PatientKey
where IsTXCurr = 1 
	and vl.PatientKey not in (select PatientKey from pbfw_patient)  /*ommit pbfw patients */
union
select
	pbfw.FacilityKey,
	pbfw.PartnerKey,
	pbfw.AgencyKey,
	pbfw.PatientKey,
	pbfw.AgeGroupKey,
	case 
		when Newpositives = 1 then 'New Positives'
		else 'Known Positives'
	end as PBFWCategory,
	vl.PBFW_ValidVLResultCategory as ValidVLResultCategory,
	patient.IsTXCurr  AS IsTXCurr,
	EligibleVL,
	PBFW_ValidVL as HasValidVL
from NDWH.dbo.factpbfw as pbfw
left join NDWH.dbo.FactViralLoads as vl on vl.PatientKey = pbfw.Patientkey
left join NDWH.dbo.DimPatient as patient on patient.PatientKey = pbfw.PatientKey
where IsTXCurr = 1
),
eligible_for_two_vl_tests as (
		/*less than 25 years and not part of pbfw */
		select 
			art.PatientKey
		from NDWH.dbo.FACTART as art
		left join NDWH.dbo.DimAgeGroup as agegroup on agegroup.AgeGroupKey = art.AgeGroupKey
		left join NDWH.dbo.DimDate as start_date on start_date.DateKey = art.StartARTDateKey
		where agegroup.Age < 25 
			and datediff(month, start_date.Date, eomonth(dateadd(mm,-1,getdate()))) >= 9
			and art.PatientKey not in (select PatientKey from pbfw_patient)  /*ommit pbfw patients */
	union 
		/* 25 and above years and not part of pbfw */ 
		select 
			art.PatientKey
		from NDWH.dbo.FACTART as art
		left join NDWH.dbo.DimAgeGroup as agegroup on agegroup.AgeGroupKey = art.AgeGroupKey
		left join NDWH.dbo.DimDate as start_date on start_date.DateKey = art.StartARTDateKey
		where agegroup.Age >= 25 
			and datediff(month, start_date.Date, eomonth(dateadd(mm,-1,getdate()))) >= 12
		and art.PatientKey not in (select PatientKey from pbfw_patient)  /*ommit pbfw patients */
	union
		/*pbfw */
		select 
			art.PatientKey
		from NDWH.dbo.FACTART as art
		inner join pbfw_patient as pbfw on pbfw.patientkey = art.PatientKey
		left join NDWH.dbo.DimDate as start_date on start_date.DateKey = art.StartARTDateKey
			and datediff(month, start_date.Date, eomonth(dateadd(mm,-1,getdate()))) >= 9
),
two_consecutive_tests_within_the_year as (
	select
		eligible_for_two_vl_tests.PatientKey,
		vl.LatestVL1,
		vl1Date.Date as LatestVLDate1,
		vl.LatestVL2,
		vl2Date.Date as LatestVLDate2
	from eligible_for_two_vl_tests
	inner join NDWH.dbo.FactViralLoads as vl on vl.PatientKey =eligible_for_two_vl_tests.PatientKey
	inner join NDWH.dbo.DimDate as vl2Date on vl2Date.DateKey = vl.LatestVLDate2Key
	inner join NDWH.dbo.DimDate as vl1Date on vl1Date.DateKey = vl.LatestVLDate1Key
	where datediff(month, vl2Date.Date, eomonth(dateadd(mm,-1,getdate()))) <= 12  /* make sure the second last vl is within 12 months */
		and concat(LatestVL1,LatestVLDate1Key) <> concat(LatestVL2,LatestVLDate2Key) /* clean up to ommit duplicate entries on same day */
),
durable_LDL as (
	select 
		Patientkey,
		LatestVL1,
		LatestVL2
	from two_consecutive_tests_within_the_year
	where (isnumeric(LatestVL2) = 1 and  cast(replace(LatestVL2, ',', '') as  float) < 50.00  or
		LatestVL2 in ('undetectable','NOT DETECTED','0 copies/ml','LDL','Less than Low Detectable Level'))
	and 
		(isnumeric(LatestVL1) = 1 and  cast(replace(LatestVL1, ',', '') as  float) < 50.00  or
		LatestVL1 in ('undetectable','NOT DETECTED','0 copies/ml','LDL','Less than Low Detectable Level'))
)
select 
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	pat.Gender,
	g.DATIMAgeGroup as AgeGroup,
	PBFWCategory,
	ValidVLResultCategory,
	sum(base_data.IsTXCurr) as TXCurr,
	sum(EligibleVL) as EligibleVL,
	sum(HasValidVL) as HasValidVL,
	sum(case when eligible_for_two_vl_tests.PatientKey is not null then 1 else 0 end) as CountEligibleForTwoVLTests,
	sum(case when two_consecutive_tests_within_the_year.PatientKey is not null then 1 else 0 end) as CountTwoConsecutiveTestsWithinTheYear,
    sum(
        case when (isnumeric(two_consecutive_tests_within_the_year.LatestVL1) = 1 and cast(replace(two_consecutive_tests_within_the_year.LatestVL1, ',', '') as  float) < 50.00 ) or
		    (two_consecutive_tests_within_the_year.LatestVL1 in ('undetectable','NOT DETECTED','0 copies/ml','LDL','Less than Low Detectable Level')) then 1 else 0 end) as CountLDLLastOneTest,
    sum(case when durable_LDL.PatientKey is not null then 1 else 0 end) as CountDurableLDL
into REPORTING.dbo.AggregateLDLDurable
from base_data
left join eligible_for_two_vl_tests on eligible_for_two_vl_tests.PatientKey = base_data.PatientKey
left join two_consecutive_tests_within_the_year on two_consecutive_tests_within_the_year.PatientKey = base_data.PatientKey
left join durable_LDL on durable_LDL.PatientKey = base_data.PatientKey
left join NDWH.dbo.DimAgeGroup g ON g.AgeGroupKey= base_data.AgeGroupKey
left join NDWH.dbo.DimFacility f ON f.FacilityKey = base_data.FacilityKey
left join NDWH.dbo.DimAgency a ON a.AgencyKey = base_data.AgencyKey
left join NDWH.dbo.DimPatient pat ON pat.PatientKey = base_data.PatientKey
left join NDWH.dbo.DimPartner p ON p.PartnerKey = base_data.PartnerKey
group by  
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	pat.Gender,
	g.DATIMAgeGroup,
	PBFWCategory,
	ValidVLResultCategory;