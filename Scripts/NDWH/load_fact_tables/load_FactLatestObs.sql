with MFL_partner_agency_combination as (
	select 
		MFL_Code,
		SDP,
		[SDP Agency] collate Latin1_General_CI_AS as Agency
	from HIS_Implementation.dbo.All_EMRSites 
),
latest_weight_height as (
select 
	PatientID,
	PatientPK,
	SiteCode,
	Weight as LatestWeight,
	Height as LatestHeight
from ODS.dbo.Intermediate_LastestWeightHeight
),
age_of_last_visit as (
	select 
		last_encounter.PatientPK,
		last_encounter.SiteCode,
		datediff(yy, patient.DOB, last_encounter.LastEncounterDate) as AgeLastVisit
	from ODS.dbo.CT_Patient as patient
	left join ODS.dbo.Intermediate_LastPatientEncounter as last_encounter on last_encounter.PatientPK = patient.PatientPK
		and last_encounter.SiteCode = patient.SiteCode
),
latest_adherence as (
	select
		distinct  
		visits.SiteCode,
		visits.PatientPK,
		visits.PatientID, 
		visits.Adherence
	from ODS.dbo.CT_PatientVisits as visits
	inner join ODS.dbo.Intermediate_LastVisitDate as last_visit on visits.SiteCode = last_visit.SiteCode 
		and visits.PatientPK = last_visit.PatientPK 
		and visits.VisitDate = last_visit.LastVisitDate  
		and AdherenceCategory in ('ARVAdherence', 'ART','ART|CTX','ARV','ARV Adherence')
),
latest_differentiated_care as (
	select
		distinct visits.SiteCode,
		visits.PatientPK,
		visits.PatientID, 
		visits.DifferentiatedCare
	from ODS.dbo.CT_PatientVisits as visits
	inner join ODS.dbo.Intermediate_LastVisitDate as last_visit on visits.SiteCode = last_visit.SiteCode 
		and visits.PatientPK = last_visit.PatientPK 
		and visits.VisitDate = last_visit.LastVisitDate  
),
latest_mmd as (
	select
		distinct PatientPK,
		PatientID,
		SiteCode,
		case 
			when abs(datediff(day,LastEncounterDate, NextAppointmentDate)) <=84 then 0
			when abs(datediff(day,LastEncounterDate, NextAppointmentDate))  >= 85 THEN  1 
		end as onMMD
	from ODS.dbo.Intermediate_LastPatientEncounter
),
lastest_stability_assessment as (
	select
		distinct  
		visits.SiteCode,
		visits.PatientPK,
		visits.PatientID, 
		visits.StabilityAssessment
	from ODS.dbo.CT_PatientVisits as visits
	inner join ODS.dbo.Intermediate_LastVisitDate as last_visit on visits.SiteCode = last_visit.SiteCode 
		and visits.PatientPK = last_visit.PatientPK 
		and visits.VisitDate = last_visit.LastVisitDate  
),
latest_pregnancy as (
	select
		distinct visits.PatientPK, 
		visits.PatientID, 
		visits.SiteCode,
		visits.Pregnant
	from ODS.dbo.CT_PatientVisits as visits
	inner join ODS.dbo.Intermediate_LastVisitDate as last_visit on visits.SiteCode = last_visit.SiteCode 
		and visits.PatientPK = last_visit.PatientPK 
		and visits.VisitDate = last_visit.LastVisitDate
	    and Pregnant is not null
),
latest_fp_method as (
	select
		distinct visits.PatientPK, 
		visits.PatientID, 
		visits.SiteCode,
		visits.FamilyPlanningMethod
	from ODS.dbo.CT_PatientVisits as visits
	inner join ODS.dbo.Intermediate_LastVisitDate as last_visit on visits.SiteCode = last_visit.SiteCode 
		and visits.PatientPK = last_visit.PatientPK 
		and visits.VisitDate = last_visit.LastVisitDate
	    and FamilyPlanningMethod is not null
		and FamilyPlanningMethod <> ''
),
combined_table as (
	select 
		patient.PatientPK,
		patient.SiteCode,
		patient.PatientID,
		latest_weight_height.LatestHeight,
		latest_weight_height.LatestWeight,
		age_of_last_visit.AgeLastVisit,
		latest_adherence.Adherence,
		latest_differentiated_care.DifferentiatedCare,
		latest_mmd.onMMD,
		lastest_stability_assessment.StabilityAssessment,
		latest_pregnancy.Pregnant
	from ODS.dbo.CT_Patient as patient
	left join latest_weight_height on latest_weight_height.PatientPK = patient.PatientPK
		and latest_weight_height.SiteCode = patient.SiteCode
	left join age_of_last_visit on age_of_last_visit.PatientPK = patient.PatientPK
		and age_of_last_visit.SiteCode = patient.SiteCode
	left join latest_adherence on latest_adherence.PatientPK = patient.PatientPK
		and latest_adherence.SiteCode = patient.SiteCode
	left join latest_differentiated_care on latest_differentiated_care.PatientPK = patient.PatientPK
		and latest_differentiated_care.SiteCode = patient.SiteCode
	left join latest_mmd on latest_mmd.PatientPK = patient.PatientPK
		and latest_mmd.SiteCode = patient.SiteCode
	left join lastest_stability_assessment on lastest_stability_assessment.PatientPK = patient.PatientPK
		and lastest_stability_assessment.SiteCode = patient.SiteCode
	left join latest_pregnancy on latest_pregnancy.PatientPK = patient.PatientPK
		and latest_pregnancy.SiteCode = patient.SiteCode
	left join latest_fp_method on latest_fp_method.PatientPK = patient.PatientPK
		and latest_fp_method.SiteCode = patient.SiteCode
)
select 
	Factkey = IDENTITY(INT, 1, 1),
	patient.PatientKey,
	facility.FacilityKey,
	partner.PartnerKey,
	agency.AgencyKey,
    age_group.AgeGroupKey,
	diff_care.DifferentiatedCareKey,
	combined_table.LatestHeight,
	combined_table.LatestWeight,
	combined_table.AgeLastVisit,
	combined_table.Adherence,
	combined_table.DifferentiatedCare,
	combined_table.onMMD,
	combined_table.StabilityAssessment,
	combined_table.Pregnant
into dbo.FactLatestObs
from combined_table 
left join NDWH.dbo.DimPatient as patient on patient.PatientPK = convert(nvarchar(64), hashbytes('SHA2_256', cast(combined_table.PatientPK as nvarchar(36))), 2)
    and patient.SiteCode = combined_table.SiteCode
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = combined_table.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = combined_table.SiteCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.dbo.DimAgeGroup as age_group on age_group.Age = combined_table.AgeLastVisit
left join NDWH.dbo.DimDifferentiatedCare as diff_care on diff_care.DifferentiatedCare = combined_table.DifferentiatedCare;

alter table dbo.FactLatestObs add primary key(FactKey);
