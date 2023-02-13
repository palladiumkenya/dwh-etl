IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateOptimizeStartRegimens]', N'U') IS NOT NULL	
	DROP  TABLE [REPORTING].[dbo].[AggregateOptimizeStartRegimens];

SELECT
	SiteCode,
	FacilityName,
	County,
	Subcounty,
	PartnerName,
	AgencyName,
	Agegroup,
	[DATIMAgeGroup],
	Gender,
	StartRegimen,
	StartARTMonth,
	StartARTYr,
	SUM ( ISTxCurr ) TXCurr,
	Firstregimen,
	Last12MVLResult 
INTO [REPORTING].[dbo].[AggregateOptimizeStartRegimens]
FROM
	(
	SELECT
		SiteCode,
		FacilityName,
		County,
		Subcounty,
		PartnerName,
		AgencyName,
		DateName( m, StartARTDateKey ) AS StartARTMonth,
		YEAR ( StartARTDateKey ) AS StartARTYr,
		CASE
			WHEN StartRegimen LIKE '3TC+DTG+TDF' THEN
			'TLD' 
			WHEN StartRegimen LIKE '3TC+EFV+TDF' THEN
			'TLE' 
			WHEN StartRegimen LIKE '%NVP%' THEN
			'NVP' ELSE 'Other Regimen' 
		END AS StartRegimen,
		StartRegimen AS Firstregimen,
		Gender,
		Agegrouping as Agegroup,
		DATIMAgeGroup,
		CASE
			WHEN ISNUMERIC( vl.Last12MonthVLResults ) = 1 THEN
				CASE
					WHEN CAST ( Replace( vl.Last12MonthVLResults, ',', '' ) AS FLOAT ) < 400.00 THEN
						'VL' 
					WHEN CAST ( Replace( vl.Last12MonthVLResults, ',', '' ) AS FLOAT ) BETWEEN 400.00 AND 1000.00 THEN
						'LVL' 
					WHEN CAST ( Replace( vl.Last12MonthVLResults, ',', '' ) AS FLOAT ) > 1000.00 THEN
						'HVL' ELSE NULL 
				END 
			ELSE CASE	
				WHEN vl.Last12MonthVLResults IN ( 'Undetectable', 'NOT DETECTED', '0 copies/ml', 'LDL', 'Less than Low Detectable Level' ) THEN
					'VL' ELSE NULL 
				END 
		END AS Last12MVLResult,
		ISTxCurr 
	FROM NDWH.dbo.FACTART art
	INNER JOIN NDWH.dbo.DimAgeGroup age ON art.AgeGroupKey = age.AgeGroupKey
	INNER JOIN NDWH.dbo.DimPartner part ON art.PartnerKey = part.PartnerKey
	INNER JOIN NDWH.dbo.DimAgency a ON art.AgencyKey = a.AgencyKey
	INNER JOIN NDWH.dbo.DimFacility fac ON art.FacilityKey = fac.FacilityKey
	INNER JOIN NDWH.dbo.DimPatient pat ON art.PatientKey = pat.PatientKey
	LEFT JOIN NDWH.dbo.FACTViralLoads vl ON art.PatientKey = vl.PatientKey 
	WHERE ISTxCurr = 1 
	) H 
	GROUP BY SiteCode, FacilityName, County, Subcounty,	PartnerName, AgencyName, StartRegimen, Agegroup, [DATIMAgeGroup], Gender, StartARTMonth, StartARTYr, Firstregimen, Last12MVLResult;