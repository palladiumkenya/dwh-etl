IF Object_id(N'[REPORTING].[dbo].[AggregatePBFW]', N'U') IS NOT NULL
DROP TABLE [Reporting].[Dbo].[aggregatepbfw];GoSELECT    Facility.Facilityname,
          Facility.Mflcode,
          Facility.County,
          Facility.Subcounty,
          Partner.Partnername,
          Agency.Agencyname,
          Age_group.Datimagegroup AS Agegroup,
          Patient.Gender,
          Sum(Knownpositive) AS Knownpositives,
          Sum(Newpositives)  AS Newpositives,
          Sum (
          CASE
                    WHEN Recieivedart=1 THEN 1
                    ELSE 0
          END ) AS Pbfwonart,
          Sum (
          CASE
                    WHEN Recieivedart=1
                    AND       Eligiblevl=1 THEN 1
                    ELSE 0
          END) AS Pbfweligiblevl,
          Sum (
          CASE
                    WHEN Try_cast (Pbfw_validvlresultcategory As Float ) IS NOT NULL THEN 1
                    ELSE 0
          END) AS Pbfwvalidvl,
          Sum (
          CASE
                    WHEN Pbfw_validvlsup=1 THEN 1
                    ELSE 0
          END) AS Pbfwsuppressed,
          Sum (
          CASE
                    WHEN Pbfw_validvlsup=0 THEN 1
                    ELSE 0
          END ) AS Pbfwunsuppressed,
          Sum (
          CASE
                    WHEN Repeatvls=1 THEN 1
                    ELSE 0
          END) AS Pbfwrepeatvl,
          Sum (
          CASE
                    WHEN Repeatsuppressed=1 THEN 1
                    ELSE 0
          END) AS Pbfwrepeatvlsuppressed,
          Sum (
          CASE
                    WHEN Repeatunsuppressed=1 THEN 1
                    ELSE 0
          END) AS Pbfwrepeatvlunsuppressed,
          Sum (
          CASE
                    WHEN Receivedeac1=1 THEN 1
                    ELSE 0
          END) AS Pbfwreceivedeac1,
          Sum (
          CASE
                    WHEN Receivedeac2=1 THEN 1
                    ELSE 0
          END) AS Pbfwreceivedeac2,
          Sum(
          CASE
                    WHEN Receivedeac3=1 THEN 1
                    ELSE 0
          END) AS Pbfwreceivedeac3,
          Sum (
          CASE
                    WHEN Pbfwreglineswitch=1 THEN 1
                    ELSE 0
          END) AS Pbfwreglineswitch
INTO      Reporting.Dbo.Aggregatepbfw
FROM      Ndwh.Dbo.Factpbfw    AS Pbfw
LEFT JOIN Ndwh.Dbo.Dimfacility AS Facility
ON        Facility.Facilitykey = Pbfw.Facilitykey
LEFT JOIN Ndwh.Dbo.Dimpartner AS Partner
ON        Partner.Partnerkey = Pbfw.Partnerkey
LEFT JOIN Ndwh.Dbo.Dimagency AS Agency
ON        Agency.Agencykey = Pbfw.Agencykey
LEFT JOIN Ndwh.Dbo.Dimagegroup AS Age_group
ON        Age_group.Agegroupkey = Pbfw.Agegroupkey
LEFT JOIN Ndwh.Dbo.Dimpatient AS Patient
ON        Patient.Patientkey = Pbfw.Patientkey
LEFT JOIN Ndwh.Dbo.Factviralloads AS Vls
ON        Vls.Patientkey=Pbfw.Patientkey
GROUP BY  Facility.Facilityname,
          Facility.Mflcode,
          Facility.County,
          Facility.Subcounty,
          Partner.Partnername,
          Agency.Agencyname,
          Age_group.Datimagegroup,
          Patient.Gender;