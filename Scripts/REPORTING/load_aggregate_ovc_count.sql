IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[REPORTING].[dbo].[AggregateOVCCount]') AND type in (N'U'))
TRUNCATE TABLE [REPORTING].[dbo].AggregateOVCCount
GO

INSERT INTO [REPORTING].[dbo].AggregateOVCCount
SELECT 
MFLCode,
f.FacilityName,
County,
SubCounty,
p.PartnerName as CTPartner,
a.AgencyName as CTAgency,
Gender, 
g.DATIMAgeGroup,
pat.IsTXCurr as TXCurr,
 ARTOutcome,
 count(*) as OVCElligiblePatientCount
from [NDWH].[dbo].[FactOVC] it
INNER JOIN NDWH.dbo.DimDate enrld on enrld.DateKey = it.OVCEnrollmentDateKey
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = it.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = it.PartnerKey
INNER JOIN NDWH.dbo.FactART art on art.PatientKey = it.PatientKey
LEFT join NDWH.dbo.DimAgeGroup g on g.Age = art.AgeLastVisit
where art.AgeLastVisit between 0 and 17 and OVCExitReason is null and pat.IsTXCurr = 1
GROUP BY MFLCode,f.FacilityName,County,Subcounty,p.PartnerName,a.AgencyName,Gender,g.DATIMAgeGroup,pat.IsTXCurr, ARTOutcome