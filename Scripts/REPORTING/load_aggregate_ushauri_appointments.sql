If Object_id(N'[Reporting].[Dbo].[AggregateUshauriAppointments]', N'U') Is Not Null
  Drop Table [Reporting].[Dbo].[AggregateUshauriAppointments];

Begin
    With bookedappointments
         As (Select Eomonth(Try_convert(Date, Appointmentdatekey)) As AsofDate,
                    Count(Patientkey)                              As
                    NumberBooked,
                    Facilitykey,
                    Partnerkey,
                    Agencykey,
                    Agegroupkey
             From   ndwh.dbo.FactUshauriAppointments Sms
             Where  Appointmentstatus Is Not Null
             Group  By Eomonth(Try_convert(Date, Appointmentdatekey)),
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
             From   ndwh.dbo.FactUshauriAppointments Sms
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
             From   ndwh.dbo.FactUshauriAppointments Sms
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
             From   ndwh.dbo.FactUshauriAppointments Sms
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
             From   ndwh.dbo.FactUshauriAppointments Sms
             Group  By Eomonth(Try_convert(Date, Appointmentdatekey)),
                       Facilitykey,
                       Partnerkey,
                       Agencykey,
                       Agegroupkey),
       missingappointments
         As (Select Eomonth(Try_convert(Date, Appointmentdatekey)) As AsofDate,
                    Count(Patientkey)                              As
                    NumberMissedAppointment,
                    Patientkey,
                    Facilitykey,
                    Partnerkey,
                    Agencykey,
                    Agegroupkey
             From   ndwh.dbo.FactUshauriAppointments Sms
             Where  Appointmentstatus ='not honoured'
             Group  By Eomonth(Try_convert(Date, Appointmentdatekey)),
                       Patientkey,
                       Facilitykey,
                       Partnerkey,
                       Agencykey,
                       Agegroupkey),

         Traced
         As (Select Eomonth(Try_convert(Date, Appointmentdatekey)) As AsofDate,
                    Count(Patientkey)                              As
                    NumberTraced,
                    Patientkey,
                    Facilitykey,
                    Partnerkey,
                    Agencykey,
                    Agegroupkey
             From   ndwh.dbo.FactUshauriAppointments Sms
             Where  (Tracingcalls = 1 OR TracingSMS = 1 OR TracingHomevisits = 1)
             Group  By Eomonth(Try_convert(Date, Appointmentdatekey)),
                       Patientkey,
                       Facilitykey,
                       Partnerkey,
                       Agencykey,
                       Agegroupkey),

              SuccessfullyTraced
         As (Select Eomonth(Try_convert(Date, Appointmentdatekey)) As AsofDate,
                    Count(Patientkey)                              As
                    NumberSuccessfullyTraced,
                    Patientkey,
                    Facilitykey,
                    Partnerkey,
                    Agencykey,
                    Agegroupkey
             From   ndwh.dbo.FactUshauriAppointments Sms
             Where Tracingoutcome is not null and Tracingoutcome <> 'Client not found '
             Group  By Eomonth(Try_convert(Date, Appointmentdatekey)),
                       Patientkey,
                       Facilitykey,
                       Partnerkey,
                       Agencykey,
                       Agegroupkey)  ,
              HomeVisits
         As (Select Eomonth(Try_convert(Date, Appointmentdatekey)) As AsofDate,
                    Count(Patientkey)                              As
                    NumberOfHomeVisits,
                    Patientkey,
                    Facilitykey,
                    Partnerkey,
                    Agencykey,
                    Agegroupkey
             From   ndwh.dbo.FactUshauriAppointments Sms
             Where Tracinghomevisits=1
             Group  By Eomonth(Try_convert(Date, Appointmentdatekey)),
                       Patientkey,
                       Facilitykey,
                       Partnerkey,
                       Agencykey,
                       Agegroupkey),
        ReturnedToCare
         As (Select Eomonth(Try_convert(Date, Appointmentdatekey)) As AsofDate,
                    Count(Patientkey)                              As
                    NumberReturnedToCare,
                    Patientkey,
                    Facilitykey,
                    Partnerkey,
                    Agencykey,
                    Agegroupkey
             From   ndwh.dbo.FactUshauriAppointments Sms
             Where Tracingoutcome='Client returned to care '
             Group  By Eomonth(Try_convert(Date, Appointmentdatekey)),
                       Patientkey,
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
           PercentHonoured,
           Coalesce (missingappointments.NumberMissedAppointment,0) As NumberMissedAppointment,
           Coalesce (Traced.NumberTraced,0) As NumberTraced,
           Coalesce (SuccessfullyTraced.NumberSuccessfullyTraced,0) As NumberSuccessfullyTraced,
           Coalesce (HomeVisits.NumberOfHomeVisits,0) As NumberOfHomeVisits,
           Coalesce (ReturnedToCare.NumberReturnedToCare,0) As NumberReturnedToCare
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
          Left Join missingappointments
                  On missingappointments.Facilitykey =
                     Bookedappointments.Facilitykey
                     And missingappointments.Partnerkey =
                         Bookedappointments.Partnerkey
                     And missingappointments.Agencykey =
                         Bookedappointments.Agencykey
                     And missingappointments.Agegroupkey =
                         Bookedappointments.Agegroupkey
                     And missingappointments.Asofdate =
                         Bookedappointments.Asofdate 
        Left Join Traced
                  On Traced.Facilitykey =
                     Bookedappointments.Facilitykey
                     And Traced.Partnerkey =
                         Bookedappointments.Partnerkey
                     And Traced.Agencykey =
                         Bookedappointments.Agencykey
                     And Traced.Agegroupkey =
                         Bookedappointments.Agegroupkey
                     And Traced.Asofdate =
                         Bookedappointments.Asofdate
        Left Join SuccessfullyTraced
                  On SuccessfullyTraced.Facilitykey =
                     Bookedappointments.Facilitykey
                     And SuccessfullyTraced.Partnerkey =
                         Bookedappointments.Partnerkey
                     And SuccessfullyTraced.Agencykey =
                         Bookedappointments.Agencykey
                     And SuccessfullyTraced.Agegroupkey =
                         Bookedappointments.Agegroupkey
                     And SuccessfullyTraced.Asofdate =
                         Bookedappointments.Asofdate
         Left Join HomeVisits
                  On HomeVisits.Facilitykey =
                     Bookedappointments.Facilitykey
                     And HomeVisits.Partnerkey =
                         Bookedappointments.Partnerkey
                     And HomeVisits.Agencykey =
                         Bookedappointments.Agencykey
                     And HomeVisits.Agegroupkey =
                         Bookedappointments.Agegroupkey
                     And HomeVisits.Asofdate =
                         Bookedappointments.Asofdate
        Left Join ReturnedToCare
                  On ReturnedToCare.Facilitykey =
                     Bookedappointments.Facilitykey
                     And ReturnedToCare.Partnerkey =
                         Bookedappointments.Partnerkey
                     And ReturnedToCare.Agencykey =
                         Bookedappointments.Agencykey
                     And ReturnedToCare.Agegroupkey =
                         Bookedappointments.Agegroupkey
                     And ReturnedToCare.Asofdate =
                         Bookedappointments.Asofdate
    Where  Bookedappointments.Asofdate Is Not Null
End
