
IF  EXISTS(SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'[REPORTING].[dbo].[AggregateTimeToVL]') AND type in (N'U')) 
TRUNCATE TABLE [REPORTING].[dbo].[AggregateTimeToVL]
GO

INSERT INTO [REPORTING].[dbo].[AggregateTimeToVL]
SELECT DISTINCT
MFLCode,
f.FacilityName,
SubCounty,
County,
p.PartnerName,
a.AgencyName,
Gender,
g.DATIMAgeGroup as AgeGroup,
year(StartARTDateKey) StartYr,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
        OVER (PARTITION BY Year(StartARTDateKey)) AS MedianTimeToFirstVL_year,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
        OVER (PARTITION BY Year(StartARTDateKey),p.PartnerName) AS MedianTimeToFirstVL_yearPartner,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
        OVER (PARTITION BY Year(StartARTDateKey),County) AS MedianTimeToFirstVL_yearCounty,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
        OVER (PARTITION BY Year(StartARTDateKey),Subcounty) AS MedianTimeToFirstVL_yearSbCty,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
        OVER (PARTITION BY Year(StartARTDateKey),f.FacilityName) AS MedianTimeToFirstVL_yearFacility,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
        OVER (PARTITION BY Year(StartARTDateKey), County, p.PartnerName) AS MedianTimeToFirstVL_yearCountyPartner,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
        OVER (PARTITION BY Year(StartARTDateKey), a.AgencyName) AS MedianTimeToFirstVL_yearCTAgency,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
        OVER (PARTITION BY Year(StartARTDateKey), Gender) AS MedianTimeToFirstVL_Gender,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
        OVER (PARTITION BY Year(StartARTDateKey), g.DATIMAgeGroup) AS MedianTimeToFirstVL_DATIM_AgeGroup
FROM NDWH.dbo.FactViralLoads it
INNER join NDWH.dbo.DimAgeGroup g on g.AgeGroupKey=it.AgeGroupKey
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = it.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = it.PartnerKey
INNER JOIN NDWH.dbo.FactART art on art.PatientKey = it.PatientKey
WHERE StartARTDateKey between cast('2011-01-01' as date) AND DateADD(MONTH,-6,GETDATE()) AND TimetoFirstVL IS NOT NULL