IF OBJECT_ID(N'[NDWH].[dbo].[FactHEI]', N'U') IS NOT NULL 
DROP TABLE [NDWH].[dbo].[FactHEI];

BEGIN

with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
        SDP_Agency as Agency
	from ODS.dbo.All_EMRSites 
),
pmtct_client_demographics as (
    select 
        PatientPk,
        SiteCode,
        DOB,
        Gender
    from ODS.dbo.MNCH_Patient as patient
),
tested_at_6wks_first_contact as (
    select 
        heis.PatientPk,
        heis.SiteCode,
        datediff(week, DOB, heis.DNAPCR1Date) as age_in_weeks_at_DNAPCR1Date
    from ODS.dbo.MNCH_HEIs as heis
    inner join pmtct_client_demographics as demographics on demographics.PatientPk = heis.PatientPK
        and demographics.SiteCode = heis.SiteCode
    where datediff(week, DOB, heis.DNAPCR1Date) >= 6
),
tested_at_6_months as (
   select 
        heis.PatientPk,
        heis.SiteCode,
        datediff(month, DOB, heis.DNAPCR2Date) as age_in_months_at_DNAPCR2Date
    from ODS.dbo.MNCH_HEIs as heis
    inner join pmtct_client_demographics as demographics on demographics.PatientPk = heis.PatientPK
        and demographics.SiteCode = heis.SiteCode
    where datediff(month, DOB, heis.DNAPCR2Date) = 6
),
tested_at_12_months as (
    select 
        heis.PatientPk,
        heis.SiteCode,
        datediff(month, DOB, heis.DNAPCR2Date) as age_in_months_at_DNAPCR2Date
    from ODS.dbo.MNCH_HEIs as heis
    inner join pmtct_client_demographics as demographics on demographics.PatientPk = heis.PatientPK
        and demographics.SiteCode = heis.SiteCode
    where datediff(month, DOB, heis.DNAPCR2Date) = 12
),
initial_PCR_less_than_8wks as (
    select 
        heis.PatientPk,
        heis.SiteCode,
        datediff(week, DOB, heis.DNAPCR1Date) as age_in_weeks_at_DNAPCR1Date,
        DOB,
        heis.DNAPCR1Date
    from ODS.dbo.MNCH_HEIs as heis
    inner join pmtct_client_demographics as demographics on demographics.PatientPk = heis.PatientPK
        and demographics.SiteCode = heis.SiteCode
    where datediff(week, DOB, heis.DNAPCR1Date) > 0 and datediff(week, DOB, heis.DNAPCR1Date) < 8
),
initial_PCR_btwn_8wks_12mnths as (
    select 
        heis.PatientPk,
        heis.SiteCode,
        datediff(week, DOB, heis.DNAPCR1Date) as age_in_weeks_at_DNAPCR1Date,
        DOB,
        heis.DNAPCR1Date
    from ODS.dbo.MNCH_HEIs as heis
    inner join pmtct_client_demographics as demographics on demographics.PatientPk = heis.PatientPK
        and demographics.SiteCode = heis.SiteCode
    where datediff(week, DOB, heis.DNAPCR1Date) >=8 and datediff(week, DOB, heis.DNAPCR1Date) <= 48
),
final_antibody_data as (
    select 
        heis.PatientPk,
        heis.SiteCode,
        FinalyAntibody,
        FinalyAntibodyDate
    from ODS.dbo.MNCH_HEIs as heis
    where FinalyAntibody is not null
),
cwc_visits_ordering as (
    select 
        PatientPk,
        SiteCode,
        VisitDate,
        InfantFeeding,
        MedicationGiven,
        row_number() over (partition by SiteCode,PatientPK order by VisitDate desc) as num
    from ODS.dbo.MNCH_CwcVisits as visits
),
latest_cwc_visit as (
    select
        *
    from cwc_visits_ordering
    where num = 1
),
feeding_data as (
    select 
        heis.PatientPk,
        heis.SiteCode,
        latest_cwc_visit.InfantFeeding,
        datediff(month, DOB, latest_cwc_visit.VisitDate) as age_in_months_as_last_cwc_visit
    from ODS.dbo.MNCH_HEIs as heis
    inner join latest_cwc_visit on latest_cwc_visit.PatientPK = heis.PatientPK
        and latest_cwc_visit.SiteCode = heis.Sitecode
    inner join pmtct_client_demographics on pmtct_client_demographics.PatientPk = heis.PatientPk
        and pmtct_client_demographics.SiteCode = heis.SiteCode
),
positive_heis as (
    select 
        heis.PatientPK,
        heis.SiteCode,
        HEIExitCritearia,
        HEIHIVStatus
    from ODS.dbo.MNCH_HEIs as heis
    where HEIHIVStatus = 'Positive' 
),
unknown_status_24_months as (
    select
        heis.PatientPK,
        heis.SiteCode,
        heis.FinalyAntibody,
        datediff(month, DOB, getdate()) as current_age_in_months
    from ODS.dbo.MNCH_HEIs as heis
    inner join pmtct_client_demographics on pmtct_client_demographics.PatientPk = heis.PatientPk
        and pmtct_client_demographics.SiteCode = heis.SiteCode
    where heis.FinalyAntibody is null or heis.FinalyAntibody = ''
        and datediff(month, DOB, getdate()) >= 24
),
infected_and_ART as (
    select 
        heis.PatientPK,
        heis.SiteCode,
        HEIExitCritearia,
        HEIHIVStatus,
        StartARTDate
    from ODS.dbo.MNCH_HEIs as heis
    inner join ODS.dbo.CT_ARTPatients as art on art.PatientPK = heis.PatientPk
        and art.SiteCode = heis.SiteCode
    where HEIHIVStatus = 'Positive' and art.StartARTDate is not null
),
Mothers as (
    select
        Patientpk,
        sitecode,
        row_number() OVER (PARTITION BY SiteCode, PatientPK ORDER BY VisitDate DESC) AS num
    FROM ODS.dbo.MNCH_AncVisits
    WHERE AZTBabyDispense IS NOT NULL OR NVPBabyDispense IS NOT NULL
),
prophylaxis_data as (SELECT
    Patientpk,
    Sitecode,
    ''Babypatientpk
FROM Mothers
WHERE num = 1

UNION

SELECT
    Patientpk,
    sitecode,
    ''Babypatientpk
FROM ODS.dbo.MNCH_PncVisits
WHERE InfantProphylaxisGiven = 'Yes'

union
 SELECT
    mat.Patientpk,
    mat.sitecode,
    Babypatientpk
FROM ODS.dbo.MNCH_MatVisits as mat
left join ODS.dbo.mnch_motherbabypairs as pair on pair.PatientPk=mat.patientpk and pair.sitecode=mat.sitecode
WHERE BabyGivenProphylaxis = 'Yes'
)
select
    FactKey = IDENTITY(INT, 1, 1),
    patient.PatientKey,
    facility.FacilityKey,
    partner.PartnerKey,
    agency.AgencyKey,
    DNAPCR1.DateKey as DNAPCR1DateKey ,
    DNAPCR2.DateKey as DNAPCR2DateKey,
    antiboday_date.DateKey as FinalyAntibodyDateKey,
    age_group.AgeGroupKey,
    case 
        when tested_at_6wks_first_contact.age_in_weeks_at_DNAPCR1Date is not null then 1 
        else 0
    end as TestedAt6wksOrFirstContact,
    case 
        when tested_at_6_months.age_in_months_at_DNAPCR2Date is not null then 1 
        else 0
    end as TestedAt6months,
    case 
        when tested_at_12_months.age_in_months_at_DNAPCR2Date is not null then 1
        else 0 
    end as TestedAt12months,
    case 
        when initial_PCR_less_than_8wks.age_in_weeks_at_DNAPCR1Date is not null then 1
        else 0
    end as InitialPCRLessThan8wks,
    case 
        when initial_PCR_btwn_8wks_12mnths.age_in_weeks_at_DNAPCR1Date is not null then 1 
        else 0
    end as InitialPCRBtwn8wks_12mnths,
    case 
        when final_antibody_data.FinalyAntibody is not null then 1 
        else 0
    end as HasFinalAntibody,
    final_antibody_data.FinalyAntibodyDate,
    case 
        when feeding_data.age_in_months_as_last_cwc_visit = 6 and feeding_data.InfantFeeding in ('Exclusive Breastfeeding(EBF)', 'EBF') then 1
        else 0
    end as EBF6mnths,
    case 
        when feeding_data.age_in_months_as_last_cwc_visit = 6 and feeding_data.InfantFeeding in ('Exclusive Replacement(ERF)', 'ERF') then 1
        else 0
    end as ERF6mnths,
    case 
        when feeding_data.age_in_months_as_last_cwc_visit = 12 and feeding_data.InfantFeeding in ('BF') then 1
        else 0
    end as BF12mnths,
    case 
        when feeding_data.age_in_months_as_last_cwc_visit = 18 and feeding_data.InfantFeeding in ('BF') then 1
        else 0
    end as BF18mnths,
    case 
        when infected_and_ART.StartARTDate is not null then 1 
        else 0 
    end as InfectedOnART,
    case 
        when positive_heis.HEIHIVStatus is not null then 1 
        else 0
    end as InfectedAt24mnths,
    positive_heis.HEIExitCritearia as HEIExitCriteria,
    positive_heis.HEIHIVStatus,
    case 
        when prophylaxis_data.Babypatientpk is not null then 1 
        else 0
    end as OnProhylaxis,
    case 
        when unknown_status_24_months.PatientPk is not null then 1 
        else 0
    end as  UnknownOutocomeAt24months
