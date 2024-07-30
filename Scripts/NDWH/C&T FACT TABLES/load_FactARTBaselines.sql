
IF OBJECT_ID(N'[NDWH].[dbo].[FactARTBaselines]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FactARTBaselines];

ALTER TABLE ODS.dbo.All_EMRSites  ALTER COLUMN SDP_Agency nvarchar(4000) ;

BEGIN	
with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency as Agency 
	from ODS.dbo.All_EMRSites 
)
select 
	Factkey = IDENTITY(INT, 1, 1),
	patient.PatientKey,
	facility.FacilityKey,
	partner.PartnerKey,
	agency.AgencyKey,
    age_group.AgeGroupKey,
    WHOStageAtART,
	cast(getdate() as date) as LoadDate
into NDWH.dbo.FactARTBaselines
from ODS.dbo.intermediate_ARTBaselines art
left join NDWH.dbo.DimPatient as patient on art.PatientPKHash = patient.PatientPKHash 
    and art.SiteCode = patient.SiteCode
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = art.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = art.SiteCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.dbo.DimAgeGroup as age_group on age_group.Age = art.AgeATARTStart



alter table NDWH.dbo.FactARTBaselines add primary key(FactKey);
END


