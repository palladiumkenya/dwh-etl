IF OBJECT_ID(N'[HIVCaseSurveillance].[dbo].[CsLinelistMissedOpportunitiesVLGap]', N'U') IS NOT NULL
    DROP TABLE [HIVCaseSurveillance].[dbo].[CsLinelistMissedOpportunitiesVLGap];

WITH Recentdata AS (
    SELECT 
        Visits.Patientkey,
        Pat.Patientpkhash,
        Fac.Mflcode,
        Visits.Facilitykey,
        CAST(Visits.Visitdatekey AS DATE) AS VisitDate,
        EOMONTH(CAST(Visits.Visitdatekey AS DATE)) AS AsOfDate,
        CAST(Visits.Nextappointmentdatekey AS DATE) AS NextAppointmentDate,
        CAST(Visits.Startartdatekey AS DATE) AS StartARTDate,
        DATEDIFF(YEAR, Pat.Dob, CAST(Visits.Visitdatekey AS DATE)) AS AgeLastVisit,
        EOMONTH(Dateconfirmed.Date) AS DateConfirmedPositive,
        Orderedbydate.Datekey AS OrderedbyDate,
        cast (Vl.TestResult as float) as TestResult ,
		case 
			when isnumeric(Vl.TestResult) = 1 then 
				case 
					when cast(replace([TestResult], ',', '') as  float) > 200.00 then 1 
					else 0 
				end 
				End as IsUnsuppressed,
        Gender,
        Agegroup.Mohagegroup AS AgeGroup,
        Fac.County,
        Fac.Subcounty,
        Partnername AS Partner,
        Agencyname AS Agency
    FROM 
        Ndwh.Dbo.Factvisits AS Visits
    LEFT JOIN 
        Ndwh.Dbo.Factvllasttwoyears AS Vl ON Visits.Patientkey = Vl.Patientkey AND CAST(OrderedbyDateKey AS DATE) >= EOMONTH(DATEADD(MONTH, -12, GETDATE()))
    INNER JOIN 
        Ndwh.Dbo.Dimpatient AS Pat ON Pat.Patientkey = Visits.Patientkey
    LEFT JOIN 
        Ndwh.Dbo.Dimdate AS Dateconfirmed ON Dateconfirmed.Datekey = Pat.Dateconfirmedhivpositivekey
    LEFT JOIN 
        Ndwh.Dbo.Dimdate AS Orderedbydate ON Orderedbydate.Datekey = Vl.Orderedbydatekey
    LEFT JOIN 
        Ndwh.Dbo.Dimfacility AS Fac ON Fac.Facilitykey = Visits.Facilitykey
    LEFT JOIN 
        Ndwh.Dbo.Dimpartner AS Partner ON Partner.PartnerKey = Visits.PartnerKey
    LEFT JOIN 
        Ndwh.Dbo.Dimagency AS Agency ON Agency.AgencyKey = Visits.AgencyKey
    LEFT JOIN 
        Ndwh.Dbo.Dimagegroup AS Agegroup ON Agegroup.Agegroupkey = DATEDIFF(YEAR, Pat.Dob, CAST(Visits.Visitdatekey AS DATE))
    WHERE 
        CAST(Visits.Visitdatekey AS DATE) >= EOMONTH(DATEADD(MONTH, -12, GETDATE()))
),

Invalidity_for_vl AS (
    SELECT 
        Pat.Patientkey,
        Recent.Mflcode,
        Recent.Visitdate,
        Recent.Asofdate,
        Recent.Gender,
        Recent.Agegroup,
        Recent.County,
        Recent.Subcounty,
        Recent.Partner,
        Recent.Agency,
		-- Calculates whether a viral load measurement is invalid within the last 12 months
        CAST(MAX(Orderedbydate.Date) AS DATE) AS last_viral_load_date,
        CASE 
            WHEN MAX(Orderedbydate.Date) IS NULL OR 
                 MAX(Orderedbydate.Date) < DATEADD(MONTH, -12, GETDATE())
                THEN 1 
            ELSE 0 
        END AS Invalid_viral_load_within_12_months
    FROM 
        Recentdata AS Recent
    LEFT JOIN 
        Ndwh.Dbo.Factart AS Art ON Art.Patientkey = Recent.Patientkey
    LEFT JOIN 
        Ndwh.Dbo.Dimdate AS Startartdate ON Startartdate.Datekey = Art.Startartdatekey
    INNER JOIN 
        Ndwh.Dbo.Dimpatient AS Pat ON Pat.Patientpkhash = Recent.Patientpkhash AND Pat.Sitecode = Recent.Mflcode
    LEFT JOIN 
        Ndwh.Dbo.Dimdate AS Orderedbydate ON Orderedbydate.Datekey = recent.Orderedbydate
    GROUP BY 
        Pat.Patientkey,
        Recent.Mflcode,
        Recent.Visitdate,
        Recent.Asofdate,
        Recent.Gender,
        Recent.Agegroup,
        Recent.County,
        Recent.Subcounty,
        Recent.Partner,
        Recent.Agency
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
		-- Determines whether a viral load was performed within the last 12 months
        MAX(OrderedDate.Date) AS OrderedByDate,
        CASE 
            WHEN MAX(OrderedDate.Date) IS NOT NULL AND 
                 MAX(OrderedDate.Date) >= DATEADD(MONTH, -12, GETDATE())
                THEN 1 
            ELSE 0 
        END AS HadViralLoadDone
    FROM 
        Recentdata AS visits
    LEFT JOIN 
        Ndwh.Dbo.Factart AS Art ON Art.Patientkey = visits.Patientkey
    LEFT JOIN 
        Ndwh.Dbo.Dimdate AS Startartdate ON Startartdate.Datekey = visits.StartARTDate
    LEFT JOIN 
        Ndwh.Dbo.Factvllasttwoyears AS vls ON visits.Patientkey = vls.Patientkey
    LEFT JOIN 
        NDWH.Dbo.Dimdate AS OrderedDate ON OrderedDate.Datekey = vls.Orderedbydatekey
    WHERE 
        OrderedDate.Date IS NOT NULL AND 
        visits.Visitdate BETWEEN DATEADD(MONTH, -12, visits.Visitdate) AND visits.Visitdate
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

SELECT
    HadVLDone.Patientkey,
    HadVLDone.MFLCode,
    HadVLDone.Gender,
    HadVLDone.AgeGroup,
    HadVLDone.County,
    HadVLDone.SubCounty,
    HadVLDone.Partner,
    HadVLDone.Agency,
    HadVLDone.Asofdate,
    HadVLDone.DateConfirmedPositive AS CohortYearMonth,
    Invalidity.Last_viral_load_date,
    DueAndDoneVL.HadViralLoadDone AS DueAndVLDone,
    Invalidity.Invalid_viral_load_within_12_months AS DueAndVLNotDone,
    HadVLDone.IsUnsuppressed
INTO HIVCaseSurveillance.Dbo.CsLinelistMissedOpportunitiesVlGap
FROM Recentdata AS HadVLDone
LEFT JOIN Invalidity_for_vl AS Invalidity ON HadVLDone.Patientkey = Invalidity.Patientkey AND HadVLDone.VisitDate = Invalidity.VisitDate
LEFT JOIN DueAndDoneVL ON DueAndDoneVL.PatientKey = HadVLDone.PatientKey AND DueAndDoneVL.Visitdate = HadVLDone.Visitdate;