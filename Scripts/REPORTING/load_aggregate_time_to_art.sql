Go
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[REPORTING].[dbo].[AggregateTimeToART]') AND type in (N'U'))
TRUNCATE TABLE [REPORTING].[dbo].[AggregateTimeToART]
GO

INSERT INTO [REPORTING].dbo.AggregateTimeToART
SELECT DISTINCT
MFLCode,
f.FacilityName,
SubCounty,
County,
p.PartnerName as CTPartner,
a.AgencyName as CTAgency,
Gender,
g.DATIMAgeGroup as AgeGroup,
year(StartARTDateKey) as StartARTYear,
PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
        OVER (PARTITION BY Year(StartARTDateKey)) AS MedianTimeToARTDiagnosis_year,
PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
        OVER (PARTITION BY Year(StartARTDateKey),p.PartnerName) AS MedianTimeToARTDiagnosis_yearPartner,
PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
        OVER (PARTITION BY Year(StartARTDateKey),County) AS MedianTimeToARTDiagnosis_yearCounty,
PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
        OVER (PARTITION BY Year(StartARTDateKey),Subcounty) AS MedianTimeToARTDiagnosis_yearSbCty,
PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
        OVER (PARTITION BY Year(StartARTDateKey),FacilityName) AS MedianTimeToARTDiagnosis_yearFacility,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
        OVER (PARTITION BY Year(StartARTDateKey), County,p.PartnerName) AS MedianTimeToARTDiagnosis_YearCountyPartner,	
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
        OVER (PARTITION BY Year(StartARTDateKey), a.AgencyName) AS MedianTimeToARTDiagnosis_yearCTAgency,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
        OVER (PARTITION BY Gender) AS MedianTimeToART_Gender,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
        OVER (PARTITION BY g.DATIMAgeGroup) AS MedianTimeToART_DATIM_AgeGroup
FROM NDWH.dbo.FactART it
INNER join NDWH.dbo.DimAgeGroup g on g.Age=it.AgeAtEnrol
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = it.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = it.PartnerKey
WHERE MFLCode >1 and Year(StartARTDateKey) between 2011 and Year(GetDate())
