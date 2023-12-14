IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateDSDStable]', N'U') IS NOT NULL 
	drop TABLE [REPORTING].[dbo].[AggregateDSDStable]
GO

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
    Sum(pat.isTXCurr) As TXCurr,
    cast(getdate() as date) as LoadDate
INTO REPORTING.dbo.AggregateDSDStable 
FROM NDWH.dbo.FactART as art
LEFT JOIN NDWH.dbo.FactLatestObs as lob on lob.Patientkey = art.PatientKey
LEFT JOIN NDWH.dbo.DimAgeGroup age on age.AgeGroupKey = lob.AgeGroupKey
LEFT JOIN NDWH.dbo.DimFacility f on f.FacilityKey = lob.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = lob.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = lob.PatientKey
LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = lob.PartnerKey
WHERE pat.isTXCurr = 1 and StabilityAssessment = 'Stable'
GROUP BY 
    MFLCode, 
    f.FacilityName,
    County, 
    SubCounty, 
    p.PartnerName,
    a.AgencyName, 
    Gender, 
    age.DATIMAgeGroup,
    DifferentiatedCare
    
GO
