IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.[dbo].[AggregatePrepDiscontinuation]') AND type in (N'U')) 
TRUNCATE TABLE REPORTING.[dbo].[AggregatePrepDiscontinuation]
GO

INSERT INTO REPORTING.dbo.AggregatePrepDiscontinuation
		(MFLCode,
		FacilityName, 
		County,
		SubCounty,
		PartnerName, 
		AgencyName, 
		Gender, 
		AgeGroup,
		ExitMonth,
		ExitYear,
		PrepDiscontinuations
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
		DATENAME(month, d.Date) AS ExitMonth,		
	    Datepart (year,d.Date) As ExitYear,
	    Count (distinct (concat(PrepNumber,PatientPKHash,MFLCode))) As PrepDiscontinuations

FROM NDWH.dbo.FactPrepDiscontinuation prep

LEFT join NDWH.dbo.DimFacility f on f.FacilityKey = prep.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = prep.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = prep.PatientKey
LEFT join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=prep.AgeGroupKey
LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = prep.PartnerKey
LEFT JOIN NDWH.dbo.DimDate d on d.DateKey = prep.ExitdateKey

GROUP BY  MFLCode,		
		f.FacilityName,
		County,
		SubCounty,
		p.PartnerName,
		a.AgencyName,
		Gender,
		age.DATIMAgeGroup,		
		d.Date
		