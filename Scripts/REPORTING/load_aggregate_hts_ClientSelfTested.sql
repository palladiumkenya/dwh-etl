IF OBJECT_ID(N'REPORTING.[dbo].[AggregateClientSelfTested]', N'U') IS NOT NULL 
	TRUNCATE TABLE REPORTING.[dbo].[AggregateClientSelfTested]
GO
INSERT INTO REPORTING.dbo.AggregateClientSelfTested
		(MFLCode,
		FacilityName, 
		County,
		SubCounty,
		PartnerName, 
		AgencyName, 
		Gender, 
		AgeGroup,
		year,
		month,
		MonthName,
		Tested,
		Linked,
		Positive,
		ClientSelfTested
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
		d.year,
		d.month,		
		DATENAME(month, d.Date) AS MonthName,
		SUM(Tested) as Tested,
		SUM(Linked) as Linked,
		SUM(Positive) as Positive,
		SUM(CASE WHEN ClientSelfTested = 'Yes' or ClientSelfTested = '1' then 1 else 0 end) as ClientSelfTested
FROM NDWH.dbo.FactHTSClientTests hts
LEFT join NDWH.dbo.DimFacility f on f.FacilityKey = hts.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = hts.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = hts.PatientKey
LEFT join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=hts.AgeGroupKey
LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = hts.PartnerKey
LEFT JOIN NDWH.dbo.DimDate d on d.DateKey = hts.DateTestedKey
where TestType in ('Initial test','Initial')
GROUP BY  MFLCode,		
		f.FacilityName,
		County,
		SubCounty,
		p.PartnerName,
		a.AgencyName,
		Gender,
		age.DATIMAgeGroup,
		d.year,
		d.month,
		d.Date
		

		