into NDWH.dbo.FactHEI
from ODS.dbo.MNCH_HEIs as heis
left join tested_at_6wks_first_contact on tested_at_6wks_first_contact.PatientPk = heis.PatientPk
    and tested_at_6wks_first_contact.SiteCode = heis.SiteCode
left join tested_at_6_months on tested_at_6_months.PatientPk = heis.PatientPk
    and tested_at_6_months.SiteCode = heis.SiteCode
left join tested_at_12_months on tested_at_12_months.PatientPk = heis.PatientPk
    and tested_at_12_months.SiteCode = heis.SiteCode
left join initial_PCR_less_than_8wks on initial_PCR_less_than_8wks.PatientPk = heis.PatientPk
    and initial_PCR_less_than_8wks.SiteCode = heis.SiteCode
left join initial_PCR_btwn_8wks_12mnths on initial_PCR_btwn_8wks_12mnths.PatientPK = heis.PatientPk
    and initial_PCR_btwn_8wks_12mnths.SiteCode = heis.SiteCode
left join final_antibody_data on final_antibody_data.PatientPk = heis.PatientPk
    and final_antibody_data.SiteCode = heis.SiteCode
left join feeding_data on feeding_data.PatientPk = heis.PatientPk
    and feeding_data.SiteCode = heis.SiteCode
