IF OBJECT_ID(N'[NDWH].[dbo].[FactARTHistory]', N'U') IS NOT NULL 
DROP TABLE [NDWH].[dbo].[FactARTHistory];
 -- FactARTHistory Load
WITH MFL_partner_agency_combination AS (
	SELECT 
		MFL_Code,
		SDP,
		[SDP Agency] AS Agency
	FROM HIS_Implementation.dbo.All_EMRSites
)
SELECT 
	FactARTHistoryKey = IDENTITY(INT, 1, 1),
	facility.FacilityKey,
	partner.PartnerKey,
	agency.AgencyKey,
	patient.PatientKey,
	as_of.DateKey AS AsOfDateKey,
	CASE 
		WHEN txcurr_report.ARTOutcome = 'V' THEN 1
		ELSE 0
	END AS IsTXCurr,
	art_outcome.ARTOutcomeKey,
	CAST(GETDATE() AS DATE) AS LoadDate
INTO [NDWH].[dbo].[FactARTHistory]
FROM [ODS].[dbo].[HistoricalARTOutcomesBaseTable] AS txcurr_report
LEFT JOIN [NDWH].[dbo].[DimDate] as as_of 
	ON as_of.Date = txcurr_report.AsOfDate
LEFT JOIN [NDWH].[dbo].[DimFacility] as facility 
	ON facility.MFLCode = txcurr_report.MFLCode
LEFT JOIN [NDWH].[dbo].[DimPatient] as patient 
	ON patient.PatientPK =  CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(txcurr_report.PatientPK as NVARCHAR(36))), 2)          
	   and patient.SiteCode = txcurr_report.MFLCode
LEFT JOIN MFL_partner_agency_combination 
	ON  MFL_partner_agency_combination.MFL_Code COLLATE Latin1_General_CI_AS = txcurr_report.MFLCode COLLATE Latin1_General_CI_AS
LEFT JOIN dbo.DimPartner as partner 
	ON partner.PartnerName COLLATE Latin1_General_CI_AS= MFL_partner_agency_combination.SDP COLLATE Latin1_General_CI_AS
LEFT JOIN dbo.DimAgency as agency 
	ON agency.AgencyName COLLATE Latin1_General_CI_AS= MFL_partner_agency_combination.Agency COLLATE Latin1_General_CI_AS
LEFT JOIN dbo.DimARTOutcome as art_outcome 
	ON art_outcome.ARTOutcomeName = txcurr_report.ARTOutcome;

alter table dbo.FactARTHistory add primary key(FactARTHistoryKey);