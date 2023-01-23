IF OBJECT_ID(N'[NDWH].[dbo].[FactOTZ]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FactOTZ];
BEGIN
	with MFL_partner_agency_combination as (
		select 
			MFL_Code,
			SDP,
			[SDP_Agency] collate Latin1_General_CI_AS as Agency
		from ODS.dbo.All_EMRSites 
	),
	otz_and_last_encounter_combined as (
	select
		otz.PatientID,
		otz.PatientPK,
		otz.SiteCode,
		otz.OTZEnrollmentDate,
		otz.LastVisitDate,
		otz.TransferInStatus,
		otz.TransitionAttritionReason,
		otz.ModulesPreviouslyCovered,
		otz.ModulesCompletedToday_OTZ_Orientation,
		otz.ModulesCompletedToday_OTZ_Participation,
		otz.ModulesCompletedToday_OTZ_Leadership,
		otz.ModulesCompletedToday_OTZ_MakingDecisions,
		otz.ModulesCompletedToday_OTZ_Transition,
		otz.ModulesCompletedToday_OTZ_TreatmentLiteracy,
		otz.ModulesCompletedToday_OTZ_SRH,
		otz.ModulesCompletedToday_OTZ_Beyond,
		datediff(yy, patient.DOB, last_encounter.LastEncounterDate) as AgeLastVisit
	from ODS.dbo.Intermediate_LastOTZVisit as otz
	left join ODS.dbo.Intermediate_LastPatientEncounter as last_encounter on last_encounter.PatientPK = otz.PatientPK
			and last_encounter.SiteCode = otz.SiteCode
	left join ODS.dbo.CT_Patient as patient on patient.PatientPK = otz.PatientPK
		and patient.SiteCode = otz.SiteCode
	)
	select 
		Factkey = IDENTITY(INT, 1, 1),
		patient.PatientKey,
		facility.FacilityKey,
		partner.PartnerKey,
		agency.AgencyKey,
		age_group.AgeGroupKey,
		otz_enrollment.DateKey as OTZEnrollmentDateKey,
		last_visit.DateKey as LastVisitDateKey,
		otz_and_last_encounter_combined.TransitionAttritionReason,
		otz_and_last_encounter_combined.TransferInStatus,
		otz_and_last_encounter_combined.ModulesPreviouslyCovered,
		otz_and_last_encounter_combined.ModulesCompletedToday_OTZ_Orientation,
		otz_and_last_encounter_combined.ModulesCompletedToday_OTZ_Participation,
		otz_and_last_encounter_combined.ModulesCompletedToday_OTZ_Leadership,
		otz_and_last_encounter_combined.ModulesCompletedToday_OTZ_MakingDecisions,
		otz_and_last_encounter_combined.ModulesCompletedToday_OTZ_Transition,
		otz_and_last_encounter_combined.ModulesCompletedToday_OTZ_TreatmentLiteracy,
		otz_and_last_encounter_combined.ModulesCompletedToday_OTZ_SRH,
		otz_and_last_encounter_combined.ModulesCompletedToday_OTZ_Beyond,
		cast(getdate() as date) as LoadDate
	into [NDWH].[dbo].[FactOTZ]
	from otz_and_last_encounter_combined
	left join NDWH.dbo.DimPatient as patient on patient.PatientPK = convert(nvarchar(64), hashbytes('SHA2_256', cast(otz_and_last_encounter_combined.PatientPK as nvarchar(36))), 2)
		and patient.SiteCode = otz_and_last_encounter_combined.SiteCode
	left join NDWH.dbo.DimFacility as facility on facility.MFLCode = otz_and_last_encounter_combined.SiteCode
	left join NDWH.dbo.DimDate as otz_enrollment on otz_enrollment.Date = otz_and_last_encounter_combined.OTZEnrollmentDate
	left join NDWH.dbo.DimDate as last_visit on last_visit.Date = otz_and_last_encounter_combined.OTZEnrollmentDate
	left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = otz_and_last_encounter_combined.SiteCode
	left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
	left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
	left join NDWH.dbo.DimAgeGroup as age_group on age_group.Age = otz_and_last_encounter_combined.AgeLastVisit;

	alter table [NDWH].[dbo].[FactOTZ] add primary key(FactKey);
END
