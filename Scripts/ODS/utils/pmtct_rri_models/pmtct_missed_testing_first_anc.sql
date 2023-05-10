IF EXISTS(SELECT * FROM PMTCTRRI.sys.objects WHERE object_id = OBJECT_ID(N'PMTCTRRI.[dbo].[MissedTestingFirstANC]') AND type in (N'U')) 
Drop TABLE PMTCTRRI.[dbo].MissedTestingFirstANC
Go
BEGIN

with facility_data as (
 select
    distinct MFL_Code,
    Facility_Name,
    SDP,
    SDP_Agency as Agency,
    County,
    SubCounty,
    case 
        when EMR in ('KenyaEMR',' IQCare-KeHMIS','AMRS','DREAMSOFTCARE','ECare','kenyaEMR') Then 'EMR Based'
        When EMR in ('No EMR','No-EMR','NonEMR') Then 'Paper Based' Else 'Unclassified' 
    End as Facilitytype
from ODS.dbo.All_EMRSites
),
visits_ordering as (
select
 COUNT(DISTINCT CONCAT(PatientPK,'-',SiteCode)) AS FirstANC,
    PatientPK,
    SiteCode,
    VisitDate
from PMTCT_STG.dbo.MNCH_AncVisits
where ANCVisitNo=1
group by 
    PatientPK,
    SiteCode,
    VisitDate
from PMTCT_STG.dbo.MNCH_AncVisits
),
first_anc_visits_summary as (
    select
        SiteCode, 
        concat(year(VisitDate), '-', month(VisitDate)) as YearMonth,
        count(concat(PatientPK,SiteCode)) as NoOfMothers
    from visits_ordering
    group by 
        SiteCode, 
        concat(year(VisitDate), '-', month(VisitDate))
),
tested_hiv_clients_visits_ordering as (
    select
        COUNT(DISTINCT CONCAT(PatientPK,'-',SiteCode)) AS MothersTested,
        PatientPK,
        SiteCode,
        VisitDate
    from PMTCT_STG.dbo.MNCH_AncVisits
    where HIVTestingDone = 'Yes' and ANCVisitNo=1
    Group by 
    PatientPK,
    SiteCode,
    VisitDate
),
hiv_testing_summary as (
select
    SiteCode, 
    concat(year(VisitDate), '-', month(VisitDate)) as YearMonth,
    count(concat(PatientPK,SiteCode)) as NoOfMothersTested
from tested_hiv_clients_visits_ordering
group by 
    SiteCode, 
    concat(year(VisitDate), '-', month(VisitDate))
),
tested_syphillis_clients_visits_ordering as (
    select
        COUNT(DISTINCT CONCAT(PatientPK,'-',SiteCode)) AS SyphilisTested,
        PatientPK,
        SiteCode,
        VisitDate
    from PMTCT_STG.dbo.MNCH_AncVisits
    where SyphilisTestDone = 'Yes'
),
tested_syphillis_summary as (
    select
        SiteCode, 
        concat(year(VisitDate), '-', month(VisitDate)) as YearMonth,
        count(concat(PatientPK,SiteCode)) as NoOfMothersTested
    from tested_syphillis_clients_visits_ordering
    group by 
        SiteCode, 
        concat(year(VisitDate), '-', month(VisitDate))
),
joined_data as (
select 
     first_anc_visits_summary.SiteCode,
     first_anc_visits_summary.YearMonth,
     first_anc_visits_summary.NoOfMothers,
     coalesce(cast(hiv_testing_summary.NoOfMothersTested as float), 0) as NoOfMothersHIVTested,
     coalesce(cast(tested_syphillis_summary.NoOfMothersTested as float), 0) as NoOfMothersSyphillisTested
from first_anc_visits_summary
left join hiv_testing_summary on first_anc_visits_summary.SiteCode = hiv_testing_summary.SiteCode
    and first_anc_visits_summary.YearMonth = hiv_testing_summary.YearMonth
left join tested_syphillis_summary on first_anc_visits_summary.SiteCode = tested_syphillis_summary.SiteCode
    and first_anc_visits_summary.YearMonth = tested_syphillis_summary.YearMonth
),
final_indicators as (
select 
    joined_data.*,
    NoOfMothers - NoOfMothersHIVTested as MissedHIVTesting,
    NoOfMothers - NoOfMothersSyphillisTested as MissedSyphillistesting,
    round(NoOfMothersHIVTested/NoOfMothers,2) as ProportionOfMothersTestedHIV,
    round(NoOfMothersSyphillisTested/NoOfMothers, 2) as ProportionOfMothersTestedSyphillis
from joined_data
)
select 
    facility_data.Facility_Name,
    facility_data.County,
    facility_data.SubCounty,
    facility_data.SDP,
    facility_data.Agency,
    facility_data.Facilitytype,
    final_indicators.*
into PMTCTRRI.dbo.MissedTestingFirstANC
from final_indicators
left join facility_data on facility_data.MFL_Code = final_indicators.SiteCode
order by SiteCode

END


