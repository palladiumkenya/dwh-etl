IF  EXISTS (SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'[REPORTING].[dbo].[LineListALHIV]') AND type in (N'U'))
TRUNCATE TABLE [REPORTING].[dbo].[LineListALHIV]
GO
--- A linelist of ALHIV patients (Enrolled + Not Enrolled to OTZ)
INSERT INTO REPORTING.dbo.LineListALHIV
SELECT DISTINCT
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName as CTPartner,
	a.AgencyName as CTAgency,
	Gender,
	age.DATIMAgeGroup as AgeGroup,
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
	vl.Last12MonthVL as Last12MonthVL

FROM NDWH.dbo.FACTART art
INNER join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey= art.AgeGroupKey
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = art.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = art.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = art.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = art.PartnerKey
LEFT JOIN NDWH.dbo.FactViralLoads vl on vl.PatientKey = art.PatientKey and vl.PatientKey IS NOT NULL
WHERE age.Age BETWEEN 10 AND 24 AND IsTXCurr = 1
GO
