IF OBJECT_ID(N'[NDWH].[dbo].[FactHTSClientTests]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FactHTSClientTests];

BEGIN

with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency collate Latin1_General_CI_AS as Agency
	from ODS.dbo.All_EMRSites 
),
client_linkage_data as (
    select 
        Sitecode,
        PatientPk,
        DateEnrolled,
        ReportedCCCNumber,
        row_number() over(partition by Sitecode,PatientPK order by DateEnrolled desc) as row_num 
    from ODS.dbo.HTS_ClientLinkages 
)
select     
    patient.PatientKey,
    facility.FacilityKey,
	partner.PartnerKey,
	agency.AgencyKey,
    age_group.AgeGroupKey,
    datediff(yy, patient.DOB, last_encounter.TestDate) as AgeAtTesting,
    testing.DateKey as DateTestedKey,
    EverTestedForHiv,
    MonthsSinceLastTest,
    ClientTestedAs,
    EntryPoint,
    TestStrategy,
    TestResult1,
    TestResult2,
    FinalTestResult,
    PatientGivenResult,
    TestType,
    TBScreening,
    ClientSelfTested,
    CoupleDiscordant
    Consent,
    EncounterId,
    case when FinalTestResult is not null then 1 else 0 end as Tested,
    case when FinalTestResult = 'Positive' then 1 else 0 end as Positive,
    case when (FinalTestResult = 'Positive' and client_linkage_data.ReportedCCCNumber is not null) then 1 else 0 end as Linked,
    case 
        when (MonthsSinceLastTest < 3 and MonthsSinceLastTest is not null) then '<3 Months' 
        when (MonthsSinceLastTest >= 3 and MonthsSinceLastTest < 6) then '3-6 Months' 
        when (MonthsSinceLastTest >= 6 and MonthsSinceLastTest < 9) then '6-9 Months' 
        when (MonthsSinceLastTest >= 9 and MonthsSinceLastTest < 12) then '9-12 Months' 
        when (MonthsSinceLastTest >= 12 and MonthsSinceLastTest < 18) then '12-18 Months' 
        when (MonthsSinceLastTest >= 18 and MonthsSinceLastTest < 24) then '18-24 Months' 
        when (MonthsSinceLastTest >= 24 and MonthsSinceLastTest < 36) then '24-36 Months' 
        when (MonthsSinceLastTest >= 36 and (MonthsSinceLastTest < 48)) then '36-48 Months' 
        when (MonthsSinceLastTest >= 48 and MonthsSinceLastTest is not null) then '>48Months' 
    end as MonthsLastTest,
    case 
        when (EverTestedForHiv = 'Yes' and MonthsSinceLastTest < 12) then 'Retest' 
    else 'New' end as TestedBefore
into NDWH.dbo.FactHTSClientTests
from ODS.dbo.Intermediate_EncounterHTSTests as last_encounter
left join NDWH.dbo.DimPatient as patient on patient.PatientPK = convert(nvarchar(64), hashbytes('SHA2_256', cast(last_encounter.PatientPK as nvarchar(36))), 2)
    and patient.SiteCode = last_encounter.SiteCode
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = last_encounter.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = last_encounter.SiteCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.dbo.DimAgeGroup as age_group on age_group.Age =  datediff(yy, patient.DOB, last_encounter.TestDate)
left join NDWH.dbo.DimDate as testing on testing.Date = cast(last_encounter.TestDate as date)
left join  client_linkage_data on client_linkage_data.PatientPk = last_encounter.PatientPK
    and client_linkage_data.SiteCode = last_encounter.SiteCode
    and client_linkage_data.row_num = 1

END