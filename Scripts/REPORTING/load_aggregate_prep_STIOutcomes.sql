IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.[dbo].[AggregateSTIOutcomes]') AND type in (N'U')) 
TRUNCATE TABLE REPORTING.[dbo].[AggregateSTIOutcomes]
GO

INSERT INTO REPORTING.dbo.AggregateSTIOutcomes
		(MFLCode,
		FacilityName, 
		County,
		SubCounty,
		PartnerName, 
		AgencyName, 
		Gender, 
		AgeGroup,
		Positive,
		Negative
		)

SELECT DISTINCT 
		MFLCode,		
		f.FacilityName,
		County,
		SubCounty,
		p.PartnerName,
		a.AgencyName,
		Gender,
		age.DATIMAgeGroup as AgeGroup,
		sum(case  when STISymptoms is not null or STISymptoms <> '' then 1 else 0 END) as Positive,
        sum(case  when STISymptoms is null or STISymptoms = '' then 1 else 0 END) as Negative

FROM NDWH.dbo.FactPrep prep

LEFT join NDWH.dbo.DimFacility f on f.FacilityKey = prep.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = prep.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = prep.PatientKey
LEFT join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=prep.AgeGroupKey
LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = prep.PartnerKey
LEFT JOIN NDWH.dbo.DimDate d on d.DateKey = prep.VisitDateKey

GROUP BY  MFLCode,		
		f.FacilityName,
		County,
		SubCounty,
		p.PartnerName,
		a.AgencyName,
		Gender,
		age.DATIMAgeGroup	
		