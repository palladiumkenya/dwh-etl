IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateDSDStable]', N'U') IS NOT NULL 
	TRUNCATE TABLE [REPORTING].[dbo].[AggregateDSDStable]
GO

INSERT INTO REPORTING.dbo.AggregateDSDStable (MFLCode,FacilityName,County,SubCounty, PartnerName, AgencyName,Gender, AgeGroup,DifferentiatedCare,  MMDModels, TXCurr)
SELECT DISTINCT
MFLCode,
f.FacilityName,
County,
SubCounty,
p.PartnerName,
a.AgencyName,
Gender,
age.DATIMAgeGroup as AgeGroup,
DifferentiatedCare, 
COUNT(DifferentiatedCare) as MMDModels,
Sum(pat.isTXCurr) As TXCurr

FROM NDWH.dbo.FactLatestObs lob
INNER JOIN NDWH.dbo.DimAgeGroup age on age.AgeGroupKey = lob.AgeGroupKey
INNER JOIN NDWH.dbo.DimFacility f on f.FacilityKey = lob.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = lob.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = lob.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = lob.PartnerKey
WHERE pat.isTXCurr = 1 and StabilityAssessment = 'Stable'
GROUP BY MFLCode, f.FacilityName, County, SubCounty, p.PartnerName, a.AgencyName, Gender, age.DATIMAgeGroup, DifferentiatedCare
GO
