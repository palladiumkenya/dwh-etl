IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.[dbo].[AggregateHTSUptake]') AND type in (N'U')) 
TRUNCATE TABLE REPORTING.[dbo].[AggregateHTSUptake]
GO

INSERT INTO REPORTING.dbo.AggregateHTSUptake (MFLCode, FacilityName, County, SubCounty, PartnerName, AgencyName, Gender, AgeGroup,
	year, month, MonthName, Tested, Positive, Linked
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
year,
month,
FORMAT(cast(date as date), 'MMMM') MonthName,
Sum(Tested) Tested,
Sum(Positive) Positive,
Sum(Linked) Linked

FROM NDWH.dbo.FactHTSClientTests hts
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = hts.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = hts.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = hts.PatientKey
INNER join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=hts.AgeGroupKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = hts.PartnerKey
LEFT JOIN NDWH.dbo.FactHTSClientLinkages link on link.PatientKey = hts.PatientKey
LEFT JOIN NDWH.dbo.DimDate d on d.DateKey = hts.DateTestedKey
GROUP BY MFLCode, f.FacilityName, County, SubCounty, p.PartnerName, a.AgencyName, Gender, age.DATIMAgeGroup, year, month, FORMAT(cast(date as date), 'MMMM')