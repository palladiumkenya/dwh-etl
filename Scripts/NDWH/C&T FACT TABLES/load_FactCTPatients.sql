IF OBJECT_ID(N'[NDWH].[dbo].[FactCTPatients]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FactCTPatients];
BEGIN	
with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency  as Agency
	from ODS.dbo.All_EMRSites 
),
CT_Patients as (
	select
		distinct 
		CT_Patients.PatientIDHash,
		CT_Patients.PatientPKHash,
		CT_Patients.SiteCode
	from ODS.dbo.CT_Patient as CT_Patients
    where voided=0
	
	
)
select 
	Factkey = IDENTITY(INT, 1, 1),
	patient.PatientKey,
	facility.FacilityKey,
	partner.PartnerKey,
	agency.AgencyKey,
	cast(getdate() as date) as LoadDate
into NDWH.dbo.FactCTPatients
from CT_Patients
left join NDWH.dbo.DimPatient as patient on patient.PatientPKHash = CT_Patients.PatientPKHash
    and patient.SiteCode = CT_Patients.SiteCode
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = CT_Patients.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = CT_Patients.SiteCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency


alter table NDWH.dbo.FactCTPatients add primary key(FactKey);
END