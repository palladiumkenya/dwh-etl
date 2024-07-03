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
                EOMONTH (Dateconfirmed.Date)
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
                Cast(Max(Orderedbydate) As Date) As last_viral_load_date,

				 CASE 
            WHEN Max(Orderedbydate) IS not  NULL THEN 1 
            ELSE 0 
        END AS Invalid_viral_load_within_12_months

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
                           And   Datediff(Month, Startartdate.Datekey, Getdate
                                   ())
                                   >= 3
                                  
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

HadVLDone AS (
    SELECT 
	      Visits.Patientkey,
                Mflcode,
                Visitdate,
                Asofdate,
				DateConfirmedPositive As CohortYearMonth,
                visits.Gender,
                Agegroup,
                County,
                Subcounty,
                Partner,
                Agency,
        Max(Ordereddate.Date) AS OrderedByDate,
        CASE 
            WHEN Max(Ordereddate.Date) IS NOT NULL THEN 1 
            ELSE 0 
        END AS HadViralLoadDone
		
    
    FROM 
         Recentdata AS visits
	Inner Join Ndwh.Dbo.Factart As Art
                        On Art.Patientkey = visits.Patientkey
	Left Join Ndwh.Dbo.Dimdate As Startartdate
                       On Startartdate.Datekey = visits.StartARTDate

	Inner Join Ndwh.Dbo.Dimpatient As Pat
                        On Pat.Patientpkhash = visits.Patientpkhash
                           And Pat.Sitecode = visits.Mflcode
    LEFT JOIN 
        Ndwh.Dbo.Factvllasttwoyears AS vls ON visits.patientkey = vls.patientkey 
		 And Visits.Orderedbydate  Between
                               Dateadd(Month, -12, Visits.Visitdate) And
                               Visits.Visitdate
                           And  Datediff(Month, Startartdate.Datekey, Getdate
                                   ())
                                   >= 3
                                   

    LEFT JOIN 
        NDWH.dbo.DimDate AS OrderedDate ON OrderedDate.Date = vls.OrderedByDateKey
    LEFT JOIN 
        NDWH.dbo.DimDate AS VisitDate ON VisitDate.Date = visits.VisitDate
		Group by
		 Visits.Patientkey,
                Mflcode,
                Visitdate,
                Asofdate,
				DateConfirmedPositive,
                visits.Gender,
                Agegroup,
                County,
                Subcounty,
                Partner,
                Agency
),
 DueAndDoneVL AS (
    SELECT 
        visits.Patientkey,
        visits.Mflcode,
        visits.Visitdate,
        visits.Asofdate,
        visits.DateConfirmedPositive AS CohortYearMonth,
        visits.Gender,
        visits.Agegroup,
        visits.County,
        visits.Subcounty,
        visits.Partner,
        visits.Agency,
        MAX(OrderedDate.Date) AS OrderedByDate,
        CASE 
            WHEN MAX(OrderedDate.Date) IS NOT NULL THEN 1 
            ELSE 0 
        END AS HadViralLoadDone
    FROM 
        Recentdata AS visits
    INNER JOIN 
        Ndwh.Dbo.Factart AS Art ON Art.Patientkey = visits.Patientkey
    LEFT JOIN 
        Ndwh.Dbo.Dimdate AS Startartdate ON Startartdate.Datekey = visits.StartARTDate
    LEFT JOIN 
        Ndwh.Dbo.Factvllasttwoyears AS vls ON visits.Patientkey = vls.Patientkey 
            AND visits.Visitdate BETWEEN DATEADD(MONTH, -12, Visits.Visitdate) AND Visits.Visitdate
            AND DATEDIFF(MONTH, Startartdate.Datekey, GETDATE()) >= 3
    LEFT JOIN 
        NDWH.dbo.DimDate AS OrderedDate ON OrderedDate.Date = vls.OrderedByDateKey
    GROUP BY
        visits.Patientkey,
        visits.Mflcode,
        visits.Visitdate,
        visits.Asofdate,
        visits.DateConfirmedPositive,
        visits.Gender,
        visits.Agegroup,
        visits.County,
        visits.Subcounty,
        visits.Partner,
        visits.Agency
)
 
Select
       HadVLDone.Patientkey,
       HadVLDone.MFLCode,
       HadVLDone.Gender,
       HadVLDone.AgeGroup,
       HadVLDone.County,
       HadVLDone.SubCounty,
       HadVLDone.Partner,
       HadVLDone.Agency,
       HadVLDone.Asofdate,
	   HadVLDone.CohortYearMonth,
       Invalidity.Last_viral_load_date,
	   HadVLDone.HadViralLoadDone ,
	   DueAndDoneVL.HadViralLoadDone as DueAndVLDone,
	   Invalid_viral_load_within_12_months as DueAndVLNotDone
Into   HIVCaseSurveillance.Dbo.CsLinelistMissedOpportunitiesVlGap
From  HadVLDone  as HadVLDone
left  join  Invalidity_for_vl As Invalidity  on HadVLDone.Patientkey= Invalidity.PatientKey and hadvldone.VisitDate=invalidity.VisitDate
left join DueAndDoneVL on DueAndDoneVL.PatientKey=HadVLDone.PatientKey and DueAndDoneVL.visitdate=HadVLDone.visitdate
 