Go
IF  EXISTS (SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'[REPORTING].[dbo].[AggregateNupi]') AND type in (N'U'))
TRUNCATE TABLE [REPORTING].[dbo].[AggregateNupi]
GO

INSERT INTO REPORTING.dbo.AggregateNupi
SELECT DISTINCT
MFLCode,
f.FacilityName,
County,
SubCounty,
p.PartnerName as CTPartner,
a.AgencyName as CTAgency,
Gender,
age.DATIMAgeGroup as AgeGroup,
sum(CASE WHEN art.AgeLastVisit between 0 AND 18 THEN 1 ELSE 0 END) as number_children,
sum(CASE WHEN art.AgeLastVisit > 18 AND art.AgeLastVisit <= 120 THEN 1 ELSE 0 END) as number_adults,
count(pat.Nupi) as number_nupi

FROM NDWH.dbo.FactART art
INNER join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey= art.AgeGroupKey
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = art.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = art.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = art.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = art.PartnerKey

WHERE pat.Nupi is not NULL AND pat.IsTXCurr = 1
GROUP BY MFLCode, f.FacilityName, County, SubCounty, p.PartnerName, a.AgencyName, Gender, age.DATIMAgeGroup
