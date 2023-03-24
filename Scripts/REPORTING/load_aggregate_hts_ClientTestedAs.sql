IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.[dbo].[AggregateClientTestedAs]') AND type in (N'U')) 
TRUNCATE TABLE REPORTING.[dbo].[AggregateClientTestedAs]
GO

INSERT INTO REPORTING.dbo.AggregateClientTestedAs
		(MFLCode,
		FacilityName, 
		County,
		SubCounty,
		PartnerName, 
		AgencyName, 
		Gender, 
		AgeGroup,
		clientTestedAs,
		year,
		month,
		MonthName,
		Tested,
		Linked,
		Positive
		)
SELECT DISTINCT 
		MFLCode,		
		f.FacilityName,
		County,
		SubCounty,
		p.PartnerName,
		a.AgencyName,
		Gender,
		age.DATIMAgeGroup as AgeGroup,
		clientTestedAs,
		d.year,
		d.month,		
		DATENAME(month, d.Date) AS MonthName,
		SUM(Tested) as Tested,
		SUM(Linked) as Linked,
		SUM(Positive) as Positive



FROM NDWH.dbo.FactHTSClientTests hts

LEFT join NDWH.dbo.DimFacility f on f.FacilityKey = hts.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = hts.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = hts.PatientKey
LEFT join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=hts.AgeGroupKey
LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = hts.PartnerKey
LEFT JOIN NDWH.dbo.DimDate d on d.DateKey = hts.DateTestedKey

GROUP BY  MFLCode,		
		f.FacilityName,
		County,
		SubCounty,
		p.PartnerName,
		a.AgencyName,
		Gender,
		age.DATIMAgeGroup,
		ClientTestedAs,
		d.year,
		d.month,
		d.Date
		