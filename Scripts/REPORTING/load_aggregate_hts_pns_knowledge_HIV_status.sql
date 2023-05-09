IF EXISTS(SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.[dbo].[AggregateHTSPNSKnowledgeHIVStatus]') AND type in (N'U')) 
TRUNCATE TABLE REPORTING.[dbo].[AggregateHTSPNSKnowledgeHIVStatus]
GO

with pns_and_tests as ( 
	select distinct 
		pns.PatientKey,
		facility.MFLCode,
        facility.FacilityKey,
        pns.AgencyKey,
        pns.PartnerKey,
        pns.AgeGroupKey,
		pns.ScreenedForIpv,
		pns.CccNumber,
        pns.RelationsipToIndexClient,
        pns.KnowledgeOfHivStatus,
		tests.FinalTestResult,
		pns.DateElicitedKey,
        pns.DateLinkedToCareKey,
		tests.DateTestedKey
	from NDWH.dbo.FactHTSPartnerNotificationServices as pns
    left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = pns.FacilityKey
	left join NDWH.dbo.DimPatient as patient on patient.PatientPKHash = pns.PartnerPatientPk
        and patient.SiteCode = facility.MFLCode
    left join NDWH.dbo.FactHTSClientTests as tests on tests.PatientKey = patient.PatientKey
    where 
        TestType in ('Initial Test', 'Initial') 
),
pns_tests_linkages as ( 
select 
    pns_and_tests.*,
    linkages.ReportedCCCNumber  
from pns_and_tests
left join NDWH.dbo.FactHTSClientLinkages as linkages on linkages.PatientKey = pns_and_tests.PatientKey
),
line_list_dataset as (
	select distinct
        dataset.PatientKey,
		facility.MFLCode,
		facility.FacilityName,
		facility.County,
		facility.SubCounty,
		patner.PartnerName,
		agency.AgencyName,
		RelationsipToIndexClient, 
		FinalTestResult,
		elicited.Date as DateElicited,
		tested.Date as TestDate,
		tested.year,
		tested.month,
		FORMAT(cast(tested.Date as date), 'MMMM') MonthName, 
		Gender,
		DATIMAgeGroup as Agegroup,
		case 
			when (dataset.PatientKey is not null) then 1 
		    else 0 
        end  elicited,
		case 
			when (FinalTestResult is not null ) then 1
		    else 0 
        end as tested,
		case 
			when (FinalTestResult = 'Positive') then 1
		    else 0 
        end  NewPositives, 
		case 
			when (FinalTestResult = 'Negative') then 1
		    else 0 
        end as  NewNegatives,    
		case 
			when (FinalTestResult = 'Positive' and ReportedCCCNumber is not null ) then 1 
		    else 0 
        end  Linked,
		case 
			when (KnowledgeOfHivStatus = 'Positive') then 1 
		    else 0 
        end as  KP,
        case 
			when (KnowledgeOfHivStatus='Unknown') then 1
		    else 0 
        end as  UnknownStatus
	from  pns_tests_linkages as dataset
	left join NDWH.dbo.DimPatient as patient ON patient.PatientKey = dataset.PatientKey
	left join NDWH.dbo.DimPartner as patner ON patner.PartnerKey = dataset.PartnerKey
	left join NDWH.dbo.DimFacility as facility  ON facility.FacilityKey = dataset.FacilityKey
	left join NDWH.dbo.DimAgency agency ON agency.AgencyKey = dataset.AgencyKey	
	left join NDWH.dbo.DimDate as elicited on elicited.DateKey = dataset.DateElicitedKey
	left join NDWH.dbo.DimDate as tested on tested.DateKey = dataset.DateTestedKey
	left join NDWH.dbo.DimDate linked on linked.DateKey = dataset.DateLinkedToCareKey
	left join NDWH.dbo.DimAgeGroup as agegroup on agegroup.AgeGroupKey = dataset.AgeGroupKey
)
insert into REPORTING.dbo.AggregateHTSPNSKnowledgeHIVStatus (
	MFLCode, 
	FacilityName, 
	County, 
	SubCounty, 
	PartnerName, 
	AgencyName, 
	Gender, 
	AgeGroup,
	year, 
	month, 
	MonthName, 
	ContactElicited, 
	ContactTested,
	Linked,
	KnownPositive, 
	NewNegatives,
	NewPositives, 
	UnknownStatus
)
select 
	Mflcode,
	FacilityName,
	County,
	SubCounty,
	PartnerName,
	AgencyName,
	Gender,
	Agegroup,
	year, 
	month, 
	MonthName, 
	sum(elicited) as ContactElicited, 
	sum(tested) as ContactTested,
	sum(Linked) as Linked,
	sum(KP) as KnownPositive, 
	sum(NewNegatives) as NewNegatives,
	sum(NewPositives) as NewPositives, 
	sum(UnknownStatus) as UnknownStatus
from line_list_dataset
group by 
    Mflcode,
    FacilityName,
    County,
    subcounty,
    PartnerName, 
    year,
    month,
    monthName,
    Gender,
    Agegroup, 
    AgencyName