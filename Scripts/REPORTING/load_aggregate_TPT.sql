IF OBJECT_ID(N'REPORTING.[dbo].[AggregateTPT]', N'U') IS NOT NULL 
DROP TABLE REPORTING.[dbo].[AggregateTPT]
GO

WITH Source_TPT AS (
    SELECT distinct 
        MFLCode,
        FacilityName,
        tpt.PatientKey,
        County,
        SubCounty,
        PartnerName,
        AgencyName,
        Gender,
        DATIMAgeGroup,
		StartTBTreatmentDate.Year AS StartTBTreatmentYear,
		StartTBTreatmentDate.Month AS StartTBTreatmentMonth,
		TBDiagnosisDate.Year AS TBDiagnosisYear,
		TBDiagnosisDate.Month as TBDiagnosisMonth,            
		OnIPT,
		hasTB     
    FROM NDWH.dbo.FactTPT tpt
    LEFT join NDWH.dbo.DimFacility f on f.FacilityKey = tpt.FacilityKey
    LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = tpt.AgencyKey
    LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = tpt.PatientKey
    LEFT join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=tpt.AgeGroupKey
    LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = tpt.PartnerKey   
    LEFT JOIN NDWH.dbo.DimDate StartTBTreatmentDate on StartTBTreatmentDate.DateKey = tpt.StartTBTreatmentDateKey
	LEFT JOIN NDWH.dbo.DimDate TBDiagnosisDate on TBDiagnosisDate.DateKey = tpt.TBDiagnosisDateKey
    
)
SELECT 
    MFLCode,
    FacilityName,
    County,
    SubCounty,
    PartnerName,
    AgencyName,
    Gender,
    DATIMAgeGroup as AgeGroup,
    StartTBTreatmentYear,
    StartTBTreatmentMonth,
    TBDiagnosisYear,
	TBDiagnosisMonth,
	SUM(CASE WHEN OnIPT = 'Yes' THEN 1 ELSE 0 END) AS OnIPT,    
    Sum(hasTB) hasTB
INTO REPORTING.dbo.AggregateTPT    
FROM Source_TPT
GROUP BY 
    MFLCode, 
    FacilityName, 
    County,
    SubCounty, 
    PartnerName, 
    AgencyName, 
    Gender, 
    DATIMAgeGroup,   
    StartTBTreatmentYear,
    StartTBTreatmentMonth,
    TBDiagnosisYear,
	TBDiagnosisMonth
    