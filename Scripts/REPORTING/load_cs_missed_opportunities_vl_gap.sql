If Object_id(N'[HIVCaseSurveillance].[dbo].[CsLinelistMissedOpportunitiesVLGap]', N'U') Is Not Null
  Drop Table [Hivcasesurveillance].[Dbo].[Cslinelistmissedopportunitiesvlgap];

With Recentdata
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
                              Left Join Ndwh.Dbo.Dimpartner As Partner
                       On Partner.PartnerKey =
Visits.PartnerKey
                Left Join Ndwh.Dbo.Dimagency As Agency
                       On Agency.AgencyKey =
Visits.AgencyKey
                Left Join Ndwh.Dbo.Dimagegroup As Agegroup
                       On Agegroup.Agegroupkey = Datediff(Year, Pat.Dob, ( Cast
                                                 (
                                                 Visits.Visitdatekey As Date) ))
         Where  Cast(Visits.Visitdatekey As Date) >= Eomonth(
                Dateadd(Month, -12, Getdate()))),
     Invalidity_for_vl
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
                   Agency),

 HadVLDone AS (SELECT 
     Visits.patientkey,
     VisitDate.date as VisitDate,
	 Eomonth (VisitDate.date) As AsOfDate,
     OrderedDate.Date as OrderedByDate,
     Case when  OrderedDate.Date is not null then 1 Else 0 End as HadViralLoadDone,
	 vls.TestResult
   
FROM 
    Ndwh.Dbo.Factvisits as  visits

LEFT JOIN 
     Ndwh.Dbo.Factvllasttwoyears as  vls ON  visits.patientkey = vls.patientkey 
	 	Left join NDWH.dbo.DimDate as OrderedDate on OrderedDate.Date=vls.OrderedByDateKey 
		Left join NDWH.dbo.DimDate as VisitDate on VisitDate.Date=visits.VisitDateKey
	where  EOMONTH (VisitDate.date)  = EOMONTH (OrderedDate.Date)
)
Select
       Invalidity.Patientkey,
       Mflcode,
       Gender,
       Agegroup,
       County,
       Subcounty,
       Partner,
       Agency,
       Invalidity.Asofdate,
       Invalidity.Last_viral_load_date,
       Case
         When Invalidity.Last_viral_load_date Is Not Null Then 1
         Else 0
       End As Invalid_viral_load_within_12_months,
	   coalesce (HadViralLoadDone,0) as HadViralLoadDone
Into   Hivcasesurveillance.Dbo.Cslinelistmissedopportunitiesvlgap
From   Invalidity_for_vl As Invalidity
left join HadVLDone on HadVLDone.Patientkey= Invalidity.PatientKey-- and Invalidity.AsOfDate= HadVLDone.AsOfDate

