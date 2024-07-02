IF EXISTS(SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.dbo.LinelistPrepAssessments') AND type in (N'U')) 
    DROP TABLE REPORTING.dbo.LinelistPrepAssessments
GO

WITH prepCascade AS  (
	SELECT DISTINCT 
        PatientPKHash,
        prep.PatientKey,
        MFLCode,	
        prep.FacilityKey,	
        f.FacilityName,
        County,
        SubCounty,
        p.PartnerName,
        a.AgencyName,
        pat.Gender,
        age.DATIMAgeGroup as AgeGroup,
        ass.month AssessmentMonth,
        ass.year AssessmentYear,
        EOMONTH(ass.Date) as AsofDate,
        EligiblePrep,
        ScreenedPrep,
       prepEnrol.Date as PrepEnrollmentDate,
	   ass.Date as VisitDate
    FROM NDWH.dbo.FactPrepAssessments prep
	LEFT JOIN NDWH.dbo.DimFacility f on f.FacilityKey = prep.FacilityKey
	LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = prep.AgencyKey
	LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = prep.PatientKey
	LEFT JOIN NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=prep.AgeGroupKey
	LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = prep.PartnerKey
	LEFT JOIN NDWH.dbo.DimDate ass ON ass.DateKey = AssessmentVisitDateKey 	
    LEFT JOIN NDWH.dbo.DimDate prepEnrol ON prepEnrol.DateKey = pat.PrepEnrollmentDateKey 	
),
risk_category_ordering as (
    select 
        row_number() OVER (PARTITION BY PatientKey ORDER BY VisitDateKey DESC) as num,
        PatientKey,
        HIVRiskCategory,
        VisitDateKey
    from NDWH.dbo.FactHTSEligibilityextract hiv
    where HIVRiskCategory is not null
),
latest_risk_category as (
    select 
        *
    from risk_category_ordering
    where num = 1
),
TurnedPositive as (
    Select distinct
    PatientKey,
    FinalTestResult
    from 
    NDWH.dbo.FactHTSClientTests
    where FinalTestResult='Positive' and TestType='Initial Test'
)
select 
        Prep.PatientPKHash,
        Prep.MFLCode,		
        Prep.FacilityName,
        Prep.County,
        Prep.SubCounty,
        Prep.PartnerName,
        Prep.AgencyName,
        Prep.Gender,
        AgeGroup,
        AssessmentMonth,
        AssessmentYear,
        prep.PrepEnrollmentDate ,
        AsofDate,
        EligiblePrep,
        ScreenedPrep,
        HIVRiskCategory as LatestHIVRiskCategory,
        ExitDate,
        ExitReason,
        case when TurnedPositive.PatientKey is not null then 1 else 0 End as TurnedPositive,
        CAST(GETDATE() AS DATE) AS LoadDate 
INTO REPORTING.dbo.LinelistPrepAssessments 
from prepCascade prep
left join latest_risk_category  on latest_risk_category.PatientKey = prep.PatientKey 
left join NDWH.dbo.FactPrepDiscontinuation as disc on disc.PatientKey=prep.PatientKey
left join NDWH.dbo.FactPrepVisits as visits on visits.PatientKey=prep.PatientKey
left join TurnedPositive on TurnedPositive.PatientKey=prep.PatientKey

