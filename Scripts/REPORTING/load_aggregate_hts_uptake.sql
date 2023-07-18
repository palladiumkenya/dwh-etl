IF OBJECT_ID(N'REPORTING.[dbo].[AggregateHTSUptake]', N'U') IS NOT NULL 
drop TABLE REPORTING.[dbo].[AggregateHTSUptake]
GO

SELECT 
	DISTINCT
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	Gender,
	age.DATIMAgeGroup as AgeGroup,
	TestedBefore,
	year,
	month,
	FORMAT(cast(date as date), 'MMMM') as MonthName,
	Sum(Tested) as Tested,
	Sum(Positive) as Positive,
	Sum(Linked) as Linked,
    CAST(GETDATE() AS DATE) AS LoadDate 
    INTO REPORTING.dbo.AggregateHTSUptake
FROM NDWH.dbo.FactHTSClientTests hts
LEFT join NDWH.dbo.DimFacility f on f.FacilityKey = hts.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = hts.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = hts.PatientKey
LEFT join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=hts.AgeGroupKey
LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = hts.PartnerKey
LEFT JOIN NDWH.dbo.FactHTSClientLinkages link on link.PatientKey = hts.PatientKey
LEFT JOIN NDWH.dbo.DimDate d on d.DateKey = hts.DateTestedKey
WHERE TestType in ('Initial Test', 'Initial')
GROUP BY 
	MFLCode, 
	f.FacilityName,
	County, 
	SubCounty, 
	p.PartnerName, 
	a.AgencyName, 
	Gender, 
	age.DATIMAgeGroup, 
	TestedBefore, 
	year, 
	month, 
	FORMAT(cast(date as date), 'MMMM')