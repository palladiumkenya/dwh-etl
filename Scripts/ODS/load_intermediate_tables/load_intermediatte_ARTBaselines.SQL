IF OBJECT_ID(N'[ODS].[dbo].[intermediate_ARTBaselines]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[dbo].[intermediate_ARTBaselines];

BEGIN	
with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency as Agency 
	from ODS.dbo.All_EMRSites 
),
 ARTPatients as (
    Select 
    Patientpk,
    PatientPKHash,
    SiteCode,
    StartARTDate
    from ODS.dbo.CT_ARTPatients
),
Baseline_Who as (
	select
		distinct visits.PatientPK, 
		visits.WhoStage,
        visits.SiteCode
	from ODS.dbo.CT_PatientVisits as visits
	inner join ARTPatients as art on visits.SiteCode = art.SiteCode 
		and visits.PatientPK = art.PatientPK 
		and visits.VisitDate = art.StartARTDate
	WHERE  VISITS.VOIDED=0
 )
 
	select 
		patient.PatientPKHash,
        patient.PatientPK,
		patient.SiteCode,
		WhoStage as WhoStageAtART,
        cast(getdate() as date) as LoadDate
        into ODS.dbo.intermediate_ARTBaselines
	from ARTPatients as patient
    left join Baseline_Who on Baseline_Who.PatientPK=patient.PatientPK and Baseline_Who.Sitecode=patient.Sitecode
    
END

