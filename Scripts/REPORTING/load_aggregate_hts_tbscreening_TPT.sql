IF OBJECT_ID(N'REPORTING.[dbo].[AggregateHTSTBscreeningIPT]', N'U') IS NOT NULL 
TRUNCATE TABLE REPORTING.[dbo].[AggregateHTSTBscreeningIPT]
GO

WITH tested AS (
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
		year,
        month,
        FORMAT(cast(date as date), 'MMMM') MonthName,      
		OnIPT,
		hasTB     
    FROM NDWH.dbo.FactTPT tpt
    LEFT join NDWH.dbo.DimFacility f on f.FacilityKey = tpt.FacilityKey
    LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = tpt.AgencyKey
    LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = tpt.PatientKey
    LEFT join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=tpt.AgeGroupKey
    LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = tpt.PartnerKey
    LEFT JOIN NDWH.dbo.FactHTSClientLinkages link on link.PatientKey = tpt.PatientKey
    LEFT JOIN NDWH.dbo.DimDate d on d.DateKey = tpt.StartTBTreatmentDateKey
    
)
INSERT INTO REPORTING.dbo.AggregateHTSTBscreeningIPT (
	MFLCode, 
	FacilityName, 
	County, 
	SubCounty, 
	PartnerName, 
	AgencyName, 
	Gender, 
	AgeGroup,
	year, 
	month, 
	MonthName, 
	OnIPT,
	hasTB
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
    year,
    month,
    MonthName,
	SUM(CASE WHEN OnIPT = 'Yes' THEN 1 ELSE 0 END) AS OnIPT,    
    Sum(hasTB) hasTB
    
FROM tested
GROUP BY 
    MFLCode, 
    FacilityName, 
    County,
    SubCounty, 
    PartnerName, 
    AgencyName, 
    Gender, 
    DATIMAgeGroup,   
    year, 
    month, 
    MonthName 
    