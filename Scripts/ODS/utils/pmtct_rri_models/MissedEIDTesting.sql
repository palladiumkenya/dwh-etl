
IF EXISTS(SELECT * FROM PMTCTRRI.sys.objects WHERE object_id = OBJECT_ID(N'PMTCTRRI.[dbo].[[MissedInfantProphylaxis]]') AND type in (N'U')) 
Drop TABLE PMTCTRRI.[dbo].[MissedInfantProphylaxis]
GO


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
        when emr.EMR in ('KenyaEMR',' IQCare-KeHMIS','AMRS','DREAMSOFTCARE','ECare','kenyaEMR') Then 'EMR Based'
        When emr.EMR in ('No EMR','No-EMR','NonEMR','Ushauri') Then 'Paper Based' Else 'Unclassified' 
    End as Facilitytype
from ODS.dbo.All_EMRSites emr 
left join PMTCT_STG.dbo.MNCH_Patient as pat on emr.MFL_Code=pat.SiteCode
),
anc_visits_ordering as (
select distinct 
    anc.PatientPK,
    anc.SiteCode,
    VisitDate, 
    HIVTestFinalResult,  
    NVPBabyDispense,
    AZTBabyDispense
from PMTCT_STG.dbo.MNCH_AncVisits as anc
left join PMTCT_STG.dbo.MNCH_Arts as art on anc.PatientPK = art.PatientPK
    and anc.SiteCode =  art.SiteCode
where HIVTestFinalResult = 'Positive' and ANCVisitNo=1
),
first_anc_positive_visits as (
    select
        anc_visits_ordering.*,
        concat(year(VisitDate), '-', month(VisitDate)) as period
    from anc_visits_ordering
  
),
enriched_first_anc_positive_visits as (
    select 
        first_anc_positive_visits.*,
        case when art.StartARTDate < first_anc_positive_visits.VisitDate then 1 else 0 end as KnownPositive,
        case when art.StartARTDate >= first_anc_positive_visits.VisitDate then 1 else 0 end As New 
    from first_anc_positive_visits
    left join PMTCT_STG.dbo.MNCH_Arts as art on first_anc_positive_visits.PatientPK = art.PatientPK
    and first_anc_positive_visits.SiteCode = art.SiteCode
),
hiv_positive as (
        select 
            PatientPK,
            sitecode ,
            VisitDate,
            HIVTestFinalResult,
            AZTBabyDispense as BabyGivenProphylaxis
        from PMTCT_STG.dbo.MNCH_AncVisits
        where HIVTestFinalResult = 'Positive'
    union
        select 
            PatientPK,
            sitecode ,
            VisitDate,
            HIVTestFinalResult,
            NVPBabyDispense as BabyGivenProphylaxis
        from PMTCT_STG.dbo.MNCH_AncVisits
        where HIVTestFinalResult = 'Positive'
    union
        select
            PatientPK,
            sitecode ,
            VisitDate,
            HIVTestFinalResult,
            InfantProphylaxisGiven as BabyGivenProphylaxis
        from PMTCT_STG.dbo.MNCH_PncVisits
        where HIVTestFinalResult = 'Positive' 
    union 
        select
            PatientPK,
            sitecode,
            VisitDate,
            HIVTestFinalResult,
            BabyGivenProphylaxis
        from PMTCT_STG.dbo.MNCH_MatVisits
        where HIVTestFinalResult = 'Positive'
),
visits_ordering as (
    select
        row_number() over (partition by SiteCode,PatientPK order by VisitDate asc) as num ,
        PatientPK,
        Sitecode,
        Visitdate,
        concat(year(VisitDate), '-', month(VisitDate)) as period,
        HIVTestFinalResult,
        BabyGivenProphylaxis
 from hiv_positive  
),
first_visit as (
select 
    *
from visits_ordering
where num = 1
),
positive_mothers_summary as (
    select 
        SiteCode,
        period,
        count(concat(PatientPK,SiteCode)) as NoOfPositiveMothers
    from first_visit
    group by 
        SiteCode,
        period
),
given_infant_prophylaxis_summary as (
    select 
        SiteCode,
        period,
        count(concat(PatientPK,SiteCode)) as NoOfInfantsGivenProphylaxis
    from first_visit
    where BabyGivenProphylaxis = 'Yes'
    group by 
        SiteCode,
        period
),
anc_not_given_infant_prophylaxis_known_positives_summary as (
    select
        SiteCode,
        period,
        count(concat(PatientPK,SiteCode)) as NoOfInfantsNotGivenProphylaxis
    from enriched_first_anc_positive_visits
    where (NVPBabyDispense = 'No' or AZTBabyDispense = 'No') and KnownPositive = 1
    group by 
        SiteCode,
        period
),
anc_not_given_infant_prophylaxis_new_positives_summary as (
    select
        SiteCode,
        period,
        count(concat(PatientPK,SiteCode)) as NoOfInfantsNotGivenProphylaxis
    from enriched_first_anc_positive_visits
    where (NVPBabyDispense = 'No' or AZTBabyDispense = 'No') and New = 1
        group by 
        SiteCode,
        period
),
indicators as (
select
    positive_mothers_summary.SiteCode,
    positive_mothers_summary.period,
    positive_mothers_summary.NoOfPositiveMothers,
    coalesce(given_infant_prophylaxis_summary.NoOfInfantsGivenProphylaxis, 0) as NoOfInfantsGivenProphylaxis,
    NoOfPositiveMothers - coalesce(given_infant_prophylaxis_summary.NoOfInfantsGivenProphylaxis, 0) as NoOfInfantsNotGivenProphylaxis,
    coalesce(anc_not_given_infant_prophylaxis_known_positives_summary.NoOfInfantsNotGivenProphylaxis, 0) as NoOfInfantsNotGivenProphylaxisKnownPosANC,
    coalesce(anc_not_given_infant_prophylaxis_new_positives_summary.NoOfInfantsNotGivenProphylaxis, 0) as NoOfInfantsNotGivenProphylaxisNewPosANC
from positive_mothers_summary
left join given_infant_prophylaxis_summary on given_infant_prophylaxis_summary.SiteCode = positive_mothers_summary.SiteCode
    and given_infant_prophylaxis_summary.period = positive_mothers_summary.period
left join anc_not_given_infant_prophylaxis_known_positives_summary on anc_not_given_infant_prophylaxis_known_positives_summary.SiteCode = positive_mothers_summary.SiteCode
    and anc_not_given_infant_prophylaxis_known_positives_summary.period = positive_mothers_summary.period
left join anc_not_given_infant_prophylaxis_new_positives_summary on anc_not_given_infant_prophylaxis_new_positives_summary.SiteCode = positive_mothers_summary.SiteCode
    and anc_not_given_infant_prophylaxis_new_positives_summary.period = positive_mothers_summary.period
)
select 
    facility_data.Facility_Name,
    facility_data.County,
    facility_data.SubCounty,
    facility_data.SDP,
    facility_data.Agency,
    facility_data.Facilitytype,
    indicators.*
into PMTCTRRI.dbo.MissedInfantProphylaxis
from indicators
left join facility_data on indicators.SiteCode = facility_data.MFL_Code

END

