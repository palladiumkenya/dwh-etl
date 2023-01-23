Go
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AggregateDSDStable]') AND type in (N'U'))
TRUNCATE TABLE [dbo].[AggregateDSDStable]
GO

INSERT INTO REPORTING.dbo.AggregateDSDStable
SELECT DISTINCT
MFLCode,
f.FacilityName,
County,
SubCounty,
p.PartnerName as CTPartner,
a.AgencyName as CTAgency,
Gender,
age.DATIMAgeGroup as AgeGroup,
DifferentiatedCare, 
COUNT(DifferentiatedCare) as MMDModels

FROM NDWH.dbo.FactLatestObs lob
INNER join NDWH.dbo.DimAgeGroup age on age.Age = lob.AgeAtARTStart
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = lob.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = lob.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = lob.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = lob.PartnerKey
WHERE pat.isTXCurr = 1 and StabilityAssessment = 'Stable'
GROUP BY MFLCode, f.FacilityName, County, SubCounty, p.PartnerName, a.AgencyName, Gender, age.DATIMAgeGroup, DifferentiatedCare
