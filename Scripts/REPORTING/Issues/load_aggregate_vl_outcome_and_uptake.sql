IF OBJECT_ID(N'[REPORTING].[dbo].AggregateVLUptakeOutcome', N'U') IS NOT NULL 		
	truncate table [REPORTING].[dbo].AggregateVLUptakeOutcome
GO

INSERT INTO [REPORTING].dbo.AggregateVLUptakeOutcome (
  MFLCode,
  FacilityName,
  County,
  SubCounty,
  PartnerName ,
  AgencyName,
  Gender,
  StartARTYear,
  AgeGroup,
  TotalLast12MVL,
  Last12MVLResult,
  TXCurr,
  EligibleVL12Mnths,
  VLDone,
  VirallySuppressed,
  NewLast12MVLResult
)
SELECT 
  MFLCode,
  f.FacilityName,
  County,
  SubCounty,
  p.PartnerName as PartnerName,
  a.AgencyName as AgencyName,
  Gender,
  YEAR(art.StartARTDateKey) as StartARTYear,
  g.DATIMAgeGroup as AgeGroup,
  count(Last12MVLResult) as TotalLast12MVL,
  Last12MVLResult,
  sum(IsTXCurr) as TXCurr,
  sum(EligibleVL) as EligibleVL12Mnths,
  sum(Last12MonthVL) as VLDone,
  sum(Last12MVLSup) as VirallySuppressed,
  sum(Last12MonthVL) As NewLast12MVLResult
FROM NDWH.dbo.FactViralLoads it 
LEFT join NDWH.dbo.DimAgeGroup g on g.AgeGroupKey=it.AgeGroupKey
LEFT join NDWH.dbo.DimFacility f on f.FacilityKey = it.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = it.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = it.PatientKey
LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = it.PartnerKey
LEFT JOIN NDWH.dbo.FactART art on art.PatientKey = it.PatientKey
left join NDWH.dbo.DimARTOutcome as outcome on outcome.ARTOutcomeKey = art.ARTOutcomeKey
WHERE IsTXCurr=1 and outcome.ARTOutcome = 'V'
Group by MFLCode, f.FacilityName, County, SubCounty, p.PartnerName,a.AgencyName,Gender,
  g.DATIMAgeGroup,art.StartARTDateKey, Last12MVLResult