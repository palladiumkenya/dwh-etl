
IF EXISTS(SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.dbo.LinelistPrep') AND type in (N'U')) 
    DROP TABLE REPORTING.dbo.LinelistPrep
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
        ScreenedPrep
 
    FROM NDWH.dbo.FactPrepAssessments prep
    
	LEFT JOIN NDWH.dbo.DimFacility f on f.FacilityKey = prep.FacilityKey
	LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = prep.AgencyKey
	LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = prep.PatientKey
	LEFT JOIN NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=prep.AgeGroupKey
	LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = prep.PartnerKey
	LEFT JOIN NDWH.dbo.DimDate ass ON ass.DateKey = AssessmentVisitDateKey 
	
),

Riskscores As (Select 
* from NDWH.dbo.FactHTSEligibilityextract hiv
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
        case when Hiv.PatientKey  is not null then 1 else 0
        End as PreventionServices ,
        CAST(GETDATE() AS DATE) AS LoadDate 
  INTO REPORTING.dbo.LinelistPrep 
  from prepCascade prep
  left join Riskscores hiv on hiv.PatientKey=prep.PatientKey and hiv.FacilityKey=prep.FacilityKey