
IF OBJECT_ID(N'[NDWH].[dbo].[FactVisits]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FactVisits];


BEGIN	
with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency as Agency 
	from ODS.dbo.All_EMRSites 
)
select 
	Factkey = IDENTITY(INT, 1, 1),
	patient.PatientKey,
	facility.FacilityKey,
	partner.PartnerKey,
	agency.AgencyKey,
    StartARTDate.DateKey As StartARTDateKey,
    VisitDate.DateKey As VisitDateKey,
    NextAppointmentDate.DateKey As NextAppointmentDateKey,
	WHOStage,
	cast(getdate() as date) as LoadDate
into NDWH.dbo.FactVisits
from ODS.dbo.CT_PatientVisits as visits
left join ODS.dbo.CT_ARTPatients as art on art.PatientPKHash=visits.PatientPKHash and art.SiteCode=visits.SiteCode
left join NDWH.dbo.DimPatient as patient on visits.PatientPKHash = patient.PatientPKHash and visits.SiteCode = patient.SiteCode
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = visits.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = visits.SiteCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.dbo.DimDate as VisitDate on VisitDate.Date=visits.VisitDate
left join NDWH.dbo.DimDate as StartARTDate on StartARTDate.Date=art.StartARTDate
left join NDWH.dbo.DimDate as NextAppointmentDate on NextAppointmentDate.Date=visits.NextAppointmentDate
WHERE Visits.voided =0 and  VisitDate >= EOMONTH(DATEADD(MONTH, -12, GETDATE()))


alter table NDWH.dbo.FactVisits add primary key(FactKey);
END
