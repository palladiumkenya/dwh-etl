IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.[dbo].[AggegateTestingAt3MonthRefill]') AND type in (N'U')) 
TRUNCATE TABLE REPORTING.[dbo].[AggegateTestingAt3MonthRefill]
GO

INSERT INTO REPORTING.dbo.AggegateTestingAt3MonthRefill
		(MFLCode,
		FacilityName, 
		County,
		SubCounty,
		PartnerName, 
		AgencyName, 
		Gender, 
		AgeGroup,
		tested,
		nottested
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
		sum(case when Refil3DiffInDays is not null then 1 else 0 end) tested,
        sum(case when Refil3DiffInDays is null then 1 else 0 end) nottested

FROM NDWH.dbo.FactPrep prep

LEFT join NDWH.dbo.DimFacility f on f.FacilityKey = prep.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = prep.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = prep.PatientKey
LEFT join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=prep.AgeGroupKey
LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = prep.PartnerKey
 LEFT JOIN NDWH.dbo.DimDate visit ON visit.DateKey = prep.VisitDateKey 
 LEFT JOIN NDWH.dbo.DimDate test ON test.DateKey = DateTestMonth3Key 

GROUP BY  MFLCode,		
		f.FacilityName,
		County,
		SubCounty,
		p.PartnerName,
		a.AgencyName,
		Gender,
		age.DATIMAgeGroup	
		