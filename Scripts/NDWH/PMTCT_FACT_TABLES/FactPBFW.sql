IF Object_id(N'[NDWH].[dbo].[FactPBFW]', N'U') IS NOT NULL
  DROP TABLE [Ndwh].[Dbo].[Factpbfw];

BEGIN
    WITH Mfl_partner_agency_combination
         AS (SELECT DISTINCT Mfl_code,
                             Sdp,
                             Sdp_agency AS Agency
             FROM   Ods.Dbo.All_emrsites),
         Pbfw_patient_ordering
         AS (SELECT Row_number()
                      OVER (
                        Partition BY Visits.Sitecode, Visits.Patientpk
                        ORDER BY Visits.Visitdate ASC ) AS NUM,
                    Visits.Patientpkhash,
                    Visits.Patientpk,
                    Visits.Sitecode,
                    Patient.Dob,
                    Patient.Gender,
                    Pregnant,
                    Breastfeeding,
                    Visits.Visitdate,
                    Dateconfirmedhivpositive,
                    Startartdate
             FROM   Ods.Dbo.Ct_patient AS Patient
                    INNER JOIN Ods.Dbo.Ct_patientvisits AS Visits
                            ON Visits.Patientpk = Patient.Patientpk
                               AND Visits.Sitecode = Patient.Sitecode
                    LEFT JOIN Ods.Dbo.Ct_artpatients Art
                           ON Patient.Patientpk = Art.Patientpk
                              AND Patient.Sitecode = Art.Sitecode
                    LEFT JOIN Ods.Dbo.Intermediate_latestviralloads Vl
                           ON Patient.Patientpk = Vl.Patientpk
                              AND Patient.Sitecode = Vl.Sitecode
             WHERE  Visits.Pregnant = 'Yes'
                     OR Breastfeeding = 'Yes'
                        AND Visits.Lmp > '1900-01-01'
                        AND Datediff(Year, Patient.Dob, Getdate()) > 10
                        AND Patient.Voided = 0),
         Pbfw_earliestpatient
         AS (SELECT *
             FROM   Pbfw_patient_ordering
             WHERE  Num = 1),
         Anc
         AS (SELECT Row_number()
                      OVER (
                        Partition BY Patientpk, Sitecode
                        ORDER BY Visitdate ASC ) AS NUM,
                    Patientpk,
                    Patientpkhash,
                    Sitecode,
                    Visitdate
             FROM   Ods.Dbo.Mnch_ancvisits
             WHERE  Hivstatusbeforeanc = 'Positive'
                     OR Hivtestfinalresult = 'Positive'),
         Earliestanc
         AS (SELECT *
             FROM   Anc
             WHERE  Num = 1),
         Pnc
         AS (SELECT Row_number()
                      OVER (
                        Partition BY Patientpk, Sitecode
                        ORDER BY Visitdate ASC )AS Num,
                    Patientpk,
                    Patientpkhash,
                    Sitecode,
                    Visitdate
             FROM   Ods.Dbo.Mnch_pncvisits
             WHERE  Priorhivstatus = 'Positive'
                     OR Hivtestfinalresult = 'Positive'
                     OR Babyfeeding IN ( 'Breastfed exclusively',
                                         'Exclusive breastfeeding',
                                         'mixed feeding' )),
         Latestpnc
         AS (SELECT *
             FROM   Pnc
             WHERE  Num = 1),
         Matvisits
         AS (SELECT Row_number()
                      OVER (
                        Partition BY Patientpk, Sitecode
                        ORDER BY Visitdate ASC )AS Num,
                    Patientpk,
                    Patientpkhash,
                    Sitecode,
                    Visitdate
             FROM   Ods.Dbo.Mnch_matvisits
             WHERE  Hivtestfinalresult = 'Positive'
                     OR Onartanc = 'Yes'
                     OR Initiatedbf = 'Yes'),
         Latestmat
         AS (SELECT *
             FROM   Matvisits
             WHERE  Num = 1),
         Pbfw_patient
         AS (SELECT Pbfw_earliestpatient .Patientpkhash,
                    Pbfw_earliestpatient .Patientpk,
                    Pbfw_earliestpatient .Sitecode,
                    Dob,
                    Gender,
                    Pregnant,
                    Breastfeeding,
                    Pbfw_earliestpatient .Visitdate,
                    Dateconfirmedhivpositive,
                    Startartdate
             FROM   Pbfw_earliestpatient
                    FULL JOIN Earliestanc
                           ON Pbfw_earliestpatient .Patientpk =
                              Earliestanc.Patientpk
                              AND Pbfw_earliestpatient .Sitecode =
                                  Earliestanc.Sitecode
                    FULL JOIN Latestpnc
                           ON Latestpnc.Patientpk =
                              Pbfw_earliestpatient.Patientpk
                              AND Latestpnc.Sitecode =
                                  Pbfw_earliestpatient.Sitecode
                    FULL JOIN Latestmat
                           ON Latestmat.Patientpk =
                              Pbfw_earliestpatient.Patientpk
                              AND Pbfw_earliestpatient.Sitecode =
                                  Latestmat.Sitecode
            ),
         Ancdate2
         AS (SELECT Anc.Patientpkhash,
                    Anc.Sitecode,
                    Anc.Patientpk,
                    Anc.Visitdate AS ANCDate2
             FROM   Anc
             WHERE  Num = 2),
         Ancdate3
         AS (SELECT Anc.Patientpkhash,
                    Anc.Sitecode,
                    Anc.Patientpk,
                    Anc.Visitdate AS ANCDate3
             FROM   Anc
             WHERE  Num = 3),
         Ancdate4
         AS (SELECT Anc.Patientpkhash,
                    Anc.Sitecode,
                    Anc.Patientpk,
                    Anc.Visitdate AS ANCDate4
             FROM   Anc
             WHERE  Num = 4),
         Testsatanc
         AS (SELECT Row_number()
                      OVER (
                        Partition BY Tests.Sitecode, Tests.Patientpk
                        ORDER BY Tests.Testdate ASC ) AS NUM,
                    Tests.Patientpkhash,
                    Tests.Sitecode,
                    Tests.Patientpk
             FROM   Ods.Dbo.Hts_clienttests Tests
             WHERE  Entrypoint IN ( 'PMTCT ANC', 'MCH' )),
         Testedatanc
         AS (SELECT Pat.Patientpkhash,
                    Pat.Sitecode,
                    Pat.Patientpk
             FROM   Testsatanc Pat
             WHERE  Num = 1),
         Testsatlandd
         AS (SELECT Row_number()
                      OVER (
                        Partition BY Tests.Sitecode, Tests.Patientpk
                        ORDER BY Tests.Testdate ASC ) AS NUM,
                    Tests.Patientpkhash,
                    Tests.Patientpk,
                    Tests.Sitecode
             FROM   Ods.Dbo.Hts_clienttests Tests
             WHERE  Entrypoint IN ( 'Maternity', 'PMTCT MAT' )),
         Testedatlandd
         AS (SELECT Pat.Patientpkhash,
                    Pat.Sitecode,
                    Pat.Patientpk
             FROM   Testsatlandd AS Pat
             WHERE  Num = 1),
         Testsatpnc
         AS (SELECT Row_number()
                      OVER (
                        Partition BY Tests.Sitecode, Tests.Patientpk
                        ORDER BY Tests.Testdate ASC ) AS NUM,
                    Tests.Patientpkhash,
                    Tests.Patientpk,
                    Tests.Sitecode
             FROM   Ods.Dbo.Hts_clienttests Tests
             WHERE  Entrypoint IN ( 'PMTCT PNC', 'PNC', 'POSTNATAL CARE CLINIC'
                                  )),
         Testedatpnc
         AS (SELECT Pat.Patientpkhash,
                    Pat.Sitecode,
                    Pat.Patientpk
             FROM   Testsatpnc Pat
             WHERE  Num = 1),
         Eac
         AS (SELECT Row_number()
                      OVER (
                        Partition BY Eac.Sitecode, Eac.Patientpk
                        ORDER BY Eac.Visitdate ASC ) AS NUM,
                    Patientpkhash,
                    Sitecode,
                    Patientpk,
                    Visitdate
             FROM   Ods.Dbo.Ct_enhancedadherencecounselling Eac),
         Eac1
         AS (SELECT *
             FROM   Eac
             WHERE  Num = 1),
         Eac2
         AS (SELECT *
             FROM   Eac
             WHERE  Num = 2),
         Eac3
         AS (SELECT *
             FROM   Eac
             WHERE  Num = 3),
         Receivedeac1
         AS (SELECT Eac1.Patientpkhash,
                    Eac1.Sitecode,
                    Eac1.Patientpk
             FROM   Eac1 AS Eac1),
         Receivedeac2
         AS (SELECT Eac2.Patientpkhash,
                    Eac2.Patientpk,
                    Eac2.Sitecode
             FROM   Eac2 AS Eac2),
         Receivedeac3
         AS (SELECT Eac3.Patientpkhash,
                    Eac3.Patientpk,
                    Eac3.Sitecode
             FROM   Eac3 AS Eac3),
         Switches
         AS (SELECT Row_number()
                      OVER (
                        Partition BY Pharm.Sitecode, Pharm.Patientpk
                        ORDER BY Pharm.Dispensedate DESC ) AS NUM,
                    Pharm.Patientpk,
                    Pharm.Sitecode,
                    CASE
                      WHEN Regimenchangedswitched IS NOT NULL THEN 1
                      ELSE 0
                    END                                    AS PBFWRegLineSwitch
             FROM   Ods.Dbo.Ct_patientpharmacy Pharm
             WHERE  Regimenchangedswitched IS NOT NULL),
         Pbfwreglineswitch
         AS (SELECT *
             FROM   Switches
             WHERE  Num = 1),
         Summary
         AS (SELECT Patient.Patientpkhash,
                    Patient.Sitecode,
                    Dob,
                    Gender,
                    Visitdate AS ANCDate1,
                    Ancdate2,
                    Ancdate3,
                    Ancdate4,
                    CASE
                      WHEN Testedatlandd.Patientpkhash IS NOT NULL THEN 1
                      ELSE 0
                    END       AS TestedatLandD,
                    CASE
                      WHEN Testedatanc.Patientpkhash IS NOT NULL THEN 1
                      ELSE 0
                    END       AS TestedatANC,
                    CASE
                      WHEN Testedatpnc.Patientpkhash IS NOT NULL THEN 1
                      ELSE 0
                    END       AS TestedatPNC,
                    CASE
                      WHEN Datediff(Year, Dob, Getdate()) BETWEEN 10 AND 19 THEN
                      1
                      ELSE 0
                    END       AS PositiveAdolescent,
                    CASE
                      WHEN Dateconfirmedhivpositive = Visitdate THEN 1
                      ELSE 0
                    END       AS NewPositives,
                    CASE
                      WHEN Dateconfirmedhivpositive < Visitdate THEN 1
                      ELSE 0
                    END       AS KnownPositive,
                    CASE
                      WHEN Startartdate IS NOT NULL THEN 1
                      ELSE 0
                    END       AS RecieivedART,
                    CASE
                      WHEN Receivedeac1.Patientpk IS NOT NULL THEN 1
                      ELSE 0
                    END       AS ReceivedEAC1,
                    CASE
                      WHEN Receivedeac2.Patientpk IS NOT NULL THEN 1
                      ELSE 0
                    END       AS ReceivedEAC2,
                    CASE
                      WHEN Receivedeac3.Patientpk IS NOT NULL THEN 1
                      ELSE 0
                    END       AS ReceivedEAC3,
                    Pbfwreglineswitch
             FROM   Pbfw_patient AS Patient
                    LEFT JOIN Ancdate2
                           ON Patient.Patientpk = Ancdate2.Patientpk
                              AND Patient.Sitecode = Ancdate2.Sitecode
                    LEFT JOIN Ancdate3
                           ON Patient.Patientpk = Ancdate3.Patientpk
                              AND Patient.Sitecode = Ancdate3.Sitecode
                    LEFT JOIN Ancdate4
                           ON Patient.Patientpk = Ancdate4.Patientpk
                              AND Patient.Sitecode = Ancdate4.Sitecode
                    LEFT JOIN Testedatanc
                           ON Patient.Patientpk = Testedatanc.Patientpk
                              AND Patient.Sitecode = Testedatanc.Sitecode
                    LEFT JOIN Testedatlandd
                           ON Patient.Patientpk = Testedatlandd.Patientpk
                              AND Patient.Sitecode = Testedatlandd.Sitecode
                    LEFT JOIN Testedatpnc
                           ON Patient.Patientpk = Testedatpnc.Patientpk
                              AND Patient.Sitecode = Testedatpnc.Sitecode
                    LEFT JOIN Receivedeac1
                           ON Patient.Patientpk = Receivedeac1.Patientpk
                              AND Patient.Sitecode = Receivedeac1.Sitecode
                    LEFT JOIN Receivedeac2
                           ON Patient.Patientpk = Receivedeac2.Patientpk
                              AND Patient.Sitecode = Receivedeac2.Sitecode
                    LEFT JOIN Receivedeac3
                           ON Patient.Patientpk = Receivedeac3.Patientpk
                              AND Patient.Sitecode = Receivedeac3.Sitecode
                    LEFT JOIN Pbfwreglineswitch
                           ON Patient.Patientpk = Pbfwreglineswitch.Patientpk
                              AND Patient.Sitecode = Pbfwreglineswitch.Sitecode)
    SELECT FactKey = IDENTITY(Int, 1, 1),
           Patient.Patientkey,
           Facility.Facilitykey,
           Partner.Partnerkey,
           Agency.Agencykey,
           Age_group.Agegroupkey,
           Ancdate1,
           Ancdate2,
           Ancdate3,
           Ancdate4,
           Testedatanc,
           Testedatlandd,
           Testedatpnc,
           Positiveadolescent,
           Newpositives,
           Knownpositive,
           Recieivedart,
           Ancdate1.Datekey AS ANCDate1Key,
           Ancdate2.Datekey AS ANCDate2Key,
           Ancdate3.Datekey AS ANCDate3Key,
           Ancdate4.Datekey AS ANCDate4Key,
           Receivedeac1,
           Receivedeac2,
           Receivedeac3,
           Pbfwreglineswitch
    INTO   Ndwh.Dbo.Factpbfw
    FROM   Summary
           LEFT JOIN Ndwh.Dbo.Dimfacility AS Facility
                  ON Facility.Mflcode = Summary.Sitecode
           LEFT JOIN Mfl_partner_agency_combination
                  ON Mfl_partner_agency_combination.Mfl_code = Summary.Sitecode
           LEFT JOIN Ndwh.Dbo.Dimpartner AS Partner
                  ON Partner.Partnername = Mfl_partner_agency_combination.Sdp
           LEFT JOIN Ndwh.Dbo.Dimagency AS Agency
                  ON Agency.Agencyname = Mfl_partner_agency_combination.Agency
           LEFT JOIN Ndwh.Dbo.Dimpatient AS Patient
                  ON Patient.Patientpkhash = Summary.Patientpkhash
                     AND Patient.Sitecode = Summary.Sitecode
           LEFT JOIN Ndwh.Dbo.Dimdate AS Ancdate1
                  ON Ancdate1.Date = Cast(Summary.Ancdate1 AS Date)
           LEFT JOIN Ndwh.Dbo.Dimdate AS Ancdate2
                  ON Ancdate2.Date = Cast(Summary.Ancdate2 AS Date)
           LEFT JOIN Ndwh.Dbo.Dimdate AS Ancdate3
                  ON Ancdate3.Date = Cast(Summary.Ancdate3 AS Date)
           LEFT JOIN Ndwh.Dbo.Dimdate AS Ancdate4
                  ON Ancdate4.Date = Cast(Summary.Ancdate4 AS Date)
           LEFT JOIN Ndwh.Dbo.Dimagegroup AS Age_group
                  ON Age_group.Age = Datediff(Yy, Summary.Dob, Getdate())
    WHERE  Patient.Voided = 0;

    ALTER TABLE Ndwh.Dbo.Factpbfw
      ADD PRIMARY KEY(Factkey);
END 