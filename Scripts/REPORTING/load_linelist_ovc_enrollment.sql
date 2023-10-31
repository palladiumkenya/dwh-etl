IF OBJECT_ID(N'[REPORTING].[dbo].LineListOVCEnrollments', N'U') IS NOT NULL 			
	DROP TABLE [REPORTING].[dbo].LineListOVCEnrollments
GO

SELECT
	pat.PatientPKHash,
	pat.PatientIDHash,
	pat.NUPI,
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	pat.Gender, 
	g.DATIMAgeGroup,
	g.Age,
	enrld.Date as OVCEnrollmentDate,
	rp.RelationshipWithPatient,
	EnrolledinCPIMS,
	CASE
	When EnrolledinCPIMS ='Yes' Then 'Yes'Else 'No'
	End as EnrolledinCPIMSCleaned,
	CPIMSUniqueIdentifierHash,
	PartnerOfferingOVCServices,
	OVCExitReason,
	exd.Date as ExitDate,
	FirstVL,
	fvd.Date as FirstVLDate,
	lastVL,
	lvd.Date as lastVLDate,
	ValidVLResultCategory1 as ValidVLResultCategory,
	validvl.Date as ValidVLDate,
	pat.IsTXCurr as TXCurr,
	CurrentRegimen,
	case 
	when CurrentRegimen like '%DTG%' then CurrentRegimen 
	else 'non DTG' 
	end as LastRegimen,
	onMMD,
	case 
		when ao.ARTOutcome is null then 'Others'
		else ao.ARTOutcomeDescription
	end as ARTOutcomeDescription,
	EligibleVL,
	HasValidVL as HasValidVL,
	ValidVLSup as VirallySuppressed,
    CAST(GETDATE() AS DATE) AS LoadDate 
INTO [REPORTING].[dbo].LineListOVCEnrollments
FROM [NDWH].[dbo].[FactOVC] it
LEFT JOIN NDWH.dbo.DimDate enrld on enrld.DateKey = it.OVCEnrollmentDateKey
LEFT JOIN NDWH.dbo.DimFacility f on f.FacilityKey = it.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = it.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = it.PatientKey
LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = it.PartnerKey
LEFT JOIN NDWH.dbo.FactART art on art.PatientKey = it.PatientKey
LEFT JOIN NDWH.dbo.FactViralLoads vl on vl.PatientKey = it.PatientKey
LEFT JOIN NDWH.dbo.DimAgeGroup g on g.Age = AgeLastVisit
LEFT JOIN NDWH.dbo.DimDate exd on exd.DateKey = it.OVCExitDateKey
LEFT JOIN NDWH.dbo.DimDate lvd on lvd.DateKey = vl.LastVLDateKey
LEFT JOIN NDWH.dbo.DimDate fvd on fvd.DateKey = vl.FirstVLDateKey
LEFT JOIN NDWH.dbo.DimDate validvl on validvl.DateKey = vl.ValidVLDateKey
LEFT JOIN NDWH.dbo.DimRelationshipWithPatient rp on rp.RelationshipWithPatientKey = it.RelationshipWithPatientKey
LEFT JOIN NDWH.dbo.DimARTOutcome ao on ao.ARTOutcomeKey = art.ARTOutcomeKey
LEFT JOIN NDWH.dbo.FactLatestObs lo on lo.PatientKey = it.PatientKey
where art.AgeLastVisit between 0 and 17 and OVCExitReason is null and IsTXCurr = 1