IF OBJECT_ID(N'[REPORTING].[dbo].AggregateOVCCount', N'U') IS NOT NULL 	
	drop TABLE [REPORTING].[dbo].AggregateOVCCount
GO

SELECT 
    MFLCode,
    f.FacilityName,
    County,
    SubCounty,
    p.PartnerName,
    a.AgencyName,
    Gender, 
    g.DATIMAgeGroup,
    pat.IsTXCurr as TXCurr,
    ao.ARTOutcome,
    count(*) as OVCElligiblePatientCount,
    CAST(GETDATE() AS DATE) AS LoadDate 
  INTO [REPORTING].[dbo].AggregateOVCCount
from [NDWH].[dbo].[FactOVC] it
INNER JOIN NDWH.dbo.DimDate enrld on enrld.DateKey = it.OVCEnrollmentDateKey
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = it.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = it.PartnerKey
INNER JOIN NDWH.dbo.FactART art on art.PatientKey = it.PatientKey
INNER JOIN NDWH.dbo.DimARTOutcome ao on ao.ARTOutcomeKey = art.ARTOutcomeKey
LEFT join NDWH.dbo.DimAgeGroup g on g.Age = art.AgeLastVisit
where art.AgeLastVisit between 0 and 17 and OVCExitReason is null and pat.IsTXCurr = 1
GROUP BY MFLCode,f.FacilityName,County,Subcounty,p.PartnerName,a.AgencyName,Gender,g.DATIMAgeGroup,pat.IsTXCurr, ao.ARTOutcome