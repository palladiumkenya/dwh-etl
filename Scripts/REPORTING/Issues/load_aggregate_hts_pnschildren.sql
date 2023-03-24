IF EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.[dbo].[AggregateHTSPNSChildren]') AND type in (N'U'))
TRUNCATE TABLE REPORTING.[dbo].[AggregateHTSPNSChildren]
GO

with cte1 as ( 
	SELECT distinct 
		a.PartnerPatientPk,
		fac.[MFLCODE] SiteCode,
		fac.County,
		fac.SubCounty,
		a.ScreenedForIpv,
		a.CccNumber,
		c.FinalTestResult as FinalResult, 
		e.Date DateElicited,
		f.Date TestDate 
	FROM NDWH.dbo.FactHTSPartnerNotificationServices a
	LEFT JOIN NDWH.dbo.DimFacility fac on fac.FacilityKey = a.FacilityKey
	INNER JOIN ODS.dbo.HTS_clients b on b.PatientPkHash=a.PartnerPatientPk and b.SiteCode= fac.[MFLCode]
	INNER JOIN NDWH.dbo.FactHTSClientTests c on c.PatientKey=a.PatientKey and c.FacilityKey=a.FacilityKey
	LEFT JOIN NDWH.dbo.DimDate e on a.DateElicitedKey = e.DateKey
	LEFT JOIN NDWH.dbo.DimDate f on c.DateTestedKey = f.DateKey
),
cte2 as (
	SELECT distinct 
		a.PartnerPatientPk,
		fac.MFLCode SiteCode,
		fac.County,
		fac.SubCounty,
		a.ScreenedForIpv,
		a.CccNumber,
		c.FinalTestResult as FinalResult, 
		e.Date DateElicited,
		f.Date TestDate, 
		d.ReportedCCCNumber
-- 			d.ReportedStartARTDate 
	FROM NDWH.dbo.FactHTSPartnerNotificationServices a
	LEFT JOIN NDWH.dbo.DimFacility fac on fac.FacilityKey = a.FacilityKey
	INNER JOIN ODS.dbo.HTS_clients b on b.PatientPkHash=a.PartnerPatientPk and b.SiteCode= fac.[MFLCode]
	INNER JOIN NDWH.dbo.FactHTSClientTests c on c.PatientKey=a.PatientKey and c.FacilityKey=a.FacilityKey
	INNER JOIN NDWH.dbo.FactHTSClientLinkages d on d.PatientKey=a.PatientKey and d.FacilityKey=a.FacilityKey
	LEFT JOIN NDWH.dbo.DimDate e on a.DateElicitedKey = e.DateKey
	LEFT JOIN NDWH.dbo.DimDate f on c.DateTestedKey = f.DateKey 
),
combined as (
	SELECT distinct
		f.MFLCode,
		f.FacilityName,
		f.County,
		f.SubCounty,
		PartnerName,
		AgencyName,
		FinalTestResult as Positive,
		RelationsipToIndexClient, 
		a.FinalTestResult,
		pat.PatientPKHash,
		e.Date DateElicited,
		j.Date TestDate,
		j.year,
		j.month,
		FORMAT(cast(j.date as date), 'MMMM') MonthName, 
		Gender,
		DATIMAgeGroup Agegroup,
		Case 
			WHEN (b.PartnerPatientPk  is not null and b.PartnerPatientPk<>'') then 1 
		ELSE 0 End  ChildPatientPk,
		Case 
			WHEN (c.FinalResult  is not null ) then 1
		ELSE 0 End  FinalResult,
		Case 
			WHEN (d.ReportedCCCNumber  is not null ) then 1 
		ELSE 0 End  Linked,
		Case 
			WHEN (b.KnowledgeOfHivStatus='Positive') then 1 
		ELSE 0 End  KP    
	FROM  NDWH.dbo.FactHTSClientTests a
	INNER JOIN NDWH.dbo.FactHTSPartnerNotificationServices b on b.PatientKey=a.PatientKey and b.FacilityKey=a.FacilityKey
	LEFT JOIN NDWH.dbo.DimPatient pat ON pat.PatientKey = b.PatientKey
	LEFT JOIN NDWH.dbo.DimPartner p ON p.PartnerKey = a.PartnerKey
	LEFT JOIN NDWH.dbo.DimFacility f ON f.FacilityKey = a.FacilityKey
	LEFT JOIN NDWH.dbo.DimAgency age ON a.AgencyKey = age.AgencyKey
	LEFT JOIN NDWH.dbo.DimFacility i ON i.FacilityKey = b.FacilityKey
	LEFT JOIN NDWH.dbo.DimDate e on b.DateElicitedKey = e.DateKey
	LEFT JOIN NDWH.dbo.DimDate j on a.DateTestedKey = j.DateKey
	LEFT JOIN NDWH.dbo.DimDate h on DateLinkedToCareKey = h.DateKey
	LEFT JOIN NDWH.dbo.DimAgeGroup g on b.AgeGroupKey = g.AgeGroupKey
	LEFT JOIN cte1 c on c.PartnerPatientPk = b.PartnerPatientPk and c.SiteCode=i.MFLCode 
	LEFT JOIN cte2 d on d.PartnerPatientPk = b.PartnerPatientPk and d.SiteCode=i.MFLCode
	where RelationsipToIndexClient in ('Child') 
)
INSERT INTO REPORTING.dbo.AggregateHTSPNSChildren (
	MFLCode,
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
	ChildrenElicited, 
	ChildrenTested,
	ChildrenPositive, 
	ChildrenLiked, 
	ChildrenKnownPositive)

SELECT 
	Mflcode, 
	FacilityName, 
	County, 
	SubCounty, 
	PartnerName, 
	AgencyName,
	Gender,
	Agegroup,
	year,
	month,
	MonthName, 
	count(PatientPkHash)ChildrenElicited,
	sum(ChildPatientPk)ChildrenTested,
	sum(FinalResult)ChildrenPositive,
	sum(Linked)ChildrenLiked,
	sum(KP)ChildrenKnownPositive

from combined
where FinalTestResult='Positive'
Group by Mflcode,
FacilityName,
County,
subcounty,
PartnerName,
year,
month,
monthName,
Gender,
Agegroup,
AgencyName