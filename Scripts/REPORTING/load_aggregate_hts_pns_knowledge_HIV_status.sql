IF OBJECT_ID(N'REPORTING.[dbo].[AggregateHTSPNSKnowledgeHIVStatus]', N'U') IS NOT NULL 
TRUNCATE TABLE REPORTING.[dbo].[AggregateHTSPNSKnowledgeHIVStatus]
GO

With cte1 as (
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
), cte2 as (
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
), combined as (
    SELECT distinct 
		f.MFLCode Mflcode,
		f.FacilityName,
		f.County,
		f.SubCounty,
		AgencyName,
		p.PartnerName, 
		a.FinalTestResult,
		RelationsipToIndexClient,
		pat.PatientPkHash PatientPk,
		e.Date DateElicited, 
		j.Date TestDate, 
		j.month, 
		j.year,
		FORMAT(cast(j.date as date), 'MMMM') MonthName, 
		Gender,
		g.DATIMAgeGroup as Agegroup,
		Case 
			WHEN (b.PartnerPatientPk  is not null and b.PartnerPatientPk<> '') then 1            
		ELSE 0 End  ContactPatientPk,        
		Case 
			WHEN (c.FinalResult  is not null ) then 1 
		ELSE 0 End  FinalResult,        
		Case 
			WHEN (c.FinalResult  is not null and c.FinalResult='Positive' ) then 1
		ELSE 0 End  NewPositives, 
		Case 
			WHEN (c.FinalResult  is not null and c.FinalResult='Negative' ) then 1
		ELSE 0 End  NewNegatives,
		Case 
			WHEN (d.ReportedCCCNumber  is not null and d.ReportedCCCNumber<>'') then 1 
		ELSE 0 End  Linked,
		Case 
			WHEN (b.KnowledgeOfHivStatus='Positive' or b.KnowledgeOfHivStatus='703') then 1 
		ELSE 0 End  KP,
		Case 
			WHEN (b.KnowledgeOfHivStatus='Unknown' or b.KnowledgeOfHivStatus='1067') then 1
		ELSE 0 End  UnknownStatus
	FROM  NDWH.dbo.FactHTSClientTests a
	INNER JOIN NDWH.dbo.FactHTSPartnerNotificationServices b on b.PatientKey=a.PatientKey and b.FacilityKey=a.FacilityKey
	LEFT JOIN NDWH.dbo.DimPatient pat ON pat.PatientKey = b.PatientKey
	LEFT JOIN NDWH.dbo.DimPartner p ON p.PartnerKey = a.PartnerKey
	LEFT JOIN NDWH.dbo.DimFacility f ON f.FacilityKey = a.FacilityKey
	LEFT JOIN NDWH.dbo.DimAgency age ON a.AgencyKey = age.AgencyKey
	LEFT JOIN NDWH.dbo.DimFacility i ON i.FacilityKey = b.FacilityKey
	LEFT JOIN NDWH.dbo.DimDate e on b.DateElicitedKey = e.DateKey
	LEFT JOIN NDWH.dbo.DimDate j on a.DateTestedKey = j.DateKey
	LEFT JOIN NDWH.dbo.DimAgeGroup g on b.AgeGroupKey = g.AgeGroupKey
	LEFT JOIN cte1 c on c.PartnerPatientPk = b.PartnerPatientPk and c.SiteCode=i.MFLCode
	LEFT JOIN cte2 d on d.PartnerPatientPk = b.PartnerPatientPk and d.SiteCode=i.MFLCode
)

INSERT INTO REPORTING.dbo.AggregateHTSPNSKnowledgeHIVStatus (
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
	ContactElicited, 
	ContactTested,
	Positive, 
	Linked,
	KnownPositive, 
	NewNegatives,
	NewPositives, 
	UnknownStatus
)
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
	count(PatientPk)ContactElicited, 
	sum(ContactPatientPk)ContactTested,
	sum(FinalResult)Positive, 
	sum(Linked)Linked,
	sum(KP)KnownPositive, 
	sum(NewNegatives)NewNegatives,
	sum(NewPositives)NewPositives, 
	sum(UnknownStatus)UnknownStatus
from combined
where FinalTestResult='Positive'
Group by Mflcode,FacilityName,County,subcounty,PartnerName, year,month,monthName,Gender,Agegroup, AgencyName