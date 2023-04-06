
IF OBJECT_ID(N'[NDWH].[dbo].[FACTAppointments]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FACTAppointments];
BEGIN
with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
		SDP,
	  SDP_Agency as Agency
	from ODS.dbo.All_EMRSites 
),

   Patient As ( Select    
      PatientPKHash,
      PatientIDHash,
      MFlCode,
      ExpectedNextAppointmentDate,
      LastEncounterDate,
      NextAppointmentDate,
      DiffExpectedTCADateLastEncounter,
      AppointmentStatus,
      AsOfDate,
      StartARTDate,
      ARTDurationMonths,
      DateRecieved

from 
ODS.dbo.[HistoricalAppointmentStatus] Patient

   )

   Select 
            Factkey = IDENTITY(INT, 1, 1),
            pat.PatientKey,
            fac.FacilityKey,
            partner.PartnerKey,
            agency.AgencyKey,
            StartARTDate.Date As StartARTDateKey,
            ExpectedNextAppointmentDate,
            Patient.LastEncounterDate,
            Patient.NextAppointmentDate,
            DiffExpectedTCADateLastEncounter,
            AppointmentStatus,
            AsOfDate,
            Patient.StartARTDate,
            ARTDurationMonths,
            DateRecieved,
            cast(getdate() as date) as LoadDate
INTO NDWH.dbo.FACTAppointments
from  Patient
left join NDWH.dbo.DimPatient as Pat on pat.PatientPKHash=Patient.PatientPkHash and Pat.SiteCode=Patient.MFLCode
left join NDWH.dbo.Dimfacility fac on fac.MFLCode=Patient.MFLCode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code  = Patient.MFLCode 
left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP 
left join NDWH.dbo.DimDate as StartARTDate on StartARTDate.Date= Patient.StartARTDate
left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency

alter table NDWH.dbo.FACTAppointments add primary key(FactKey)


END





