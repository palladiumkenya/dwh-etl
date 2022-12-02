with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
		[SDP Agency] collate Latin1_General_CI_AS as Agency
	from HIS_Implementation.dbo.All_EMRSites 
),
source_ovc as (
	select
		distinct ovc.PatientPK,
		ovc.PatientID,
		ovc.SiteCode,
		OVCEnrollmentDate,
		RelationshipToClient,
		EnrolledinCPIMS,
		CPIMSUniqueIdentifier,
		PartnerOfferingOVCServices,
		OVCExitReason,
		ExitDate,
		datediff(yy, patient.DOB, last_encounter.LastEncounterDate) as AgeLastVisit
	from ODS.dbo.CT_OVC as ovc
	left join ODS.dbo.Intermediate_LastPatientEncounter as last_encounter on last_encounter.PatientPK = ovc.PatientPK
		and last_encounter.SiteCode = ovc.SiteCode
	left join ODS.dbo.CT_Patient as patient on patient.PatientPK = ovc.PatientPK
	and patient.SiteCode = ovc.SiteCode
)
select 
	Factkey = IDENTITY(INT, 1, 1),
	patient.PatientKey,
	facility.FacilityKey,
	partner.PartnerKey,
	agency.AgencyKey,
    age_group.AgeGroupKey,
	ovc_enrollment.DateKey as OVCEnrollmentDateKey,
	relationship_client.RelationshipWithPatientKey,
	source_ovc.EnrolledinCPIMS,
	CPIMSUniqueIdentifier,
	PartnerOfferingOVCServices,
	OVCExitReason,
	exit_date.DateKey as OVCExitDateKey,
	cast(getdate() as date) as LoadDate
into dbo.FactOVC
from source_ovc
left join NDWH.dbo.DimPatient as patient on patient.PatientPK = convert(nvarchar(64), hashbytes('SHA2_256', cast(source_ovc.PatientPK as nvarchar(36))), 2)
    and patient.SiteCode = source_ovc.SiteCode
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = source_ovc.SiteCode
left join NDWH.dbo.DimDate as ovc_enrollment on ovc_enrollment.Date = source_ovc.OVCEnrollmentDate
left join NDWH.dbo.DimDate as exit_date on exit_date.Date = source_ovc.ExitDate
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = source_ovc.SiteCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.dbo.DimAgeGroup as age_group on age_group.Age = source_ovc.AgeLastVisit
left join NDWH.dbo.DimRelationshipWithPatient as relationship_client on relationship_client.RelationshipWithPatient = source_ovc.RelationshipToClient;

alter table dbo.FactOVC add primary key(FactKey);