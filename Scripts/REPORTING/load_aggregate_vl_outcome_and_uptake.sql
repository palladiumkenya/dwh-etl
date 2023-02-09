
IF EXISTS(SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'[REPORTING].[dbo].[AggregateVLUptakeOutcome]') AND type in (N'U'))
TRUNCATE TABLE [REPORTING].[dbo].[AggregateVLUptakeOutcome]
GO
-- TODO::Fix StartARTYear & Last12MVLResult
INSERT INTO [REPORTING].dbo.AggregateVLUptakeOutcome
SELECT 
  MFLCode,
  f.FacilityName,
  County,
  SubCounty,
  p.PartnerName,
  a.AgencyName,
  Gender,
  art.StartARTDateKey as StartARTYear,
  g.DATIMAgeGroup as AgeGroup,
  count(Last12MVLResult) as TotalLast12MVL,
  Last12MVLResult,
  sum(IsTXCurr) as TXCurr,
  sum(EligibleVL) as EligibleVL12Mnths,
  sum(Last12MonthVL) as VLDone,
  sum(Last12MVLSup) as VirallySuppressed,
  sum(Last12MonthVL) As NewLast12MVLResult
FROM NDWH.dbo.FactViralLoads it 
INNER join NDWH.dbo.DimAgeGroup g on g.AgeGroupKey=it.AgeGroupKey
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = it.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = it.PartnerKey
INNER JOIN NDWH.dbo.FactART art on art.PatientKey = it.PatientKey
WHERE IsTXCurr=1
Group by MFLCode, f.FacilityName, County, SubCounty, p.PartnerName,a.AgencyName,Gender,
  g.DATIMAgeGroup,art.StartARTDateKey, Last12MVLResult