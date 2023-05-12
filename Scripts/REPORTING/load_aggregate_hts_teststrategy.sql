IF OBJECT_ID(N'REPORTING.[dbo].[AggregateHTSTeststrategy]', N'U') IS NOT NULL 
	TRUNCATE TABLE REPORTING.[dbo].[AggregateHTSTeststrategy];
GO

INSERT INTO REPORTING.dbo.AggregateHTSTeststrategy (MFLCode, FacilityName, County, SubCounty, PartnerName, AgencyName, Gender, AgeGroup,
	TestStrategy, year, month, MonthName, Tested, Positive, Linked
)
SELECT
    MFLCode,
    f.FacilityName,
    County,
    SubCounty,
    p.PartnerName,
    a.AgencyName,
    Gender,
    age.DATIMAgeGroup as AgeGroup, 
    TestStrategy,
    year,
    month,
    FORMAT(cast(date as date), 'MMMM') MonthName,
    Sum(Tested) as TestedClients,
    Sum(Positive) as PositiveClients,
    Sum(Linked) as LinkedClients
FROM NDWH.dbo.FactHTSClientTests hts
LEFT JOIN NDWH.dbo.DimFacility f on f.FacilityKey = hts.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = hts.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = hts.PatientKey
LEFT JOIN NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=hts.AgeGroupKey
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
    Gender, age.DATIMAgeGroup, 
    TestStrategy, 
    year, 
    month, 
    FORMAT(cast(date as date), 'MMMM')