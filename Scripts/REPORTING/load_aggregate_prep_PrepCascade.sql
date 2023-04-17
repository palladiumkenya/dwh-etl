IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.[dbo].[AggregatePrepCascade]') AND type in (N'U')) 
TRUNCATE TABLE REPORTING.[dbo].[AggregatePrepCascade]
GO

INSERT INTO REPORTING.dbo.AggregatePrepCascade
		(MFLCode,
		FacilityName, 
		County,
		SubCounty,
		PartnerName, 
		AgencyName, 
		Gender, 
		AgeGroup,
		EligiblePrep,
		Screened,
        EnrollmentMonth,
		EnrollmentYear,
		StartedPrep
		
		)

SELECT DISTINCT 
		MFLCode,		
		f.FacilityName,
		County,
		SubCounty,
		p.PartnerName,
		a.AgencyName,
		pat.Gender,
		age.DATIMAgeGroup as AgeGroup,
		Sum(EligiblePrep) As EligiblePrep,
		sum(ScreenedPrep) As Screened,
		enrol.month EnrollmentMonth, 
        enrol.year EnrollmentYear,
        Count (distinct (concat(PrepNumber,PatientPKHash,MFLCode))) As StartedPrep
		--Count (distinct (concat(PrepNumber,PatientPkHash,SiteCode))) As PrepCT
		

FROM NDWH.dbo.FactPrepAssessments prep

LEFT join NDWH.dbo.DimFacility f on f.FacilityKey = prep.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = prep.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = prep.PatientKey
LEFT join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=prep.AgeGroupKey
LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = prep.PartnerKey
--LEFT JOIN NDWH.dbo.DimDate visit ON visit.DateKey = prep.AssessmentVisitDateKey
LEFT JOIN NDWH.dbo.DimDate enrol ON enrol.DateKey = PrepEnrollmentDateKey 
 



GROUP BY  MFLCode,		
		f.FacilityName,
		County,
		SubCounty,
		p.PartnerName,
		a.AgencyName,
		pat.Gender,
		age.DATIMAgeGroup,
		enrol.Month,
		enrol.Year
		
		