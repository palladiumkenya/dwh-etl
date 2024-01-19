IF OBJECT_ID(N'[Reporting].[Dbo].[aggregateUshauriSMSReminders]', N'U') IS NOT NULL DROP TABLE [Reporting].[Dbo].[aggregateUshauriSMSReminders];
BEGIN
   WITH BookedAppointments AS 
   (
      SELECT
         EOMONTH (Try_CONVERT(date, AppointmentDate)) AS AsofDate,
         COUNT(PatientKey) AS NumberBooked,
         MFLCode 
      FROM
         NDWH.dbo.FactUshauriSMSReminders sms 
         left join
            NDWH.dbo.DimFacility fac 
            on fac.FacilityKey = sms.FacilityKey 
      WHERE
         AppointmentStatus is not null 
      GROUP BY
         EOMONTH(Try_CONVERT(date, AppointmentDate)),
         MFLCode 
   )
,
   ConsentedAppointments AS 
   (
      SELECT
         EOMONTH (Try_CONVERT(date, AppointmentDate)) AS AsofDate,
         COUNT(PatientKey) AS NumberConsented,
         MFLCode 
      FROM
         NDWH.dbo.FactUshauriSMSReminders sms 
         left join
            NDWH.dbo.DimFacility fac 
            on fac.FacilityKey = sms.FacilityKey 
      WHERE
         ConsentForSMS = 'YES' 
      GROUP BY
         EOMONTH (Try_CONVERT(date, AppointmentDate)),
         MFLCode 
   )
,
   ReceivedSMS AS 
   (
      SELECT
         COALESCE( Try_CONVERT(date, FourWeekSMSSendDate), Try_CONVERT(date, ThreeWeekSMSSendDate), Try_CONVERT(date, TwoWeekSMSSendDate), Try_CONVERT(date, OneWeekSMSSendDate), Try_CONVERT (date, OneDaySMSSendDate) ) AS AsofDate,
         COUNT(PatientKey) AS NumberReceivedSMS,
         MFLCode 
      FROM
         NDWH.dbo.FactUshauriSMSReminders sms 
         left join
            NDWH.dbo.DimFacility fac 
            on fac.FacilityKey = sms.FacilityKey 
      WHERE
         coalesce (FourWeekSMSSent, ThreeWeekSMSSent, TwoWeekSMSSent, OneWeekSMSSent, OneDaySMSSent) = 'Success' 
      GROUP BY
         Try_CONVERT(date, FourWeekSMSSendDate),
         Try_CONVERT(date, ThreeWeekSMSSendDate),
         Try_CONVERT(date, TwoWeekSMSSendDate),
         Try_CONVERT(date, OneWeekSMSSendDate),
         Try_CONVERT (date, OneDaySMSSendDate),
         MFLCode 
   )
,
   HonouredAppointments AS 
   (
      SELECT
         EOMONTH(Try_CONVERT(date, AppointmentDate)) AS AsofDate,
         COUNT(PatientKey) AS NumberHonouredAppointment,
         MFLCode 
      FROM
         NDWH.dbo.FactUshauriSMSReminders sms 
         left join
            NDWH.dbo.DimFacility fac 
            on fac.FacilityKey = sms.FacilityKey 
      WHERE
         AppointmentStatus = 'honoured' 
      GROUP BY
         EOMONTH (Try_CONVERT(date, AppointmentDate)),
         MFLCode 
   )
,
   AppointmentCounts AS 
   (
      SELECT
         EOMONTH (Try_CONVERT(date, AppointmentDate)) AS AsofDate,
         COUNT(PatientKey) AS TotalAppointments,
         MFLCode 
      FROM
         NDWH.dbo.FactUshauriSMSReminders sms 
         left join
            NDWH.dbo.DimFacility fac 
            on fac.FacilityKey = sms.FacilityKey 
      GROUP BY
         EOMONTH (Try_CONVERT(date, AppointmentDate)),
         MFLCode 
   )
,
   Facilityinfo AS 
   (
      Select
         MFL_Code,
         County,
         SDP,
         EMR 
      from
         ODS.dbo.All_EMRSites 
   )
   SELECT
      AppointmentCounts.MFLCode,
      AppointmentCounts.AsofDate,
      COALESCE(BookedAppointments.NumberBooked, 0) AS NumberBooked,
      COALESCE(ConsentedAppointments.NumberConsented, 0) AS NumberConsented,
      COALESCE(ReceivedSMS.NumberReceivedSMS, 0) AS NumberReceivedSMS,
      COALESCE(HonouredAppointments.NumberHonouredAppointment, 0) AS NumberHonouredAppointment,
      COALESCE(CAST(HonouredAppointments.NumberHonouredAppointment AS FLOAT) / AppointmentCounts.TotalAppointments * 100, 0) AS PercentHonoured INTO Reporting.Dbo.aggregateUshauriSMSReminders 
   FROM
      AppointmentCounts 
      LEFT JOIN
         BookedAppointments 
         ON AppointmentCounts.MFLCode = BookedAppointments.MFLCode 
         and BookedAppointments.AsofDate = AppointmentCounts.AsofDate 
      LEFT JOIN
         ConsentedAppointments 
         ON AppointmentCounts.MFLCode = ConsentedAppointments.MFLCode 
         and AppointmentCounts.AsofDate = ConsentedAppointments.AsofDate 
      LEFT JOIN
         ReceivedSMS 
         ON AppointmentCounts.MFLCode = ReceivedSMS.MFLCode 
         and AppointmentCounts.AsofDate = ReceivedSMS.AsofDate 
      LEFT JOIN
         HonouredAppointments 
         ON AppointmentCounts.MFLCode = ReceivedSMS.MFLCode 
         and AppointmentCounts.AsofDate = ReceivedSMS.AsofDate 
   where
      AppointmentCounts.MFLCode > 0 
      and AppointmentCounts.AsofDate is not null 
END