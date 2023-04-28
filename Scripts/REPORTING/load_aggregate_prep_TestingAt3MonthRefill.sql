IF EXISTS(SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.[dbo].[AggregatePrepTestingAt3MonthRefill]') AND type in (N'U')) 
TRUNCATE TABLE REPORTING.[dbo].[AggregatePrepTestingAt3MonthRefill]
GO

INSERT INTO REPORTING.dbo.AggregatePrepTestingAt3MonthRefill
	(MFLCode,
	FacilityName, 
	County,
	SubCounty,
	PartnerName, 
	AgencyName, 
	Gender, 
	Month,
	Year,
	AgeGroup,
	refilled,
	tested,
	nottested
	)
SELECT DISTINCT 
	MFLCode,		
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	pat.Gender,
	Month,
	Year,
	age.DATIMAgeGroup as AgeGroup,
	sum(case when DateDispenseMonth3 is not null then 1 else 0 end) refilled,
	sum(case when TestResultsMonth3 is not null then 1 else 0 end) tested,
	sum(case when TestResultsMonth3 is null then 1 else 0 end) nottested

FROM NDWH.dbo.FactPrepRefills prep

LEFT JOIN NDWH.dbo.DimFacility f on f.FacilityKey = prep.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = prep.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = prep.PatientKey
LEFT join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=prep.AgeGroupKey
LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = prep.PartnerKey
LEFT JOIN NDWH.dbo.DimDate test ON test.DateKey = DateDispenseMonth3 

GROUP BY  MFLCode,		
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	pat.Gender,
	age.DATIMAgeGroup,
	test.Month,
	test.Year