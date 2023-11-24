IF OBJECT_ID(N'[NDWH].[dbo].[FactIITRiskScores]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FactIITRiskScores];
BEGIN


with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
        SDP_Agency as Agency
	from ODS.dbo.All_EMRSites 
),
iit_risk_scores_ordering as (
    select
        scores.PatientPK,
        scores.PatientPKHash,
        scores.SiteCode,
        cast(scores.RiskEvaluationDate as date) as RiskEvaluationDate,
        scores.RiskScore,
        case 
            when cast(scores.RiskScore as decimal(9,2)) >= 0.0 and scores.RiskScore <= 0.04587387 then 'Low'
            when cast(scores.RiskScore as decimal(9,2)) >= 0.04587388 and scores.RiskScore <= 0.1458252 then 'Medium'
            when cast(scores.RiskScore as decimal(9, 2)) >= 0.1458253  and scores.RiskScore <= 1.0 then 'High'
        end as RiskCategory,
        row_number() over (partition by scores.PatientPK, scores.SiteCode order by scores.RiskEvaluationDate desc) as rank
    from ODS.dbo.CT_IITRiskScores as scores 
    left join ODS.dbo.CT_Patient as patient on patient.PatientPK = scores.PatientPK
        and patient.SiteCode = scores.PatientPK
),
appointments_from_last_visit as (
    select 
        PatientPK,
        SiteCode,
        LastVisitDate,
        NextAppointment
    from ODS.dbo.Intermediate_LastVisitDate
)
select 
    Factkey = IDENTITY(INT, 1, 1),
    patient.PatientKey,
    facility.FacilityKey,
    partner.PartnerKey,
    agency.AgencyKey,
    agegroup.AgeGroupKey,
    evaluation.DateKey as RiskEvaluationDateKey,
    appointment.DateKey as LastVisitAppointmentGivenDateKey,
    RiskScore as LatestRiskScore,
    RiskCategory as LastestRiskCategory
into NDWH.dbo.FactIITRiskScores
from iit_risk_scores_ordering as risk_scores
left join NDWH.dbo.DimPatient as patient on patient.PatientPKHash = risk_scores.PatientPKHash
    and patient.SiteCode = risk_scores.SiteCode
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = risk_scores.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = risk_scores.SiteCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency 
left join NDWH.dbo.DimDate as evaluation on evaluation.Date = risk_scores.RiskEvaluationDate
left join NDWh.dbo.DimAgeGroup as agegroup on agegroup.Age = datediff(yy, patient.DOB, risk_scores.RiskEvaluationDate)
left join appointments_from_last_visit on appointments_from_last_visit.PatientPK = risk_scores.PatientPK
    and appointments_from_last_visit.SiteCode = risk_scores.SiteCode
left join NDWH.dbo.DimDate as appointment on appointment.Date = appointments_from_last_visit.NextAppointment
where rank = 1 and patient.voided = 0

alter table NDWH.dbo.FactIITRiskScores add primary key(FactKey)

END