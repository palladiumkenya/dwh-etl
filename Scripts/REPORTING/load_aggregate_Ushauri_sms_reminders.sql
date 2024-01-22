IF Object_id(N'[Reporting].[Dbo].[AggregateUshauriSMSReminders]', N'U') IS NOT NULL
  DROP TABLE [Reporting].[Dbo].[AggregateUshauriSmsReminders];

BEGIN
    WITH Bookedappointments
         AS (SELECT Asofdate,
                    Count(Patientkey) AS NumberBooked,
                    Mflcode
             FROM   Ndwh.Dbo.Factushaurismsreminders Sms
                    LEFT JOIN Ndwh.Dbo.Dimfacility Fac
                           ON Fac.Facilitykey = Sms.Facilitykey
             WHERE  Appointmentstatus IS NOT NULL
             GROUP  BY Asofdate,
                       Mflcode),
         Consentedappointments
         AS (SELECT Asofdate,
                    Count(Patientkey) AS NumberConsented,
                    Mflcode
             FROM   Ndwh.Dbo.Factushaurismsreminders Sms
                    LEFT JOIN Ndwh.Dbo.Dimfacility Fac
                           ON Fac.Facilitykey = Sms.Facilitykey
             WHERE  Consentforsms = 'YES'
             GROUP  BY Asofdate,
                       Mflcode),
         Receivedsms AS (
              SELECT 
              COALESCE(Try_convert(Date,FourWeekSMSSendDateKey) , 
                               Try_convert(Date, ThreeWeekSMSSendDateKey) ,
                               Try_convert(Date, Twoweeksmssenddatekey) ,
                               Try_convert(Date, Oneweeksmssenddatekey) ,
                               Try_convert(Date, Onedaysmssenddatekey)) AS AsofDate,
                    Count(Patientkey) AS NumberReceivedSMS ,
                    Mflcode
             FROM   Ndwh.Dbo.Factushaurismsreminders Sms
                    LEFT JOIN Ndwh.Dbo.Dimfacility Fac
                           ON Fac.Facilitykey = Sms.Facilitykey
             WHERE  COALESCE(Fourweeksmssent, Threeweeksmssent, Twoweeksmssent,
                    Oneweeksmssent,
                            Onedaysmssent) = 'Success'
             GROUP  BY Try_convert(Date, FourWeekSMSSendDateKey) ,
                       Try_convert(Date, ThreeWeekSMSSendDateKey),
                       Try_convert(Date, TwoWeekSMSSendDateKey) ,
                       Try_convert(Date, OneWeekSMSSendDateKey) ,
                       Try_convert(Date, OneDaySMSSendDateKey) ,
                       Mflcode),
         Honouredappointments
         AS (SELECT Asofdate,
                    Count(Patientkey) AS NumberHonouredAppointment,
                    Mflcode
             FROM   Ndwh.Dbo.Factushaurismsreminders Sms
                    LEFT JOIN Ndwh.Dbo.Dimfacility Fac
                           ON Fac.Facilitykey = Sms.Facilitykey
             WHERE  Appointmentstatus = 'honoured'
             GROUP  BY Asofdate,
                       Mflcode),
         Appointmentcounts AS (SELECT Asofdate,
                    Count(Patientkey) AS TotalAppointments,
                    Mflcode
             FROM   Ndwh.Dbo.Factushaurismsreminders Sms
                    LEFT JOIN Ndwh.Dbo.Dimfacility Fac
                           ON Fac.Facilitykey = Sms.Facilitykey
             GROUP  BY Asofdate,
                       Mflcode)
    SELECT Appointmentcounts.Mflcode,
           Appointmentcounts.Asofdate,
           COALESCE(Bookedappointments.Numberbooked, 0)                    AS
           NumberBooked,
           COALESCE(Consentedappointments.Numberconsented, 0)              AS
           NumberConsented,
           COALESCE(Receivedsms.Numberreceivedsms, 0)                      AS
           NumberReceivedSMS,
           COALESCE(Honouredappointments.Numberhonouredappointment, 0)     AS
           NumberHonouredAppointment,
           COALESCE(Cast(Honouredappointments.Numberhonouredappointment AS Float
                    ) /
                             Appointmentcounts.Totalappointments * 100, 0) AS
           PercentHonoured
    INTO   Reporting.Dbo.AggregateUshauriSmsReminders
    FROM   Appointmentcounts
           LEFT JOIN Bookedappointments
                  ON Appointmentcounts.Mflcode = Bookedappointments.Mflcode
                     AND Bookedappointments.Asofdate =
                         Appointmentcounts.Asofdate
           LEFT JOIN Consentedappointments
                  ON Appointmentcounts.Mflcode = Consentedappointments.Mflcode
                     AND Appointmentcounts.Asofdate =
                         Consentedappointments.Asofdate
           LEFT JOIN Receivedsms
                  ON Appointmentcounts.Mflcode = Receivedsms.Mflcode
                     AND Appointmentcounts.Asofdate = Receivedsms.Asofdate
           LEFT JOIN Honouredappointments
                  ON Appointmentcounts.Mflcode = Receivedsms.Mflcode
                     AND Appointmentcounts.Asofdate = Receivedsms.Asofdate
    WHERE  Appointmentcounts.Mflcode > 0
           AND Appointmentcounts.Asofdate IS NOT NULL
END 

