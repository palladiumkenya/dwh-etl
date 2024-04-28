IF EXISTS(SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.dbo.LinelistPrep') AND type in (N'U')) 
    DROP TABLE REPORTING.dbo.LinelistPrep
GO

With TurnedPositive as (
    Select distinct
    PatientKey,
    FinalTestResult,
    testingdate.[Date] as DateTested
    from 
    NDWH.dbo.FactHTSClientTests as tests
    left join NDWH.dbo.DimDate as testingdate on testingdate.[Date]=tests.DateTestedKey
    where  TestType='Initial Test'
)
SELECT
       Factkey = IDENTITY(INT, 1, 1)
      ,PatientPKHash
      ,SiteCode
      ,Agency
      ,PartnerName
      ,Age
      ,visit.Date as VisitDate
      ,tca.Date as   NextAppointmentDate
      ,VisitID
      ,BloodPressure
      ,Temperature
      ,Weight
      ,Height
      ,BMI
      ,STIScreening
      ,STISymptoms
      ,STIPositive
      ,STINegative
      ,STITreated
      ,Circumcised
      ,VMMCReferral
      ,LMP
      ,MenopausalStatus
      ,PregnantAtThisVisit
      ,EDD
      ,PlanningToGetPregnant
      ,PregnancyPlanned
      ,PregnancyEnded
      ,PregnancyEnded.Date as   PregnancyEndDate
      ,PregnancyOutcome
      ,BirthDefects
      ,Breastfeeding
      ,FamilyPlanningStatus
      ,FPMethods
      ,AdherenceDone
      ,AdherenceOutcome
      ,AdherenceReasons
      ,SymptomsAcuteHIV
      ,ContraindicationsPrep
      ,PrepTreatmentPlan
      ,PrepPrescribed
      ,RegimenPrescribed
      ,MonthsPrescribed
      ,CondomsIssued
      ,Tobegivennextappointment
      ,Reasonfornotgivingnextappointment
      ,HepatitisBPositiveResult
      ,HepatitisCPositiveResult
      ,VaccinationForHepBStarted
      ,TreatedForHepB
      ,VaccinationForHepCStarted
      ,TreatedForHepC
      ,NextAppointment
      ,ClinicalNotes
      ,ExitDate
      ,ExitReason
      ,case when FinalTestResult='Positive' Then 1 Else 0 end as TurnedPositive
      ,Case when  visit.[Date] is not null  and visit.[Date] > prepenrol.Date Then 1 else 0 End as PrepCT
      ,prepenrol.date as PrepEnrollmentDate
      ,CAST(GETDATE() AS DATE) AS LoadDate 
      into REPORTING.dbo.LinelistPrep
  FROM NDWH.dbo.FactPrepVisits as visits
    left join NDWH.dbo.DimFacility as fac on fac.FacilityKey=visits.FacilityKey
    left join NDWH.dbo.DimPatient as pat on pat.PatientKey=visits.PatientKey
    left join NDWH.dbo.DimPartner as partner on partner.PartnerKey=visits.PartnerKey
    left join NDWH.dbo.DimAgency as agency on agency.AgencyKey=visits.agencykey
    left join NDWH.dbo.DimAgeGroup as agegroup on agegroup.AgeGroupKey=visits.AgeGroupKey
    left JOIN NDWH.dbo.DimDate as visit on visit.DateKey = visits.VisitDateKey
    left JOIN NDWH.dbo.DimDate as tca on tca.DateKey = visits.NextAppointmentDateKey
    left JOIN NDWH.dbo.DimDate as PregnancyEnded on PregnancyEnded.DateKey = visits.PregnancyEndDateKey
    left JOIN NDWH.dbo.DimDate as prepenrol on prepenrol.DateKey = visits.PrepEnrollmentDateKey
    left join NDWH.dbo.FactPrepDiscontinuation as disc on disc.PatientKey=visits.PatientKey
    left join TurnedPositive on TurnedPositive.Patientkey=visits.Patientkey and visit.[Date]=DateTested
      