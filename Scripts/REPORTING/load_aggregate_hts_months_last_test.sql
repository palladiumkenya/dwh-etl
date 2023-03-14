IF EXISTS(SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.[dbo].[AggregateHTSMonthsLastTest]') AND type in (N'U')) 
TRUNCATE TABLE REPORTING.[dbo].[AggregateHTSMonthsLastTest]
GO

INSERT INTO REPORTING.dbo.AggregateHTSMonthsLastTest (MFLCode, FacilityName, County, SubCounty, PartnerName, AgencyName, Gender, AgeGroup,
	MonthLastTest, year, month, MonthName, Tested, Positive, Linked
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
MonthsLastTest MonthLastTest,
year,
month,
FORMAT(cast(date as date), 'MMMM') MonthName,
Sum(Tested) Tested,
Sum(Positive) Positive,
Sum(Linked) Linked

FROM NDWH.dbo.FactHTSClientTests hts
LEFT join NDWH.dbo.DimFacility f on f.FacilityKey = hts.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = hts.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = hts.PatientKey
LEFT join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=hts.AgeGroupKey
LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = hts.PartnerKey
LEFT JOIN NDWH.dbo.FactHTSClientLinkages link on link.PatientKey = hts.PatientKey
LEFT JOIN NDWH.dbo.DimDate d on d.DateKey = hts.DateTestedKey
GROUP BY MFLCode, f.FacilityName, County, SubCounty, p.PartnerName, a.AgencyName, Gender, age.DATIMAgeGroup, MonthsLastTest, year, month, FORMAT(cast(date as date), 'MMMM')