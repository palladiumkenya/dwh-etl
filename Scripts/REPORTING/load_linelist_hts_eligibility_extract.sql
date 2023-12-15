IF OBJECT_ID(N'[REPORTING].[dbo].[LineListHTSEligibilityExtract]', N'U') IS NOT NULL 			
	DROP TABLE [REPORTING].[dbo].[LineListHTSEligibilityExtract];


SELECT
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	pat.Gender,
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
INTO LineListHTSEligibilityExtract
FROM NDWH.dbo.FactHTSEligibilityextract ex
LEFT join NDWH.dbo.DimFacility f on f.FacilityKey = ex.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = ex.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = ex.PatientKey
LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = ex.PartnerKey
