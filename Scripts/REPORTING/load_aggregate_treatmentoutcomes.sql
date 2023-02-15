IF  EXISTS (SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'[REPORTING].[dbo].[AggregateTreatmentOutcomes]') AND type in (N'U'))
	TRUNCATE TABLE [REPORTING].[dbo].[AggregateTreatmentOutcomes]
GO

INSERT INTO REPORTING.dbo.AggregateTreatmentOutcomes
SELECT DISTINCT
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	Gender,
	age.DATIMAgeGroup as AgeGroup,
	Year(StartARTDateKey) StartYear,
	Month(StartARTDateKey) StartMonth,
	ARTOutcomeDescription,
	Count(ARTOutcomeDescription) TotalOutcomes

FROM NDWH.dbo.FACTART art
INNER join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey= art.AgeGroupKey
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = art.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = art.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = art.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = art.PartnerKey
INNER JOIN NDWH.dbo.DimARTOutcome ot on ot.ARTOutcomeKey = art.ARTOutcomeKey

GROUP BY MFLCode, f.FacilityName, County, SubCounty, p.PartnerName, a.AgencyName, Gender, age.DATIMAgeGroup, Year(StartARTDateKey) ,
	Month(StartARTDateKey) ,ARTOutcomeDescription