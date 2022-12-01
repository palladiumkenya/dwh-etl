 -- FactARTHistory Load
IF OBJECT_ID(N'[NDWH].[dbo].[FactARTHistory]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FactARTHistory];
BEGIN
	with MFL_partner_agency_combination as (
		select 
			MFL_Code,
			SDP,
			[SDP Agency] as Agency
		from HIS_Implementation.dbo.All_EMRSites
	)
	select
		FactKey = IDENTITY(INT, 1, 1),
		facility.FacilityKey,
		partner.PartnerKey,
		agency.AgencyKey,
		patient.PatientKey,
		as_of.DateKey as AsOfDateKey,
		case 
			when txcurr_report.ARTOutcome = 'V' then 1
			else 0
		end as IsTXCurr,
		art_outcome.ARTOutcomeKey,
		cast(getdate() as date) as LoadDate
	into [NDWH].[dbo].[FactARTHistory]
	from dbo.HistoricalARTOutcomesBaseTable as txcurr_report
	left join dbo.DimDate as as_of on as_of.Date = txcurr_report.AsOfDate
	left join dbo.DimFacility as facility on facility.MFLCode = txcurr_report.MFLCode
	left join dbo.DimPatient as patient on patient.PatientPK =  CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(txcurr_report.PatientPK as NVARCHAR(36))), 2)          
		and patient.SiteCode = txcurr_report.MFLCode
	left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = txcurr_report.MFLCode
	left join dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
	left join dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
	left join dbo.DimARTOutcome as art_outcome on art_outcome.ARTOutcome = txcurr_report.ARTOutcome;

	alter table dbo.FactARTHistory add primary key(FactKey);
END