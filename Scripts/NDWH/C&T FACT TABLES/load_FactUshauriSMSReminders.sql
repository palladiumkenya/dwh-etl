IF OBJECT_ID(N'[NDWH].[dbo].[FACTUshauriSMSReminders]', N'U') IS NOT NULL DROP TABLE [NDWH].[dbo].[FACTUshauriSMSReminders];
BEGIN
   With MFL_partner_agency_combination as 
   (
      select distinct
         MFL_Code,
         SDP,
         SDP_Agency as Agency 
      from
         ODS.dbo.All_EMRSites 
   )
   Select
      FactKey = IDENTITY(INT, 1, 1),
      facility.FacilityKey,
      partner.PartnerKey,
      patient.PatientKey,
      agency.AgencyKey,
      EOMONTH(Try_CONVERT(date, AppointmentDate)) AS AsofDate,
      apt.MaritalStatus,
      age_group.AgeGroupKey,
      cast (appointment.Datekey as date) as AppointmentDate,
      AppointmentType,
      AppointmentStatus,
      EntryPoint,
      VisitType,
      cast(attended.DateKey as date) as DateAttended,
      apt.DOB,
      ConsentForSMS,
      SMSLanguage,
      SMSTargetGroup,
      SMSPreferredSendTime,
      FourWeekSMSSent,
      cast (FourweeksDate.Datekey as date) as FourWeekSMSSendDate,
      FourWeekSMSDeliveryStatus,
      FourWeekSMSDeliveryFailureReason,
      ThreeWeekSMSSent,
      Cast (ThreeweeksDate.Datekey as date) as ThreeWeekSMSSendDate,
      ThreeWeekSMSDeliveryStatus,
      ThreeWeekSMSDeliveryFailureReason,
      TwoWeekSMSSent,
      Cast (TwoweeksDate.Datekey as date) as TwoWeekSMSSendDate,
      TwoWeekSMSDeliveryStatus,
      TwoWeekSMSDeliveryFailureReason,
      OneWeekSMSSent,
      Cast (OneweeksDate.Datekey as date) as OneWeekSMSSendDate,
      OneWeekSMSDeliveryStatus,
      OneWeekSMSDeliveryFailureReason,
      OneDaySMSSent,
      Cast (OneDayDate.Datekey as date) as OneDaySMSSendDate,
      OneDaySMSDeliveryStatus,
      OneDaySMSDeliveryFailureReason,
      MissedAppointmentSMSSent,
      Cast (MissedappointmentDate.Datekey as date) as MissedAppointmentSMSSendDate,
      MissedAppointmentSMSDeliveryStatus,
      MissedAppointmentSMSDeliveryFailureReason,
      TracingCalls,
      TracingSMS,
      TracingHomeVisits,
      TracingOutcome,
      Cast (TracingDate.Datekey as date) As TracingOutcomeDate,
      Cast (DateReturnedToCare.DateKey as date ) as DateReturnedToCare,
      DaysDefaulted,
      NUPIHash into NDWH.dbo.FACTUshauriSMSReminders 
   FROM
      ODS.dbo.Ushauri_PatientAppointments as apt 
      left join
         NDWH.dbo.DimFacility as facility 
         on facility.MFLCode = apt.sitecode 
      left join
         MFL_partner_agency_combination 
         on MFL_partner_agency_combination.MFL_Code = apt.sitecode 
      left join
         NDWH.dbo.DimPartner as partner 
         on partner.PartnerName = MFL_partner_agency_combination.SDP 
      left join
         NDWH.dbo.DimPatient as patient 
         on patient.PatientPKHash = apt.PatientPKhash 
         and patient.SiteCode = apt.sitecode 
      left join
         NDWH.dbo.DimAgency as agency 
         on agency.AgencyName = MFL_partner_agency_combination.Agency 
      left join
         NDWH.dbo.DimAgeGroup as age_group 
         on age_group.AgeGroupKey = DATEDIFF(YY, patient.DOB, Try_Convert (date, AppointmentDate)) 
      left join
         NDWH.dbo.DimDate as as_of 
         on as_of.Date = Try_Convert(date, apt.AppointmentDate) 
      left join
         NDWH.dbo.DimDate as appointment 
         on appointment.Date = Try_Convert(date, apt.AppointmentDate) 
      left join
         NDWH.dbo.DimDate as attended 
         on attended.Date = Try_Convert(date, apt.DateAttended) 
      left join
         NDWH.dbo.DimDate as FourweeksDate 
         on FourweeksDate.Date = Try_Convert(date, apt.FourWeekSMSSendDate) 
      left join
         NDWH.dbo.DimDate as ThreeweeksDate 
         on ThreeweeksDate.Date = Try_convert(date, apt.ThreeWeekSMSSendDate) 
      left join
         NDWH.dbo.DimDate as TwoweeksDate 
         on TwoweeksDate.Date = Try_Convert(date, apt.TwoWeekSMSSendDate) 
      left join
         NDWH.dbo.DimDate as OneweeksDate 
         on OneweeksDate.Date = Try_Convert(date, apt.OneWeekSMSSendDate) 
      left join
         NDWH.dbo.DimDate as OneDayDate 
         on OneDayDate.Date = Try_Convert(date, apt.OneDaySMSSendDate) 
      left join
         NDWH.dbo.DimDate as MissedAppointmentDate 
         on MissedAppointmentDate.Date = Try_Convert(date, apt.MissedAppointmentSMSSendDate) 
      left join
         NDWH.dbo.DimDate as TracingDate 
         on TracingDate.Date = Try_Convert(date, apt.TracingOutcomeDate) 
      left join
         NDWH.dbo.DimDate as DateReturnedToCare 
         on DateReturnedToCare.Date = Try_Convert(date, apt.DateReturnedToCare) alter table NDWH.dbo.FACTUshauriSMSReminders add primary key(FactKey);
END