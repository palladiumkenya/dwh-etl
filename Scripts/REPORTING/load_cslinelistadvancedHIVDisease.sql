If Object_id(N'HIVCaseSurveillance.dbo.CsLinelistAdvanceHIVDisease', N'U') Is
   Not
   Null
  Drop Table Hivcasesurveillance.Dbo.Cslinelistadvancehivdisease;

With Visitdata
     As (Select Facilityname,
                Partnername,
                Agencyname,
                County,
                Subcounty,
                Visits.Patientkey,
                Whostage,
                Gender,
                Try_convert(Date, Visitdatekey)           As VisitDate,
                Eomonth(Try_convert(Date, Visitdatekey))  As AsofDate,
                Datediff(Year, Try_convert(Date, Pat.Dob),
                Try_convert(Date, Eomonth(Visitdatekey))) As Age
         From   Ndwh.Dbo.Facthistoricalvisits As Visits
                Left Join Ndwh.Dbo.Dimpatient As Pat
                       On Pat.Patientkey = Visits.Patientkey
                Left Join Ndwh.Dbo.Dimfacility As Facility
                       On Facility.Facilitykey = Visits.Facilitykey
                Left Join Ndwh.Dbo.Dimpartner As Partner
                       On Partner.Partnerkey = Visits.Partnerkey
                Left Join Ndwh.Dbo.Dimagency As Agency
                       On Agency.Agencykey = Visits.Agencykey
         Where  Visits.Patientkey Is Not Null),
     Rankedvisits
     As (Select Visitdata.Patientkey,
                Facilityname,
                Partnername,
                Agencyname,
                County,
                Subcounty,
                Asofdate,
                Gender,
                Visitdata.Whostage,
                Age,
                Row_number()
                  Over (
                    Partition By Patientkey, Asofdate
                    Order By Asofdate Desc) As VisitRank
         From   Visitdata),
     Latestvisits
     As (Select Patientkey,
                Facilityname,
                Partnername,
                Agencyname,
                County,
                Subcounty,
                Asofdate,
                Whostage,
                Gender,
                Age
         From   Rankedvisits As Latestvisits
         Where  Visitrank = 1),
     Cd4s
     As (Select Patientkey,
                Lastcd4,
                Lastcd4date
         From   Ndwh.Dbo.Factcd4)
Select Visits.Patientkey,
       Asofdate,
       Facilityname,
       Partnername,
       Agencyname,
       County,
       Subcounty,
       Whostage,
       Visits.Gender,
       Eomonth(Dateconfirmed.Date)As CohortYearMonth,
       Visits.Age,
       Age.Datimagegroup,
       Case
         When ( Visits.Age >= 5
                And Visits.Whostage In ( 3, 4 ) )
               Or Visits.Age < 5
               Or ( Visits.Age >= 5
                    And Convert(Float, Cd4s.Lastcd4) < 200 ) Then 1
         Else 0
       End                        As AHD,
       Case
         When Visits.Whostage In ( 3, 4 ) Then 1
         Else 0
       End                        As WhoStage3and4,
       Case
         When Visits.Age >= 5
              And Convert(Float, Cd4s.Lastcd4) < 200 Then 1
         Else 0
       End                        As CD4Lessthan200
Into   Hivcasesurveillance.Dbo.Cslinelistadvancehivdisease
From   Latestvisits As Visits
       Left Join Cd4s
              On Cd4s.Patientkey = Visits.Patientkey
       Left Join Ndwh.Dbo.Dimpatient As Pat
              On Pat.Patientkey = Visits.Patientkey
       Left Join Ndwh.Dbo.Dimdate As Dateconfirmed
              On Dateconfirmed.Datekey = Pat.Dateconfirmedhivpositivekey
       Left Join Ndwh.Dbo.Dimagegroup Age
              On Age.Age = Visits.Age 