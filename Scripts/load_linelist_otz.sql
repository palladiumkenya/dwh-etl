IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LineListOTZ]') AND type in (N'U'))
TRUNCATE TABLE [dbo].[LineListOTZ]
GO

INSERT INTO REPORTING.dbo.LineListOTZ
SELECT DISTINCT
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName as CTPartner,
	a.AgencyName as CTAgency,
	Gender,
	age.DATIMAgeGroup as AgeGroup,otz_enrollment.DateKey as OTZEnrollmentDateKey,
	LastVisitDateKey,
	TransitionAttritionReason,
	TransferInStatus,
	ModulesPreviouslyCovered,
	ModulesCompletedToday_OTZ_Orientation,
	ModulesCompletedToday_OTZ_Participation,
	ModulesCompletedToday_OTZ_Leadership,
	ModulesCompletedToday_OTZ_MakingDecisions,
	ModulesCompletedToday_OTZ_Transition,
	ModulesCompletedToday_OTZ_TreatmentLiteracy,
	ModulesCompletedToday_OTZ_SRH,
	ModulesCompletedToday_OTZ_Beyond,
	FirstVL,
	LastVL,
	vl.EligibleVL,
	Last12MVLResult as Last12MonthVLResults,
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
	vl.Last12MonthVL as Last12MonthVL

FROM NDWH.dbo.FactOTZ otz
INNER join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=otz.AgeGroupKey
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = otz.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = otz.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = otz.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = otz.PartnerKey
LEFT JOIN NDWH.dbo.FactViralLoads vl on vl.PatientKey = otz.PatientKey and vl.PatientKey IS NOT NULL
WHERE age.Age BETWEEN 10 AND 24
GO
