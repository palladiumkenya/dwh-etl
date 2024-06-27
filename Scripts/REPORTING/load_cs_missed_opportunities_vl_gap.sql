If Object_id(N'[HIVCaseSurveillance].[dbo].[CsLinelistMissedOpportunitiesVLGap]', N'U') Is Not Null
  Drop Table [Hivcasesurveillance].[Dbo].[Cslinelistmissedopportunitiesvlgap];

With Mfl_partner_agency_combination
     As (Select Distinct Mfl_code,
                         Sdp,
                         Sdp_agency As Agency
         From   Ods.Dbo.All_emrsites),
     Recentdata
     As (Select Visits.Patientkey,
                Pat.Patientpkhash,
                Fac.Mflcode,
                Visits.Facilitykey,
                Cast (Visits.Visitdatekey As Date)
                As
                   VisitDate,
                Eomonth (Cast (Visits.Visitdatekey As Date))
                As
                   AsOfDate,
                Cast (Visits.Nextappointmentdatekey As Date)
                As
                   NextAppointmentDate,
                Cast (Visits.Startartdatekey As Date)
                As
                   StartARTDate,
                Datediff(Year, Pat.Dob, ( Cast (Visits.Visitdatekey As Date) ))
                As
                   AgeLastVisit,
                Dateconfirmed.Date
                As
                   DateConfirmedPositive,
                Orderedbydate.Datekey
                As
                   OrderedbyDate,
                Gender,
                Agegroup.Mohagegroup
                As
                   AgeGroup,
                Fac.County,
                Fac.Subcounty,
                Partnername
                As
                   Partner,
                Agencyname
                As
                   Agency
         From   Ndwh.Dbo.Factvisits As Visits
                Left Join Ndwh.Dbo.Factvllasttwoyears As Vl
                       On Visits.Patientkey = Vl.Patientkey
                Inner Join Ndwh.Dbo.Dimpatient As Pat
                        On Pat.Patientkey = Visits.Patientkey
                Left Join Ndwh.Dbo.Dimdate Dateconfirmed
                       On Dateconfirmed.Datekey =
                          Pat.Dateconfirmedhivpositivekey
                Left Join Ndwh.Dbo.Dimdate Orderedbydate
                       On Orderedbydate.Datekey = Vl.Orderedbydatekey
                Left Join Ndwh.Dbo.Dimfacility As Fac
                       On Fac.Facilitykey = Visits.Facilitykey
                Left Join Mfl_partner_agency_combination
                       On Mfl_partner_agency_combination.Mfl_code = Fac.Mflcode
                Left Join Ndwh.Dbo.Dimpartner As Partner
                       On Partner.Partnername =
Mfl_partner_agency_combination.Sdp
                Left Join Ndwh.Dbo.Dimagency As Agency
                       On Agency.Agencyname =
Mfl_partner_agency_combination.Agency
                Left Join Ndwh.Dbo.Dimagegroup As Agegroup
                       On Agegroup.Agegroupkey = Datediff(Year, Pat.Dob, ( Cast
                                                 (
                                                 Visits.Visitdatekey As Date) ))
         Where  Cast(Visits.Visitdatekey As Date) >= Eomonth(
                Dateadd(Month, -12, Getdate()))),
     Validity_for_vl
     As (Select Pat.Patientkey,
                Mflcode,
                Visitdate,
                Asofdate,
                Recent.Gender,
                Agegroup,
                County,
                Subcounty,
                Partner,
                Agency,
                Cast(Max(Orderedbydate) As Date) As last_viral_load_date
         From   Recentdata As Recent
                Inner Join Ndwh.Dbo.Factart As Art
                        On Art.Patientkey = Recent.Patientkey
                Left Join Ndwh.Dbo.Dimdate As Startartdate
                       On Startartdate.Datekey = Art.Startartdatekey
                Inner Join Ndwh.Dbo.Dimpatient As Pat
                        On Pat.Patientpkhash = Recent.Patientpkhash
                           And Pat.Sitecode = Recent.Mflcode
                Inner Join Ndwh.Dbo.Factvllasttwoyears As Vls
                        On Vls.Patientkey = Recent.Patientkey
                           And Recent.Orderedbydate Not Between
                               Dateadd(Month, -12, Recent.Visitdate) And
                               Recent.Visitdate
                           And Recent.Orderedbydate Not Between
                               Dateadd(Month, -12, Recent.Visitdate) And
                               Recent.Visitdate
                           And ( ( Datediff(Month, Startartdate.Datekey, Getdate
                                   ())
                                   >= 3
                                   And Recent.Agelastvisit >= 25
                                   And Datediff(Month, Recent.Orderedbydate,
                                       Recent.Visitdate) >
                                       12 )
                                  Or ( Datediff(Month, Startartdate.Datekey,
                                       Getdate(
                                       ))
                                       >= 3
                                       And Recent.Agelastvisit < 25
                                       And Datediff(Month, Recent.Orderedbydate,
                                           Recent.Visitdate) > 6 ) )
         Group  By Pat.Patientkey,
                   Mflcode,
                   Visitdate,
                   Asofdate,
                   Recent.Gender,
                   Agegroup,
                   County,
                   Subcounty,
                   Partner,
                   Agency)
Select Validity.Patientkey,
       Mflcode,
       Gender,
       Agegroup,
       County,
       Subcounty,
       Partner,
       Agency,
       Validity.Asofdate,
       Validity.Last_viral_load_date,
       Case
         When Validity.Last_viral_load_date Is Not Null Then 1
         Else 0
       End As Invalid_viral_load_within_12_months
Into   Hivcasesurveillance.Dbo.Cslinelistmissedopportunitiesvlgap
From   Validity_for_vl As Validity
Order  By Validity.Patientkey,
          Validity.Asofdate 