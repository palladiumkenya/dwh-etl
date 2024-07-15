
IF OBJECT_ID(N'[NDWH].[dbo].[FactHistoricalVisits]', N'U') IS NOT NULL 
	DROP TABLE NDWH.[dbo].[FactHistoricalVisits];


BEGIN	
with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	    SDP_Agency as Agency 
	from ODS.dbo.All_EMRSites 
),
UniqueVisits as (
Select   row_number() OVER (PARTITION BY SiteCode,Patientpkhash, VisitDate ORDER BY VisitDate DESC) AS NUM,
	Patientpkhash,
	Sitecode,
	VisitDate,
	WHOStage,
	NextAppointmentDate,
	voided
	from ODS.dbo.CT_PatientVisits as visits
	
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
into NDWH.dbo.FactHistoricalVisits
from UniqueVisits as  visits
inner join ODS.dbo.CT_ARTPatients as art on art.PatientPKHash=visits.PatientPKHash and art.SiteCode=visits.SiteCode
inner join NDWH.dbo.DimPatient as patient on visits.PatientPKHash = patient.PatientPKHash and visits.SiteCode = patient.SiteCode
left join NDWH.dbo.DimFacility as facility on facility.MFLCode = visits.SiteCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = visits.SiteCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
left join NDWH.dbo.DimDate as VisitDate on VisitDate.Date=visits.VisitDate
left join NDWH.dbo.DimDate as StartARTDate on StartARTDate.Date=art.StartARTDate
left join NDWH.dbo.DimDate as NextAppointmentDate on NextAppointmentDate.Date=visits.NextAppointmentDate
WHERE Visits.voided =0 and Visits.NUM=1 and VisitDate >= EOMONTH(DATEADD(MONTH, -11, GETDATE())) 


alter table NDWH.dbo.FactHistoricalVisits add primary key(FactKey);
END



 