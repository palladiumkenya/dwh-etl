IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateTimeToVL12M]', N'U') IS NOT NULL 	
	TRUNCATE TABLE [REPORTING].[dbo].[AggregateTimeToVL12M]
GO
INSERT INTO [REPORTING].dbo.AggregateTimeToVL12M
SELECT DISTINCT
MFLCode,
f.FacilityName,
SubCounty,
County,
 p.PartnerName,
 a.AgencyName,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
        OVER (PARTITION BY p.PartnerName) AS MedianTimeToFirstVL_Partner,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
        OVER (PARTITION BY County) AS MedianTimeToFirstVL_County,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
        OVER (PARTITION BY Subcounty) AS MedianTimeToFirstVL_SbCty,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
        OVER (PARTITION BY a.AgencyName) AS MedianTimeToFirstVL_CTAgency
FROM NDWH.dbo.FactViralLoads it
INNER join NDWH.dbo.DimAgeGroup g on g.AgeGroupKey=it.AgeGroupKey
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = it.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = it.PartnerKey
INNER JOIN NDWH.dbo.FactART art on art.PatientKey = it.PatientKey
WHERE DateDIFF(MONTH,StartARTDateKey,GETDATE())<=12 AND TimetoFirstVL IS NOT NULL
ORDER BY county desc