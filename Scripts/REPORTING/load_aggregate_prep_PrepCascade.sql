IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.[dbo].[AggregatePrepCascade]') AND type in (N'U')) 
TRUNCATE TABLE REPORTING.[dbo].[AggregatePrepCascade]
GO

WITH prepCascade AS  (
	SELECT DISTINCT 
			MFLCode,		
			f.FacilityName,
			County,
			SubCounty,
			p.PartnerName,
			a.AgencyName,
			pat.Gender,
			age.DATIMAgeGroup as AgeGroup,
			ass.month AssMonth,
			ass.year AssYear,
			Sum(EligiblePrep) As EligiblePrep,
			sum(ScreenedPrep) As Screened,
			Count (distinct (concat(PrepNumber,PatientPKHash,MFLCode))) As PrepCT
	FROM NDWH.dbo.FactPrepAssessments prep

	LEFT JOIN NDWH.dbo.DimFacility f on f.FacilityKey = prep.FacilityKey
	LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = prep.AgencyKey
	LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = prep.PatientKey
	LEFT JOIN NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=prep.AgeGroupKey
	LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = prep.PartnerKey
	LEFT JOIN NDWH.dbo.DimDate ass ON ass.DateKey = AssessmentVisitDateKey 

	GROUP BY MFLCode,
			f.FacilityName,
			County,
			SubCounty,
			p.PartnerName,
			a.AgencyName,
			pat.Gender,
			age.DATIMAgeGroup,
			ass.Month,
			ass.Year
),
prepStart AS (
	SELECT DISTINCT 
		MFLCode,		
		f.FacilityName,
		County,
		SubCounty,
		p.PartnerName,
		a.AgencyName,
		pat.Gender,
		age.DATIMAgeGroup as AgeGroup,
		enrol.month EnrollmentMonth, 
		enrol.year EnrollmentYear,
		Count (distinct (concat(PrepNumber,PatientPKHash,MFLCode))) As StartedPrep
	FROM NDWH.dbo.FactPrepAssessments prep

	LEFT JOIN NDWH.dbo.DimFacility f on f.FacilityKey = prep.FacilityKey
	LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = prep.AgencyKey
	LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = prep.PatientKey
	LEFT join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=prep.AgeGroupKey
	LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = prep.PartnerKey
	LEFT JOIN NDWH.dbo.DimDate enrol ON enrol.DateKey = PrepEnrollmentDateKey 

	GROUP BY MFLCode,
			f.FacilityName,
			County,
			SubCounty,
			p.PartnerName,
			a.AgencyName,
			pat.Gender,
			age.DATIMAgeGroup,
			enrol.Month,
			enrol.Year
)
INSERT INTO REPORTING.dbo.AggregatePrepCascade
	(
		MFLCode,		
		FacilityName,
		County,
		SubCounty,
		PartnerName,
		AgencyName,
		Gender,
		AgeGroup,
		Month,
		Year,
		EligiblePrep,
		Screened,
		PrepCT,
		StartedPrep	
	)
SELECT
	COALESCE(p.MFLCode, s.MFLCode) AS MFLCode,		
	COALESCE(p.FacilityName, s.FacilityName) AS FacilityName,
	COALESCE(p.County, s.County) AS County,
	COALESCE(p.SubCounty, s.SubCounty) AS SubCounty,
	COALESCE(p.PartnerName, s.PartnerName) AS PartnerName,
	COALESCE(p.AgencyName, s.AgencyName) AS AgencyName,
	COALESCE(p.Gender, s.Gender) AS Gender,
	COALESCE(p.AgeGroup, s.AgeGroup) AS AgeGroup,
	COALESCE(p.AssMonth, s.EnrollmentMonth) AS AssMonth,
	COALESCE(p.AssYear, s.EnrollmentYear) AS AssYear,
	COALESCE(p.EligiblePrep, 0) AS EligiblePrep,
	COALESCE(p.Screened, 0) AS Screened,
	COALESCE(p.PrepCT, 0) AS PrepCT,
	COALESCE(s.StartedPrep, 0) AS StartedPrep
FROM prepCascade p

FULL OUTER JOIN prepStart s on p.MFLCode = s.MFLCode and s.FacilityName = p.FacilityName and s.County = p.County and s.SubCounty = p.SubCounty and s.PartnerName = p.PartnerName and s.AgencyName = p.AgencyName and s.Gender = p.Gender and s.AgeGroup = s.AgeGroup and AssMonth = EnrollmentMonth and AssYear = EnrollmentYear
