IF OBJECT_ID(N'REPORTING.[dbo].[AggregateHTSUptake]', N'U') IS NOT NULL 
TRUNCATE TABLE REPORTING.[dbo].[AggregateHTSUptake]
GO

INSERT INTO REPORTING.dbo.AggregateHTSUptake (
MFLCode, 
FacilityName,
SubCounty, 
County,
PartnerName, 
AgencyName,
Gender,
AgeGroup,
TestedBefore,
year, 
month,
MonthName,
countTXNew,
Tested,
Positive,
Linked
)

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
	FORMAT(cast(date as date), 'MMMM') as MonthName,
	COUNT(*) AS countTXNew,
	hts_data.TestedBefore,
    hts_data.Tested,
    hts_data.Positive,
    hts_data.Linked
FROM NDWH.dbo.FactArt AS art
LEFT JOIN NDWH.dbo.DimFacility AS facility ON facility.FacilityKey = art.FacilityKey
LEFT JOIN NDWH.dbo.DimPartner AS partner ON partner.PartnerKey = art.PartnerKey
LEFT JOIN NDWH.dbo.DimPatient AS patient ON patient.PatientKey = art.PatientKey
LEFT JOIN NDWH.dbo.DimAgeGroup AS age_group ON age_group.AgeGroupKey = art.AgeGroupKey
LEFT JOIN NDWH.dbo.DimAgency AS agency ON agency.AgencyKey = art.AgencyKey
LEFT JOIN NDWH.dbo.DimARTOutcome AS outcome ON outcome.ARTOutcomeKey = art.ARTOutcomeKey
LEFT JOIN NDWH.dbo.DimDate AS startDate ON startDate.DateKey = art.StartARTDateKey
LEFT JOIN
(
    SELECT 
        f.FacilityKey,
		hts.TestedBefore,
        SUM(hts.Tested) AS Tested,
        SUM(hts.Positive) AS Positive,
        SUM(hts.Linked) AS Linked
    FROM NDWH.dbo.FactHTSClientTests hts
    LEFT JOIN NDWH.dbo.DimFacility f ON f.FacilityKey = hts.FacilityKey
    LEFT JOIN NDWH.dbo.DimAgency a ON a.AgencyKey = hts.AgencyKey
    LEFT JOIN NDWH.dbo.DimPatient pat ON pat.PatientKey = hts.PatientKey
    LEFT JOIN NDWH.dbo.DimAgeGroup age ON age.AgeGroupKey = hts.AgeGroupKey
    LEFT JOIN NDWH.dbo.DimPartner p ON p.PartnerKey = hts.PartnerKey
    LEFT JOIN NDWH.dbo.FactHTSClientLinkages link ON link.PatientKey = hts.PatientKey
    LEFT JOIN NDWH.dbo.DimDate d ON d.DateKey = hts.DateTestedKey
    WHERE hts.TestType IN ('Initial Test', 'Initial')
    GROUP BY 
        f.FacilityKey,
		hts.TestedBefore

) AS hts_data ON hts_data.FacilityKey = facility.FacilityKey
GROUP BY 
    facility.MFLCode,
    facility.FacilityName,
    facility.SubCounty,
    facility.County,
    partner.PartnerName,
    agency.AgencyName,
    patient.Gender,
    age_group.DATIMAgeGroup,
	hts_data.TestedBefore,
	FORMAT(cast(date as date), 'MMMM'),
    startDate.Year,
    startDate.Month,
    hts_data.Tested,
    hts_data.Positive,
    hts_data.Linked;
