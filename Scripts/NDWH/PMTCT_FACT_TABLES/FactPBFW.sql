IF Object_id(N'[NDWH].[dbo].[FactPBFW]', N'U') IS NOT NULL
  DROP TABLE [NDWH].[dbo].[FACTPBFW];

BEGIN
    WITH mfl_partner_agency_combination
         AS (SELECT DISTINCT mfl_code,
                             sdp,
                             sdp_agency AS Agency
             FROM   ods.dbo.all_emrsites),
         pbfw_patient
         AS (SELECT Row_number()
                      OVER (
                        partition BY visits.sitecode, visits.patientpkhash
                        ORDER BY visits.visitdate ASC ) AS NUM,
                    visits.patientpkhash,
                    visits.patientpk,
                    visits.sitecode,
                    patient.dob,
                    patient.gender,
                    pregnant,
                    breastfeeding,
                    visits.visitdate,
                    dateconfirmedhivpositive,
                    startartdate,
                    testresult,
                    CASE
                      WHEN Datediff(month, startartdate, Getdate()) >= 3 THEN 1
                      WHEN Datediff(month, startartdate, Getdate()) < 3 THEN 0
                    END                                 AS EligibleVL,
                    CASE
                      WHEN Isnumeric([testresult]) = 1 THEN
                        CASE
                          WHEN Cast(Replace([testresult], ',', '') AS FLOAT) <
                               200.00
                        THEN 1
                          ELSE 0
                        END
                      ELSE
                        CASE
                          WHEN [testresult] IN ( 'undetectable', 'NOT DETECTED',
                                                 '0 copies/ml',
                                                 'LDL',
                               'Less than Low Detectable Level'
                                               ) THEN 1
                          ELSE 0
                        END
                    END                                 AS Suppressed,
                    orderedbydate                       AS ValidVLDate,
                    CASE
                      WHEN Isnumeric(testresult) = 1 THEN
                        CASE
                          WHEN Cast(Replace(testresult, ',', '') AS FLOAT) >=
                               200.00
                        THEN
                          '>200'
                          WHEN Cast(Replace(testresult, ',', '') AS FLOAT)
                               BETWEEN
                               200.00
                               AND 999.00
                        THEN '200-999'
                          WHEN Cast(Replace(testresult, ',', '') AS FLOAT)
                               BETWEEN
                               51.00 AND 199.00
                        THEN
                          '51-199'
                          WHEN Cast(Replace(testresult, ',', '') AS FLOAT) < 50
                        THEN
                          '<50'
                        END
                      ELSE
                        CASE
                          WHEN testresult IN ( 'undetectable', 'NOT DETECTED',
                                               '0 copies/ml'
                                               , 'LDL',
                                               'Less than Low Detectable Level'
                                             )
                        THEN 'Undetectable'
                        END
                    END                                 AS ValidVLResultCategory
             FROM   ods.dbo.ct_patient AS patient
                    INNER JOIN ods.dbo.ct_patientvisits AS visits
                            ON visits.patientpkhash = patient.patientpkhash
                               AND visits.sitecode = patient.sitecode
                    LEFT JOIN ods.dbo.ct_artpatients art
                           ON patient.patientpkhash = art.patientpkhash
                              AND patient.sitecode = art.sitecode
                    LEFT JOIN ods.dbo.intermediate_latestviralloads vl
                           ON patient.patientpkhash = vl.patientpkhash
                              AND patient.sitecode = vl.sitecode
             WHERE  visits.pregnant = 'Yes'
                     OR breastfeeding = 'Yes'
                        AND visits.lmp > '1900-01-01'
                        AND visits.sitecode > 0
                        AND Datediff(year, patient.dob, Getdate()) > 10),
         ancdate2
         AS (SELECT pbfw_patient.patientpkhash,
                    pbfw_patient.sitecode,
                    pbfw_patient.visitdate AS ANCDate2
             FROM   pbfw_patient
             WHERE  num = 2),
         ancdate3
         AS (SELECT pbfw_patient.patientpkhash,
                    pbfw_patient.sitecode,
                    pbfw_patient.visitdate AS ANCDate3
             FROM   pbfw_patient
             WHERE  num = 3),
         ancdate4
         AS (SELECT pbfw_patient.patientpkhash,
                    pbfw_patient.sitecode,
                    pbfw_patient.visitdate AS ANCDate4
             FROM   pbfw_patient
             WHERE  num = 4),
         testsatanc
         AS (SELECT Row_number()
                      OVER (
                        partition BY tests.sitecode, tests.patientpkhash
                        ORDER BY tests.testdate ASC ) AS NUM,
                    tests.patientpkhash,
                    tests.sitecode
             FROM   ods.dbo.hts_clienttests tests
             WHERE  entrypoint IN ( 'PMTCT ANC', 'MCH' )),
         testedatanc
         AS (SELECT pat.patientpkhash,
                    pat.sitecode
             FROM   testsatanc pat
             WHERE  num = 1),
         testsatlandd
         AS (SELECT Row_number()
                      OVER (
                        partition BY tests.sitecode, tests.patientpkhash
                        ORDER BY tests.testdate ASC ) AS NUM,
                    tests.patientpkhash,
                    tests.sitecode          
             FROM   ods.dbo.hts_clienttests tests
             WHERE  entrypoint IN ( 'Maternity', 'PMTCT MAT' )),
         testedatlandd
         AS (SELECT pat.patientpkhash,
                    pat.sitecode
             FROM   testsatlandd AS Pat
             WHERE  num = 1),
 testsatpnc
         AS (SELECT Row_number()
                      OVER (
                        partition BY tests.sitecode, tests.patientpkhash
                        ORDER BY tests.testdate ASC ) AS NUM,
                    tests.patientpkhash,
                    tests.sitecode
             FROM   ods.dbo.hts_clienttests tests
             WHERE  entrypoint IN ( 'PMTCT PNC', 'PNC' ,'POSTNATAL CARE CLINIC')
         ),
         testedatpnc
         AS (SELECT pat.patientpkhash,
                    pat.sitecode
             FROM   testsatpnc pat
             WHERE  num = 1),


         summary
         AS (SELECT patient.patientpkhash,
                    patient.sitecode,
                    dob,
                    gender,
                    visitdate                   AS ANCDate1,
                    ancdate2,
                    ancdate3,
                    ancdate4,
                     case when testedatlandd.patientpkhash is not null then 1 else 0 end as TestedatLandD,
                    case when testedatanc.patientpkhash is not null then 1 else 0 end as TestedatANC,
                     case when testedatpnc.patientpkhash is not null then 1 else 0 end as TestedatPNC,
                    CASE
                      WHEN Datediff(year, dob, Getdate()) BETWEEN 10 AND 19 THEN
                      1
                      ELSE 0
                    END                         AS PositiveAdolescent,
                    CASE
                      WHEN dateconfirmedhivpositive = visitdate THEN 1
                      ELSE 0
                    END                         AS NewPositives,
                    CASE
                      WHEN dateconfirmedhivpositive < visitdate THEN 1
                      ELSE 0
                    END                         AS KnownPositive,
                    CASE
                      WHEN startartdate IS NOT NULL THEN 1
                      ELSE 0
                    END                         AS RecieivedART,
                    COALESCE (eligiblevl, 0)    AS EligibleVL,
                    suppressed,
                    CASE
                    When 
                     Try_Cast(Replace(validvlresultcategory, ',', '') AS FLOAT)  >= 200.00 THEN 1
                      ELSE 0
                    END                         AS Unsuppressed,
                    validvlresultcategory
             FROM   pbfw_patient AS Patient
                    LEFT JOIN ancdate2
                           ON Patient.patientpkhash = ancdate2.patientpkhash
                              AND Patient.sitecode = ancdate2.sitecode
                    LEFT JOIN ancdate3
                           ON Patient.patientpkhash = ancdate3.patientpkhash
                              AND Patient.sitecode = ancdate3.sitecode
                    LEFT JOIN ancdate4
                           ON Patient.patientpkhash = ancdate4.patientpkhash
                              AND Patient.sitecode = ancdate4.sitecode
                    LEFT JOIN testedatanc
                           ON Patient.patientpkhash = testedatanc.patientpkhash
                              AND Patient.sitecode = testedatanc.sitecode
                    LEFT JOIN testedatlandd
                           ON Patient.patientpkhash =
                              testedatlandd.patientpkhash
                              AND Patient.sitecode = testedatlandd.sitecode
                    LEFT JOIN testedatpnc
                           ON Patient.patientpkhash =
                              testedatpnc.patientpkhash
                              AND Patient.sitecode = testedatpnc.sitecode
             WHERE  Patient.num = 1)
    SELECT FactKey = IDENTITY(int, 1, 1),
           Patient.patientkey,
           Facility.facilitykey,
           Partner.partnerkey,
           Agency.agencykey,
           age_group.AgeGroupKey,
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
           Eligiblevl,
           Suppressed,
           Unsuppressed,
           Validvlresultcategory,
           ANCDate1.datekey AS ANCDate1Key,
           ANCDate2.datekey AS ANCDate2Key,
           ANCDate3.datekey AS ANCDate3Key,
           ANCDate4.datekey AS ANCDate4Key
    INTO   ndwh.dbo.factpbfw
    FROM   summary
           LEFT JOIN ndwh.dbo.dimfacility AS Facility
                  ON Facility.mflcode = summary.sitecode
           LEFT JOIN mfl_partner_agency_combination
                  ON mfl_partner_agency_combination.mfl_code = summary.sitecode
           LEFT JOIN ndwh.dbo.dimpartner AS Partner
                  ON Partner.partnername = mfl_partner_agency_combination.sdp
           LEFT JOIN ndwh.dbo.dimagency AS Agency
                  ON Agency.agencyname = mfl_partner_agency_combination.agency
           LEFT JOIN ndwh.dbo.dimpatient AS Patient
                  ON Patient.patientpkhash = summary.patientpkhash
                     AND Patient.sitecode = summary.sitecode
           LEFT JOIN ndwh.dbo.dimdate AS ANCDate1
                  ON ANCDate1.date = Cast(summary.ancdate1 AS DATE)
           LEFT JOIN ndwh.dbo.dimdate AS ANCDate2
                  ON ANCDate2.date = Cast(summary.ancdate2 AS DATE)
           LEFT JOIN ndwh.dbo.dimdate AS ANCDate3
                  ON ANCDate3.date = Cast(summary.ancdate3 AS DATE)
           LEFT JOIN ndwh.dbo.dimdate AS ANCDate4
                  ON ANCDate4.date = Cast(summary.ancdate4 AS DATE)
            Left join NDWH.dbo.DimAgeGroup as age_group on age_group.Age =  datediff(yy, summary.DOB,  getdate())


    ALTER TABLE ndwh.dbo.factpbfw
      ADD PRIMARY KEY(factkey);
END     