IF EXISTS(SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.[dbo].[AggregatePrepTestingAt1MonthRefill]') AND type in (N'U')) 
TRUNCATE TABLE REPORTING.[dbo].[AggregatePrepTestingAt1MonthRefill]
GO

INSERT INTO REPORTING.dbo.AggregatePrepTestingAt1MonthRefill
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
	d.Month,
	d.Year,
	age.DATIMAgeGroup as AgeGroup,
	sum(case when DateDispenseMonth1 is not null then 1 else 0 end) refilled,
	sum(case when TestResultsMonth1 is not null then 1 else 0 end) tested,
	sum(case when TestResultsMonth1 is null then 1 else 0 end) nottested

FROM NDWH.dbo.FactPrepRefills prep

LEFT join NDWH.dbo.DimFacility f on f.FacilityKey = prep.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = prep.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = prep.PatientKey
LEFT join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=prep.AgeGroupKey
LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = prep.PartnerKey
LEFT JOIN NDWH.dbo.DimDate d on d.DateKey = prep.DateDispenseMonth1

GROUP BY MFLCode,		
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	pat.Gender,
	age.DATIMAgeGroup,
	d.Month,
	d.Year
