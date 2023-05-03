IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateOTZEligibilityAndEnrollments]', N'U') IS NOT NULL 	
	TRUNCATE TABLE [REPORTING].[dbo].[AggregateOTZEligibilityAndEnrollments]
GO

INSERT INTO REPORTING.dbo.AggregateOTZEligibilityAndEnrollments (
	MFLCode,
	FacilityName,
	County,
	SubCounty,
	PartnerName,
	AgencyName,
	Gender,
	AgeGroup,
	OTZEnrollmentYearMonth,
	CompletedTraining,
	TransferInStatus,
	ModulesPreviouslyCovered,
	CompletedToday_OTZ_Orientation,
	CompletedToday_OTZ_Participation,
	CompletedToday_OTZ_Leadership,
	CompletedToday_OTZ_MakingDecisions,
	CompletedToday_OTZ_Transition,
	CompletedToday_OTZ_TreatmentLiteracy,
	CompletedToday_OTZ_SRH,
	CompletedToday_OTZ_Beyond,
	FirstVL,
	LastVL,
	EligibleVL,
	Last12MonthVLResults,
	Last12MVLResult,
	Last12MonthVL,
	patients_eligible,
	Enrolled
)

SELECT DISTINCT
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	Gender,
	age.DATIMAgeGroup AS AgeGroup,
	CONVERT ( CHAR ( 7 ), CAST ( CAST ( OTZEnrollmentDateKey AS CHAR ) AS datetime ), 23 ) AS OTZEnrollmentYearMonth,
	SUM ( CASE WHEN otz.ModulesPreviouslyCovered IS NOT NULL THEN 1 ELSE 0 END ) AS CompletedTraining,
	TransferInStatus,
	ModulesPreviouslyCovered,
	SUM ( ModulesCompletedToday_OTZ_Orientation ) AS CompletedToday_OTZ_Orientation,
	SUM ( ModulesCompletedToday_OTZ_Participation ) AS CompletedToday_OTZ_Participation,
	SUM ( ModulesCompletedToday_OTZ_Leadership ) AS CompletedToday_OTZ_Leadership,
	SUM ( ModulesCompletedToday_OTZ_MakingDecisions ) AS CompletedToday_OTZ_MakingDecisions,
	SUM ( ModulesCompletedToday_OTZ_Transition ) AS CompletedToday_OTZ_Transition,
	SUM ( ModulesCompletedToday_OTZ_TreatmentLiteracy ) AS CompletedToday_OTZ_TreatmentLiteracy,
	SUM ( ModulesCompletedToday_OTZ_SRH ) AS CompletedToday_OTZ_SRH,
	SUM ( ModulesCompletedToday_OTZ_Beyond ) AS CompletedToday_OTZ_Beyond,
	FirstVL,
	LastVL,
	SUM ( vl.EligibleVL ) AS EligibleVL,
	Last12MonthVLResults,
	CASE
		WHEN ISNUMERIC( vl.Last12MonthVLResults ) = 1 THEN
			CASE
				WHEN CAST ( Replace( vl.Last12MonthVLResults, ',', '' ) AS FLOAT ) < 400.00 THEN 'VL' 
				WHEN CAST ( Replace( vl.Last12MonthVLResults, ',', '' ) AS FLOAT ) BETWEEN 400.00 AND 1000.00 THEN 'LVL' 
				WHEN CAST ( Replace( vl.Last12MonthVLResults, ',', '' ) AS FLOAT ) > 1000.00 THEN 'HVL' ELSE NULL 
			END ELSE
				CASE
					WHEN vl.Last12MonthVLResults IN ( 'Undetectable', 'NOT DETECTED', '0 copies/ml', 'LDL', 'Less than Low Detectable Level' ) THEN 'VL' ELSE NULL 
				END 
			END AS Last12MVLResult,
	SUM ( vl.Last12MonthVL ) AS Last12MonthVL,
	COUNT ( * ) patients_eligible,
	COUNT(otz.PatientKey) as Enrolled
	
FROM NDWH.dbo.FACTART art

INNER JOIN NDWH.dbo.DimAgeGroup age ON age.AgeGroupKey= art.AgeGroupKey
INNER JOIN NDWH.dbo.DimFacility f ON f.FacilityKey = art.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a ON a.AgencyKey = art.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat ON pat.PatientKey = art.PatientKey
INNER JOIN NDWH.dbo.DimPartner p ON p.PartnerKey = art.PartnerKey
LEFT JOIN NDWH.dbo.FactViralLoads vl ON vl.PatientKey = art.PatientKey AND vl.PatientKey IS NOT NULL 
FULL OUTER JOIN NDWH.dbo.FactOTZ otz on otz.PatientKey = art.PatientKey

WHERE age.Age BETWEEN 10 AND 24  AND IsTXCurr = 1 

GROUP BY MFLCode,f.FacilityName,County,SubCounty,p.PartnerName,a.AgencyName,Gender,age.DATIMAgeGroup,CONVERT ( CHAR ( 7 ), CAST ( CAST ( OTZEnrollmentDateKey AS CHAR ) AS datetime ), 23 ),TransferInStatus,ModulesPreviouslyCovered,vl.FirstVL,vl.LastVL,vl.Last12MonthVLResults, CASE 
		WHEN ISNUMERIC(vl.Last12MonthVLResults) = 1 
			THEN CASE WHEN CAST(Replace(vl.Last12MonthVLResults,',','')AS FLOAT) < 400.00 THEN 'VL' 
			WHEN CAST(Replace(vl.Last12MonthVLResults,',','')AS FLOAT) between 400.00 and 1000.00 THEN 'LVL'
			WHEN CAST(Replace(vl.Last12MonthVLResults,',','') AS FLOAT) > 1000.00 THEN 'HVL'
			ELSE NULL END 
		ELSE 
			CASE WHEN vl.Last12MonthVLResults  IN ('Undetectable','NOT DETECTED','0 copies/ml','LDL','Less than Low Detectable Level') THEN 'VL' 
			ELSE NULL END  
		END 
GO