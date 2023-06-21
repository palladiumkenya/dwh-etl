IF OBJECT_ID(N'REPORTING.[dbo].[AggregateHTSUptake]', N'U') IS NOT NULL 
TRUNCATE TABLE REPORTING.[dbo].[AggregateHTSUptake]
GO

INSERT INTO REPORTING.dbo.AggregateHTSUptake (MFLCode, FacilityName, County, SubCounty, PartnerName, AgencyName, Gender, AgeGroup,
	TestedBefore, year, month, MonthName, Tested, Positive, Linked
)
WITH CTE AS (
    SELECT 
        DISTINCT
        MFLCode,
        f.FacilityName,
        County,
        SubCounty,
        p.PartnerName,
        a.AgencyName,
        Gender,
        age.DATIMAgeGroup AS AgeGroup,
        TestedBefore,
        year,
        month,
        FORMAT(CAST(date AS date), 'MMMM') AS MonthName,
        SUM(Tested) AS Tested,
        SUM(Positive) AS Positive,
        SUM(Linked) AS Linked
    FROM NDWH.dbo.FactHTSClientTests hts
    LEFT JOIN NDWH.dbo.DimFacility f ON f.FacilityKey = hts.FacilityKey
    LEFT JOIN NDWH.dbo.DimAgency a ON a.AgencyKey = hts.AgencyKey
    LEFT JOIN NDWH.dbo.DimPatient pat ON pat.PatientKey = hts.PatientKey
    LEFT JOIN NDWH.dbo.DimAgeGroup age ON age.AgeGroupKey = hts.AgeGroupKey
    LEFT JOIN NDWH.dbo.DimPartner p ON p.PartnerKey = hts.PartnerKey
    LEFT JOIN NDWH.dbo.FactHTSClientLinkages link ON link.PatientKey = hts.PatientKey
    LEFT JOIN NDWH.dbo.DimDate d ON d.DateKey = hts.DateTestedKey
    WHERE TestType IN ('Initial Test', 'Initial')
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
        FORMAT(CAST(date AS date), 'MMMM')
),
CTE1 AS (
    SELECT 
        facility.MFLCode,
        facility.FacilityName,
        facility.SubCounty,
        facility.County,
        partner.PartnerName,
        agency.AgencyName,
        patient.Gender,
        age_group.DATIMAgeGroup,
        startDate.Year,
        startDate.Month,
        COUNT(*) AS countTXNew
    FROM NDWH.dbo.FactArt AS art
    LEFT JOIN NDWH.dbo.DimFacility AS facility ON facility.FacilityKey = art.FacilityKey
    LEFT JOIN NDWH.dbo.DimPartner AS partner ON partner.PartnerKey = art.PartnerKey
    LEFT JOIN NDWH.dbo.DimPatient AS patient ON patient.PatientKey = art.PatientKey
    LEFT JOIN NDWH.dbo.DimAgeGroup AS age_group ON age_group.AgeGroupKey = art.AgeGroupKey
    LEFT JOIN NDWH.dbo.DimAgency AS agency ON agency.AgencyKey = art.AgencyKey
    LEFT JOIN NDWH.dbo.DimARTOutcome AS outcome ON outcome.ARTOutcomeKey = art.ARTOutcomeKey
    LEFT JOIN NDWH.dbo.DimDate AS startDate ON startDate.DateKey = art.StartARTDateKey
    GROUP BY 
        facility.MFLCode,
        facility.FacilityName,
        facility.SubCounty,
        facility.County,
        partner.PartnerName,
        agency.AgencyName,
        patient.Gender,
        age_group.DATIMAgeGroup,
        startDate.Year,
        startDate.Month 
)
INSERT INTO REPORTING.dbo.AggregateHTSUptake (MFLCode, FacilityName, County, SubCounty, PartnerName, AgencyName, Gender, AgeGroup,
    TestedBefore, year, month, MonthName, Tested, Positive, Linked)
SELECT CTE.*, CTE1.countTXNew
FROM CTE
LEFT JOIN CTE1 ON CTE.MFLCode = CTE1.MFLCode;
