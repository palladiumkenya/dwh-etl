IF OBJECT_ID(N'[NDWH].[dbo].[FactPrep]', N'U') IS NOT NULL 
DROP TABLE [NDWH].[dbo].[FactPrep];

BEGIN

    with MFL_partner_agency_combination as (
        select 
            distinct MFL_Code,
            SDP,
        SDP_Agency collate Latin1_General_CI_AS as Agency
        from ODS.dbo.All_EMRSites 
    ),
    prep_patients as
    (
        select
            distinct convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK as nvarchar(36))), 2) as PatientPK,
            SiteCode
        from ODS.dbo.PrEP_Patient
    ),
    exits_ordering as (
        select  
            row_number () over (partition by PrepNumber, PatientPk,SiteCode order by ExitDate desc) as num,
            PatientPk,
            SiteCode,
            StatusDate,
            ExitDate,
            ExitReason,
            DateOfLastPrepDose
        from ODS.dbo.PrEP_CareTermination
    ),
    latest_exits as (
        select 
            *
        from exits_ordering
        where num = 1
    ),
    latest_prep_assessments as (
        select 
            *
        from ODS.dbo.Intermediate_LastestPrepAssessments
    )
    select 
        FactKey = IDENTITY(INT, 1, 1),
        patient.PatientKey,
        facility.FacilityKey,
        agency.AgencyKey,
        partner.PartnerKey,
        age_group.AgeGroupKey,
        latest_prep_visits.VisitID,
        visit.DateKey as VisitDateKey,
        latest_prep_visits.BloodPressure,
        latest_prep_visits.Temperature,
        latest_prep_visits.Weight,
        latest_prep_visits.Height,
        latest_prep_visits.BMI,
        latest_prep_visits.STIScreening,
        latest_prep_visits.STISymptoms,
        latest_prep_visits.STITreated,
        latest_prep_visits.Circumcised,
        latest_prep_visits.VMMCReferral,
        latest_prep_visits.LMP,
        latest_prep_visits.MenopausalStatus,
        latest_prep_visits.PregnantAtThisVisit,
        latest_prep_visits.EDD,
        latest_prep_visits.PlanningToGetPregnant,
        latest_prep_visits.PregnancyPlanned,
        latest_prep_visits.PregnancyEnded,
        pregnancy.DateKey as PregnancyEndDateKey,
        latest_prep_visits.PregnancyOutcome,
        latest_prep_visits.BirthDefects,
        latest_prep_visits.Breastfeeding,
        latest_prep_visits.FamilyPlanningStatus,
        latest_prep_visits.FPMethods,
        latest_prep_visits.AdherenceDone,
        latest_prep_visits.AdherenceOutcome,
        latest_prep_visits.AdherenceReasons,
        latest_prep_visits.SymptomsAcuteHIV,
        latest_prep_visits.ContraindicationsPrep,
        latest_prep_visits.PrepTreatmentPlan,
        latest_prep_visits.PrepPrescribed,
        latest_prep_visits.RegimenPrescribed,
        latest_prep_visits.MonthsPrescribed,
        latest_prep_visits.CondomsIssued,
        latest_prep_visits.Tobegivennextappointment,
        latest_prep_visits.Reasonfornotgivingnextappointment,
        latest_prep_visits.HepatitisBPositiveResult,
        latest_prep_visits.HepatitisCPositiveResult,
        latest_prep_visits.VaccinationForHepBStarted,
        latest_prep_visits.TreatedForHepB,
        latest_prep_visits.VaccinationForHepCStarted,
        latest_prep_visits.TreatedForHepC,
        latest_prep_visits.NextAppointment,
        latest_prep_visits.ClinicalNotes,
        latest_prep_assessments.ClientRisk,
        latest_prep_assessments.EligiblePrep,
        assessment_date.DateKey As AssessmentVisitDateKey,
        latest_prep_assessments.ScreenedPrep,
        latest_exits.ExitReason,
        exits.DateKey as ExitdateKey,  
        refills.RefilMonth1,
        refills.TestResultsMonth1,
        refill_month_1.DateKey as DateTestMonth1Key,
        dispense_month_1.DateKey as DateDispenseMonth1,
        refills.RefilMonth3,
        refills.TestResultsMonth3,
        refill_month_3.DateKey as DateTestMonth3Key,
        dispense_month_3.DateKey as DateDispenseMonth3,
        cast(getdate() as date) as LoadDate
    into NDWH.dbo.FactPrep
    from prep_patients
    left join ODS.dbo.Intermediate_PrepLastVisit as  latest_prep_visits on convert(nvarchar(64), hashbytes('SHA2_256', cast(latest_prep_visits.PatientPK as nvarchar(36))), 2) =  prep_patients.PatientPK
        and latest_prep_visits.SiteCode = prep_patients.SiteCode
    left join latest_exits on convert(nvarchar(64), hashbytes('SHA2_256', cast(latest_exits.PatientPK as nvarchar(36))), 2) = prep_patients.PatientPK
        and latest_exits.SiteCode = prep_patients.SiteCode
    left join ODS.dbo.Intermediate_PrepRefills as refills on convert(nvarchar(64), hashbytes('SHA2_256', cast(refills.PatientPk as nvarchar(36))), 2) = prep_patients.PatientPK
        and refills.SiteCode = prep_patients.SiteCode
    left join latest_prep_assessments on convert(nvarchar(64), hashbytes('SHA2_256', cast(latest_prep_assessments.PatientPK as nvarchar(36))), 2) = prep_patients.PatientPK
        and latest_prep_assessments.SiteCode = prep_patients.SiteCode
    left join NDWH.dbo.DimPatient as patient on patient.PatientPKHash = prep_patients.PatientPK
        and patient.SiteCode = prep_patients.SiteCode
    left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = prep_patients.SiteCode
    left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP collate Latin1_General_CI_AS
    left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
    left join NDWH.dbo.DimFacility as facility on facility.MFLCode = prep_patients.SiteCode
    left join NDWH.dbo.DimAgeGroup as age_group on age_group.Age = datediff(yy, patient.DOB, coalesce(latest_prep_visits.VisitDate, getdate()))
    left join NDWH.dbo.DimDate as visit on visit.Date = latest_prep_visits.VisitDate
    left join NDWH.dbo.DimDate as pregnancy on pregnancy.Date = latest_prep_visits.PregnancyEndDate
    left join NDWH.dbo.DimDate as appointment on appointment.Date= latest_prep_visits.NextAppointment
    left join NDWH.dbo.DimDate as assessment_date on assessment_date.Date = latest_prep_assessments.VisitDate
    left join NDWH.dbo.DimDate as exits on exits.Date = latest_exits.ExitDate
    left join NDWH.dbo.DimDate as refill_month_1 on refill_month_1.Date = refills.TestDateMonth1
    left join NDWH.dbo.DimDate as dispense_month_1 on dispense_month_1.Date = refills.DispenseDateMonth1
    left join NDWH.dbo.DimDate as refill_month_3 on refill_month_3.Date = refills.TestDateMonth3
    left join NDWH.dbo.DimDate as dispense_month_3 on dispense_month_3.Date = refills.DispenseDateMonth3;

    alter table NDWH.dbo.FactPrep add primary key(FactKey);
END