left join infected_and_ART on infected_and_ART.PatientPk = heis.PatientPk
    and infected_and_ART.SiteCode = heis.SiteCode
left join positive_heis on positive_heis.PatientPk = heis.PatientPk
    and positive_heis.SiteCode = heis.SiteCode
left join prophylaxis_data on prophylaxis_data.PatientPk = heis.PatientPk
    and prophylaxis_data.SiteCode = heis.SiteCode
left join unknown_status_24_months on unknown_status_24_months.PatientPk = heis.PatientPk
    and unknown_status_24_months.SiteCode = heis.SiteCode
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = heis.SiteCode
left join latest_cwc_visit on latest_cwc_visit.PatientPk = heis.PatientPk
    and latest_cwc_visit.SiteCode =heis.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = heis.SiteCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.dbo.DimPatient as patient on patient.PatientPKHash = heis.PatientPKHash 
    and patient.SiteCode = heis.SiteCode
left join NDWH.dbo.DimDate as DNAPCR1 on DNAPCR1.Date = cast(heis.DNAPCR1Date as date)
left join NDWH.dbo.DimDate as DNAPCR2 on DNAPCR2.Date = cast(heis.DNAPCR2Date as date)
left join NDWH.dbo.DimDate as antiboday_date on antiboday_date.Date = cast(final_antibody_data.FinalyAntibodyDate as date)
left join NDWH.dbo.DimAgeGroup as age_group on age_group.Age =  datediff(yy, patient.DOB, coalesce(latest_cwc_visit.VisitDate, getdate()))
WHERE patient.voided =0;

alter table NDWH.dbo.FactHEI add primary key(FactKey);

END