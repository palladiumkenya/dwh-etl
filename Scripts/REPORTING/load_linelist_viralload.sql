IF OBJECT_ID(N'[REPORTING].[dbo].[LineListViralLoad]', N'U') IS NOT NULL 			
	drop TABLE [REPORTING].[dbo].[LineListViralLoad]
GO

With Vls As (Select  
    MFLCode, 
    FacilityName, 
    County, 
    SubCounty, 
    PartnerName, 
    AgencyName, 
    Gender, 
    age.DATIMAgeGroup As Agegroup, 
    PatientPKHash, 
    PatientIDHash, 
    NUPI,
    LatestVL1, 
    LatestVLDate1Key, 
    LatestVL2,
    LatestVLDate2Key, 
    LatestVL3, 
    LatestVLDate3Key
FROM NDWH.dbo.FactViralLoads vl
INNER join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=vl.AgeGroupKey
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = vl.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = vl.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = vl.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = vl.PartnerKey
)
SELECT 
    MFLCode, 
    FacilityName, 
    County, 
    SubCounty, 
    PartnerName, 
    AgencyName, 
    Gender, 
    AgeGroup, 
    PatientPKHash, 
    PatientIDHash, 
    NUPI,
    LatestVL1, 
    LatestVLDate1Key, 
    LatestVL2,
    LatestVLDate2Key, 
    LatestVL3, 
    LatestVLDate3Key

into  REPORTING.dbo.LineListViralLoad
from Vls



GO