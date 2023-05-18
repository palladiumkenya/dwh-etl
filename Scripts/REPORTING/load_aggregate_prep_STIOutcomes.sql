IF EXISTS(SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.[dbo].[AggregatePrepSTIOutcomes]') AND type in (N'U')) 
TRUNCATE TABLE REPORTING.[dbo].[AggregatePrepSTIOutcomes]
GO

INSERT INTO REPORTING.dbo.AggregatePrepSTIOutcomes
		(MFLCode,
		FacilityName, 
		County,
		SubCounty,
		PartnerName, 
		AgencyName, 
		Gender,
		Month,
		Year,
		AgeGroup,
		NumberSTIScreened,
		NumberSTIPositive,
		NumberSTINegative,
		NumberSTITreated,
		NumberSTINotTreated
		)
SELECT DISTINCT 
		MFLCode,		
		f.FacilityName,
		County,
		SubCounty,
		p.PartnerName,
		a.AgencyName,
		Gender,
		d.Month,
		d.Year,
		age.DATIMAgeGroup as AgeGroup,
		SUM(CASE WHEN STIScreening = 'Yes' THEN 1 ELSE 0 END) NumberSTIScreened,
		sum(case  when STISymptoms is not null or STISymptoms <> '' then 1 else 0 END) as NumberSTIPositive,
		sum(case  when STISymptoms is null or STISymptoms = '' then 1 else 0 END) as NumberSTINegative,
		sum(case  when [STITreated] = 'Yes' then 1 else 0 END) as NumberSTITreated,
		sum(case  when [STITreated] = 'No' then 1 else 0 END) as NumberSTINotTreated

FROM NDWH.dbo.FactPrepVisits prep

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
		age.DATIMAgeGroup,
		d.Month,
		d.Year