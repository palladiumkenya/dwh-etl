IF  EXISTS (SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'[REPORTING].[dbo].[LineListOTZEligibilityAndEnrollments]') AND type in (N'U'))
	TRUNCATE TABLE [REPORTING].[dbo].[LineListOTZEligibilityAndEnrollments]
GO
--- A linelist of ALHIV patients (Enrolled + Not Enrolled to OTZ)
INSERT INTO REPORTING.dbo.LineListOTZEligibilityAndEnrollments
SELECT DISTINCT
				MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	Gender,
	age.DATIMAgeGroup as AgeGroup,
	otz.OTZEnrollmentDateKey,
	LastVisitDateKey,
	TransitionAttritionReason,
	TransferInStatus,
	case when otz.ModulesPreviouslyCovered is not null then 1 else 0 end as CompletedTraining,
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
	vl.Last12MonthVL as Last12MonthVL,
	CASE
	WHEN art.PatientKey is not null THEN 1
	ELSE 0 END as Eligible,
	CASE
	WHEN otz.PatientKey is not null THEN 1
	ELSE 0 END as Enrolled

	
	
FROM NDWH.dbo.FACTART art

INNER JOIN NDWH.dbo.DimAgeGroup age ON age.AgeGroupKey= art.AgeGroupKey
INNER JOIN NDWH.dbo.DimFacility f ON f.FacilityKey = art.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a ON a.AgencyKey = art.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat ON pat.PatientKey = art.PatientKey
INNER JOIN NDWH.dbo.DimPartner p ON p.PartnerKey = art.PartnerKey
LEFT JOIN NDWH.dbo.FactViralLoads vl ON vl.PatientKey = art.PatientKey AND vl.PatientKey IS NOT NULL 
FULL OUTER JOIN NDWH.dbo.FactOTZ otz ON otz.PatientKey = art.PatientKey
WHERE
		age.Age BETWEEN 10 AND 24 AND IsTXCurr = 1
GO