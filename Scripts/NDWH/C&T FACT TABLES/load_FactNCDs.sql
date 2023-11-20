IF OBJECT_ID(N'[NDWH].[dbo].[FactNCD]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FactNCD]

GO

BEGIN

with ncd_source_data as (
    select 
        *
    from (
            select 
                distinct 
                case 
                    when value = 'Alzheimers Disease and other Dementias' then 'Alzheimer''s Disease and other Dementias' 
                    else value 
                end as value,
                PatientPKHash,
                PatientPK,               
                SiteCode              
            from ODS.dbo.CT_AllergiesChronicIllness  as chronic  
                cross apply STRING_SPLIT(chronic.ChronicIllness, '|')
            ) as chronic 
            pivot(
                count(value)
                for value IN (
                    "Alzheimers Disease and other Dementias",
                    "Alzheimer's Disease and other Dementias",
                    "Arthritis",
                    "Asthma",
                    "Cancer",
                    "Cardiovascular diseases",
                    "Chronic Hepatitis",
                    "Chronic Kidney Disease",
                    "Chronic Obstructive Pulmonary Disease(COPD)",
                    "Chronic Renal Failure",
                    "Cystic Fibrosis",
                    "Deafness and Hearing Impairment",
                    "Diabetes",
                    "Endometriosis",
                    "Epilepsy",
                    "Glaucoma",
                    "Heart Disease",
                    "Hyperlipidaemia",
                    "Hypertension",
                    "Hypothyroidism",
                    "Mental illness",
                    "Multiple Sclerosis",
                    "Obesity",
                    "Osteoporosis",
                    "Sickle Cell Anaemia",
                    "Thyroid disease"
                )
            ) as pivot_table
),
MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency as Agency 
	from ODS.dbo.All_EMRSites 
),
diabetes_tests_ordering as (
    /* get all Diabetes tests and order by date*/
    SELECT 
        ROW_NUMBER() OVER (PARTITION BY PatientPKHash, Sitecode ORDER BY OrderedbyDate DESC) AS RowNum,
        PatientPKHash,
        SiteCode,
        TestName,
        TRY_CAST(TestResult AS NUMERIC(18, 2)) AS NumericTestResult
    FROM ODS.dbo.CT_PatientLabs
    WHERE 
        TestName in ('HgB', 'HbsAg', 'HBA1C') 
            or TestName in ('FBS', 'Blood Sugar')
        
),
latest_diabetes_test as  (
 select 
    *
 from diabetes_tests_ordering where RowNum = 1
),
latest_diabetes_test_controlled as (
    /* get all last Diabetes tests that are within the controlled range*/
    select 
        * 
    from latest_diabetes_test
    where (TestName IN ('HgB', 'HbsAg', 'HBA1C') AND NumericTestResult <= 6.5)
        or (TestName IN ('FBS', 'Blood Sugar') AND NumericTestResult < 7.0)
),
visits_ordering as (
    select 
        PatientPKHash,
        PatientPK,               
        SiteCode,
        VisitDate,
        row_number() over (partition by PatientPK, Sitecode order by VisitDate desc) as rank
    from ODS.dbo.CT_AllergiesChronicIllness as chronic
),
age_as_of_last_visit as (
    select 
        visits_ordering.PatientPKHash,
        visits_ordering.PatientPK,               
        visits_ordering.SiteCode,
        datediff(yy, patient.DOB, coalesce(visits_ordering.VisitDate, getdate() )) As  AgeLastVisit
    from visits_ordering
    inner join ODS.dbo.CT_Patient as patient on patient.PatientPKHash = visits_ordering.PatientPKHash 
	and patient.SiteCode = visits_ordering.SiteCode
    where rank = 1
)
select
    Factkey = IDENTITY(INT, 1, 1),
    patient.PatientKey,
    facility.FacilityKey,
    partner.PartnerKey,
    agency.AgencyKey,
    age_group.AgeGroupKey,
    ncd_source_data."Alzheimer's Disease and other Dementias",
    ncd_source_data."Arthritis",
    ncd_source_data."Asthma",
    ncd_source_data."Cancer",
    ncd_source_data."Cardiovascular diseases",
    ncd_source_data."Chronic Hepatitis",
    ncd_source_data."Chronic Kidney Disease",
    ncd_source_data."Chronic Obstructive Pulmonary Disease(COPD)",
    ncd_source_data."Chronic Renal Failure",
    ncd_source_data."Cystic Fibrosis",
    ncd_source_data."Deafness and Hearing Impairment",
    ncd_source_data."Diabetes",
    ncd_source_data."Endometriosis",
    ncd_source_data."Epilepsy",
    ncd_source_data."Glaucoma",
    ncd_source_data."Heart Disease",
    ncd_source_data."Hyperlipidaemia",
    ncd_source_data."Hypertension",
    ncd_source_data."Hypothyroidism",
    ncd_source_data."Mental illness",
    ncd_source_data."Multiple Sclerosis",
    ncd_source_data."Obesity",
    ncd_source_data."Osteoporosis",
    ncd_source_data."Sickle Cell Anaemia",
    ncd_source_data."Thyroid disease",
    case when latest_diabetes_test.PatientPKHash is not null then 1 else 0 end as ScreenedDiabetes,
    case when latest_diabetes_test_controlled.PatientPKHash is not null then 1 else 0 end as IsDiabetesControlledAtLastTest,
    coalesce(visit.ScreenedBPLastVisit,0) as ScreenedBPLastVisit,
    coalesce(visit.IsBPControlledAtLastVisit, 0) as IsBPControlledAtLastVisit
into NDWH.dbo.FactNCD
from ncd_source_data
left join latest_diabetes_test on latest_diabetes_test.PatientPKHash = ncd_source_data.PatientPKHash
    and latest_diabetes_test.SiteCode = ncd_source_data.SiteCode
left join latest_diabetes_test_controlled on latest_diabetes_test_controlled.PatientPKHash = ncd_source_data.PatientPKHash
    and latest_diabetes_test_controlled.SiteCode = ncd_source_data.SiteCode
left join NDWH.dbo.DimPatient as patient on patient.PatientPKHash = ncd_source_data.PatientPKHash
    and patient.SiteCode = ncd_source_data.SiteCode
left join ODS.dbo.Intermediate_LastVisitDate as visit on visit.PatientPK = ncd_source_data.PatientPK
    and visit.SiteCode = ncd_source_data.SiteCode
left join age_as_of_last_visit on age_as_of_last_visit.PatientPKHash = ncd_source_data.PatientPKHash
    and age_as_of_last_visit.SiteCode = ncd_source_data.SiteCode
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = ncd_source_data.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = ncd_source_data.SiteCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.dbo.DimAgeGroup as age_group on age_group.Age = age_as_of_last_visit.AgeLastVisit;



alter table NDWH.dbo.FactNCD add primary key(FactKey);

END