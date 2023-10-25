IF OBJECT_ID(N'[REPORTING].[dbo].[AggregatePBFW]', N'U') IS NOT NULL 
    DROP TABLE [REPORTING].[dbo].[AggregatePBFW];
GO

SELECT 
    Facility.FacilityName,
    Facility.MFLCode,
    Facility.County,
    Facility.SubCounty,
    Partner.PartnerName,
    Agency.AgencyName,
    Age_group.DATIMAgeGroup as AgeGroup,
    Patient.Gender,
     COUNT(Knownpositive) AS KnownPositives,
    COUNT(Newpositives) AS NewPositives,
    SUM(CASE WHEN RecieivedART = 1 AND KnownPositive = 1 THEN 1 ELSE 0 END) AS KnownPositivesOnART,
    SUM(CASE WHEN Eligiblevl = 1 AND KnownPositive = 1 THEN 1 ELSE 0 END) AS KnownPositivesEligiblevl,
    SUM(CASE WHEN try_cast (Validvlresultcategory as float ) = 1 AND KnownPositive = 1 THEN 1 ELSE 0 END) AS KnownPositivesValidVl,
    SUM(CASE WHEN suppressed = 1 AND KnownPositive = 1 THEN 1 ELSE 0 END) AS KnownPositivesSuppressed,
    SUM(CASE WHEN Unsuppressed = 1 AND KnownPositive = 1 THEN 1 ELSE 0 END) AS KnownPositivesUnsuppressed
INTO REPORTING.dbo.AggregatePBFW
FROM NDWH.dbo.FactPBFW AS PBFW
LEFT JOIN NDWH.dbo.DimFacility AS Facility ON Facility.FacilityKey = PBFW.FacilityKey
LEFT JOIN NDWH.dbo.DimPartner AS Partner ON Partner.PartnerKey = PBFW.PartnerKey
LEFT JOIN NDWH.dbo.DimAgency AS Agency ON Agency.AgencyKey = PBFW.AgencyKey
LEFT JOIN NDWH.dbo.DimAgeGroup AS Age_group ON Age_group.AgeGroupKey = PBFW.AgeGroupKey
LEFT JOIN NDWH.dbo.DimPatient AS Patient ON Patient.PatientKey = PBFW.PatientKey
GROUP BY 
    Facility.FacilityName,
    Facility.MFLCode,
    Facility.County,
    Facility.SubCounty,
    Partner.PartnerName,
    Agency.AgencyName,
    Age_group.DATIMAgeGroup,
    Patient.Gender;
