If Object_id(N'[Reporting].[Dbo].[AggregateUshauriAppointments]', N'U') Is Not
   Null
  Drop Table [Reporting].[Dbo].[AggregateUshauriAppointments];

Begin
    With bookedappointments
         As (Select Eomonth(Try_convert(Date, Appointmentdatekey)) As AsofDate,
                    Count(Patientkey)                              As
                    NumberBooked,
                    Patientkey,
                    Facilitykey,
                    Partnerkey,
                    Agencykey,
                    Agegroupkey
             From   ndwh.dbo.Factushaurismsreminders Sms
             Where  Appointmentstatus Is Not Null
             Group  By Eomonth(Try_convert(Date, Appointmentdatekey)),
                       Patientkey,
                       Facilitykey,
                       Partnerkey,
                       Agencykey,
                       Agegroupkey),
         consentedappointments
         As (Select Eomonth(Try_convert(Date, Appointmentdatekey)) As AsofDate,
                    Count(Patientkey)                              As
                    NumberConsented,
                    Facilitykey,
                    Partnerkey,
                    Agencykey,
                    Agegroupkey
             From   ndwh.dbo.Factushaurismsreminders Sms
             Where  Consentforsms = 'YES'
             Group  By Eomonth(Try_convert(Date, Appointmentdatekey)),
                       Facilitykey,
                       Partnerkey,
                       Agencykey,
                       Agegroupkey),
         receivedsms
         As (Select Eomonth(Try_convert(Date, Appointmentdatekey)) As AsofDate,
                    Count(Patientkey)                              As
                    NumberReceivedSMS,
                    Facilitykey,
                    Partnerkey,
                    Agencykey,
                    Agegroupkey
             From   ndwh.dbo.Factushaurismsreminders Sms
             Where  Coalesce(Fourweeksmssent, Threeweeksmssent, Twoweeksmssent,
                    Oneweeksmssent,
                            Onedaysmssent) = 'Success'
             Group  By Eomonth(Try_convert(Date, Appointmentdatekey)),
                       Facilitykey,
                       Partnerkey,
                       Agencykey,
                       Agegroupkey),
         honouredappointments
         As (Select Eomonth(Try_convert(Date, Appointmentdatekey)) As AsofDate,
                    Count(Patientkey)                              As
                       NumberHonouredAppointment,
                    Facilitykey,
                    Partnerkey,
                    Agencykey,
                    Agegroupkey
             From   ndwh.dbo.Factushaurismsreminders Sms
             Where  Appointmentstatus = 'honoured'
             Group  By Eomonth(Try_convert(Date, Appointmentdatekey)),
                       Facilitykey,
                       Partnerkey,
                       Agencykey,
                       Agegroupkey),
         appointmentcounts
         As (Select Eomonth(Try_convert(Date, Appointmentdatekey)) As AsofDate,
                    Count(Patientkey)                              As
                    Totalappointments,
                    Facilitykey,
                    Partnerkey,
                    Agencykey,
                    Agegroupkey
             From   ndwh.dbo.Factushaurismsreminders Sms
             Group  By Eomonth(Try_convert(Date, Appointmentdatekey)),
                       Facilitykey,
                       Partnerkey,
                       Agencykey,
                       Agegroupkey)
    Select Bookedappointments.Asofdate,
           Fac.Mflcode,
           Partner.Partnername,
           Agency.Agencyname,
           Age.Agegroupkey
           As
           AgeGroup,
           Coalesce (Bookedappointments.Numberbooked, 0)
           As
           NumberBooked,
           Coalesce (Consentedappointments.Numberconsented, 0)
           As
           NumberConsented,
           Coalesce (Receivedsms.Numberreceivedsms, 0)
           As
           NumberReceivedSMS,
           Coalesce (Honouredappointments.Numberhonouredappointment, 0)
           As
           NumberHonouredAppointment,
           Coalesce(Cast(Honouredappointments.Numberhonouredappointment As Float
                    ) /
                    Nullif(
                             Appointmentcounts.Totalappointments, 0) * 100, 0)
           As
           PercentHonoured
    Into   reporting.dbo.AggregateUshauriAppointments
    From   bookedappointments
           Left Join ndwh.dbo.Dimfacility Fac
                  On Fac.Facilitykey = Bookedappointments.Facilitykey
           Left Join ndwh.dbo.Dimagency Agency
                  On Agency.Agencykey = Bookedappointments.Agencykey
           Left Join ndwh.dbo.Dimpartner Partner
                  On Partner.Partnerkey = Bookedappointments.Partnerkey
           Left Join ndwh.dbo.Dimagegroup Age
                  On Age.Agegroupkey = Bookedappointments.Agegroupkey
           Left Join consentedappointments
                  On Consentedappointments.Facilitykey =
                     Bookedappointments.Facilitykey
                     And Consentedappointments.Partnerkey =
                         Bookedappointments.Partnerkey
                     And Consentedappointments.Agencykey =
                         Bookedappointments.Agencykey
                     And Consentedappointments.Agegroupkey =
                         Bookedappointments.Agegroupkey
                     And Consentedappointments.Asofdate =
                         Bookedappointments.Asofdate
           Left Join receivedsms
                  On Receivedsms.Facilitykey = Bookedappointments.Facilitykey
                     And Receivedsms.Partnerkey = Bookedappointments.Partnerkey
                     And Receivedsms.Agencykey = Bookedappointments.Agencykey
                     And Receivedsms.Agegroupkey =
                         Bookedappointments.Agegroupkey
                     And Receivedsms.Asofdate = Bookedappointments.Asofdate
           Left Join honouredappointments
                  On Honouredappointments.Facilitykey =
                     Bookedappointments.Facilitykey
                     And Honouredappointments.Partnerkey =
                         Bookedappointments.Partnerkey
                     And Honouredappointments.Agencykey =
                         Bookedappointments.Agencykey
                     And Honouredappointments.Agegroupkey =
                         Bookedappointments.Agegroupkey
                     And Honouredappointments.Asofdate =
                         Bookedappointments.Asofdate
           Left Join appointmentcounts
                  On Appointmentcounts.Facilitykey =
                     Bookedappointments.Facilitykey
                     And Appointmentcounts.Partnerkey =
                         Bookedappointments.Partnerkey
                     And Appointmentcounts.Agencykey =
                         Bookedappointments.Agencykey
                     And Appointmentcounts.Agegroupkey =
                         Bookedappointments.Agegroupkey
                     And Appointmentcounts.Asofdate =
                         Bookedappointments.Asofdate
    Where  Bookedappointments.Asofdate Is Not Null
End 