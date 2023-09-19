
IF EXISTS(SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.dbo.LinelistPrep') AND type in (N'U')) 
    DROP TABLE REPORTING.dbo.LinelistPrep
GO

WITH prepCascade AS  (
	SELECT DISTINCT 
        PatientPKHash,
        MFLCode,		
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
    CAST(GETDATE() AS DATE) AS LoadDate 
 
    FROM NDWH.dbo.FactPrepAssessments prep
    
	LEFT JOIN NDWH.dbo.DimFacility f on f.FacilityKey = prep.FacilityKey
	LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = prep.AgencyKey
	LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = prep.PatientKey
	LEFT JOIN NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=prep.AgeGroupKey
	LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = prep.PartnerKey
	LEFT JOIN NDWH.dbo.DimDate ass ON ass.DateKey = AssessmentVisitDateKey 
	
),

Riskscores As (Select 
* from REPORTING.dbo.LineListHTSRiskCategorizationAndTestResults hiv
where HIVRiskCategory is not null
)
Select 
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
        AsofDate,
        EligiblePrep,
        ScreenedPrep,
        HIVRiskCategory,
        case when hiv.PatientPKhash  is not null then 1 else 0
        End as PreventionServices 
  INTO REPORTING.dbo.LinelistPrep 
  from prepCascade prep
  left join Riskscores hiv on hiv.PatientPKHash=prep.PatientPKHash and hiv.MFLCode=prep.MFLCode