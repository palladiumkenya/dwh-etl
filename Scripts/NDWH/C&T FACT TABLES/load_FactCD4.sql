IF OBJECT_ID(N'[NDWH].[dbo].[FactCD4]', N'U') IS NOT NULL 
	DROP TABLE  [NDWH].[dbo].[FactCD4];
BEGIN
with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP   as SDP,
	    SDP_Agency  as Agency
	from ODS.dbo.All_EMRSites 
),
 CD4s as (SELECT 
        ROW_NUMBER() OVER (PARTITION BY PatientPK, Sitecode ORDER BY OrderedbyDate DESC) AS RowNum,
        PatientPKHash,
        PatientPk,
        SiteCode,
		OrderedbyDate,
        TestName,
        TestResult
    FROM ODS.dbo.CT_PatientLabs
    WHERE 
        TestName like '%CD4%'
      ),

	  LatestCD4s as (Select * from CD4s
	  where RowNum=1
	  ),

source_CD4 as (
	select
		distinct baselines.PatientIDHash,
		baselines.PatientPKHash,
		baselines.SiteCode,
		CD4atEnrollment,
		CD4atEnrollment_Date as CD4atEnrollmentDate,
		bCD4 as BaselineCD4,
		bCD4Date as BaselineCD4Date,
		LatestCD4s.OrderedbyDate as LastCD4Date,
        Case When LatestCD4s.TestName='CD4 Count'Then LatestCD4s.TestResult Else Null End as LastCD4,
        Case When LatestCD4s.TestName='CD4 Percentage' Then LatestCD4s.TestResult Else Null End as LastCD4Percentage,
		datediff(yy, patient.DOB, last_encounter.LastEncounterDate) as AgeLastVisit
	from ODS.dbo.CT_PatientBaselines as baselines
	left join ODS.dbo.CT_Patient as patient on patient.PatientPK = baselines.PatientPK
	and patient.SiteCode = baselines.SiteCode
	left join ODS.dbo.Intermediate_LastPatientEncounter as last_encounter on last_encounter.PatientPK = baselines.PatientPK
		and last_encounter.SiteCode = baselines.SiteCode
        left join LatestCD4s on LatestCD4s.PatientPK=baselines.PatientPK and LatestCD4s.Sitecode=baselines.SiteCode
)

select 
	Factkey = IDENTITY(INT, 1, 1),
    patient.PatientKey,
	facility.FacilityKey,
	partner.PartnerKey,
	agency.AgencyKey,
    age_group.AgeGroupKey,
	source_CD4.CD4atEnrollment,
	source_CD4.CD4atEnrollmentDate,
	source_CD4.BaselineCD4,
	source_CD4.BaselineCD4Date,
	source_CD4.LastCD4,
	source_CD4.LastCD4Date,
    source_CD4.LastCD4Percentage,
	 cast(getdate() as date) as LoadDate
into NDWH.dbo.FactCD4
from source_CD4 as source_CD4
left join NDWH.dbo.DimPatient as patient on patient.PatientPKHash = source_CD4.PatientPKHash
    and patient.SiteCode = source_CD4.SiteCode
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = source_CD4.SiteCode
left join NDWH.dbo.DimDate as cd4_enrollment on cd4_enrollment.Date = source_CD4.CD4atEnrollmentDate
left join NDWH.dbo.DimDate as last_cd4 on last_cd4.Date = source_CD4.LastCD4Date
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = source_CD4.SiteCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.dbo.DimAgeGroup as age_group on age_group.Age = source_CD4.AgeLastVisit
WHERE patient.voided =0;

alter table NDWH.dbo.FactCD4 add primary key(FactKey);
END