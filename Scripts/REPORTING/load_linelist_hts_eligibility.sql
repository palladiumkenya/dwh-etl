IF OBJECT_ID(N'[REPORTING].[dbo].[LinelistHTSEligibilty]', N'U') IS NOT NULL 			
	DROP TABLE [REPORTING].[dbo].[LinelistHTSEligibilty];


SELECT
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
    pat.PatientPKHash,
    pat.NUPI,
	pat.Gender,
	age_group.Age,
	age_group.DATIMAgeGroup AgeGroup,
	visit.Date VisitDate,
	HTSStrategy,
	HTSEntryPoint,
	PartnerHivStatus,
	UnknownStatusPartner,
	KnownStatusPartner,
	ExperiencedGBV,
	TypeGBV,
	EverOnPrep,
	CurrentlyOnPrep,
	TBStatus,
	HIVRiskCategory,
	EligibleForTest,
	ReasonsForIneligibility,
	ReferredForTesting,
	ReasonRefferredForTesting
	ReasonNotReffered
INTO LinelistHTSEligibilty
FROM NDWH.dbo.FactHTSEligibilityextract ex
LEFT join NDWH.dbo.DimFacility f on f.FacilityKey = ex.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = ex.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = ex.PatientKey
LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = ex.PartnerKey
LEFT JOIN NDWH.dbo.DimDate visit on visit.DateKey = ex.VisitDateKey
LEFT JOIN NDWH.dbo.DimAgeGroup as age_group on age_group.AgeGroupKey = DATEDIFF(YY,pat.DOB,visit.Date)
