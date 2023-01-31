Go
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[REPORTING].[dbo].[AggregateOTZ]') AND type in (N'U'))
TRUNCATE TABLE [REPORTING].[dbo].[AggregateOTZ]
GO

INSERT INTO REPORTING.dbo.AggregateOTZ
SELECT DISTINCT
MFLCode,
f.FacilityName,
County,
SubCounty,
p.PartnerName as CTPartner,
a.AgencyName as CTAgency,
Gender,
age.DATIMAgeGroup as AgeGroup,
CONVERT(char(7), cast(cast(OTZEnrollmentDateKey as char) as datetime), 23) as OTZEnrollmentYearMonth,
count(*) as Enrolled,
-- sum(case when otz.OTZEnrollmentDateKey is null then 1 else 0 end) as NotEnrolled,
sum(case when otz.ModulesPreviouslyCovered is not null then 1 else 0 end) as CompletedTraining,
TransferInStatus,
ModulesPreviouslyCovered,
SUM(ModulesCompletedToday_OTZ_Orientation) as CompletedToday_OTZ_Orientation,
SUM(ModulesCompletedToday_OTZ_Participation) as CompletedToday_OTZ_Participation,
SUM(ModulesCompletedToday_OTZ_Leadership) as CompletedToday_OTZ_Leadership,
SUM(ModulesCompletedToday_OTZ_MakingDecisions) as CompletedToday_OTZ_MakingDecisions,
SUM(ModulesCompletedToday_OTZ_Transition) as CompletedToday_OTZ_Transition,
SUM(ModulesCompletedToday_OTZ_TreatmentLiteracy) as CompletedToday_OTZ_TreatmentLiteracy,
SUM(ModulesCompletedToday_OTZ_SRH) as CompletedToday_OTZ_SRH,
SUM(ModulesCompletedToday_OTZ_Beyond) as CompletedToday_OTZ_Beyond,
FirstVL,
LastVL,
SUM(vl.EligibleVL) as EligibleVL,
Last12MonthVLResults,
CASE 
	WHEN ISNUMERIC(vl.Last12MonthVLResults) = 1 
		THEN CASE WHEN CAST(Replace(vl.Last12MonthVLResults,',','')AS FLOAT) < 400.00 THEN 'VL' 
		WHEN CAST(Replace(vl.Last12MonthVLResults,',','')AS FLOAT) between 400.00 and 1000.00 THEN 'LVL'
		WHEN CAST(Replace(vl.Last12MonthVLResults,',','') AS FLOAT) > 1000.00 THEN 'HVL'
		ELSE NULL END 
	ELSE 
		CASE WHEN vl.Last12MonthVLResults  IN ('Undetectable','NOT DETECTED','0 copies/ml','LDL','Less than Low Detectable Level') THEN 'VL' 
		ELSE NULL END  
	END AS Last12MVLResult,
SUM(vl.Last12MonthVL) as Last12MonthVL,
Count(*) TotalOTZ

FROM NDWH.dbo.FactOTZ otz
INNER join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=otz.AgeGroupKey
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = otz.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = otz.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = otz.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = otz.PartnerKey
LEFT JOIN NDWH.dbo.FactViralLoads vl on vl.PatientKey = otz.PatientKey and vl.PatientKey IS NOT NULL
WHERE age.Age BETWEEN 10 AND 24 AND IsTXCurr = 1
GROUP BY MFLCode, f.FacilityName, County, SubCounty, p.PartnerName, a.AgencyName, Gender, age.DATIMAgeGroup, CONVERT(char(7), cast(cast(OTZEnrollmentDateKey as char) as datetime), 23), TransferInStatus, ModulesPreviouslyCovered, vl.FirstVL, vl.LastVL, vl.Last12MonthVLResults, Last12MVLResult
