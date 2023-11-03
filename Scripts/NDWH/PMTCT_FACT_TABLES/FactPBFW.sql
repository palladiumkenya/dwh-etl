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
                        partition BY visits.sitecode, visits.patientpk
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
                    startartdate                  

             FROM   ods.dbo.ct_patient AS patient
                    INNER JOIN ods.dbo.ct_patientvisits AS visits
                            ON visits.patientpk = patient.patientpk
                               AND visits.sitecode = patient.sitecode
                    LEFT JOIN ods.dbo.ct_artpatients art
                           ON patient.patientpk = art.patientpk
                              AND patient.sitecode = art.sitecode
                    LEFT JOIN ods.dbo.intermediate_latestviralloads vl
                           ON patient.patientpk = vl.patientpk
                              AND patient.sitecode = vl.sitecode
             WHERE  visits.pregnant = 'Yes'
                     OR breastfeeding = 'Yes'
                        AND visits.lmp > '1900-01-01'
                        AND visits.sitecode > 0
                        AND Datediff(year, patient.dob, Getdate()) > 10),
         ancdate2
         AS (SELECT pbfw_patient.patientpkhash,
                    pbfw_patient.sitecode,
					pbfw_patient.PatientPK,
                    pbfw_patient.visitdate AS ANCDate2
             FROM   pbfw_patient
             WHERE  num = 2),
         ancdate3
         AS (SELECT pbfw_patient.patientpkhash,
                    pbfw_patient.sitecode,
					pbfw_patient.PatientPK,
                    pbfw_patient.visitdate AS ANCDate3
             FROM   pbfw_patient
             WHERE  num = 3),
         ancdate4
         AS (SELECT pbfw_patient.patientpkhash,
                    pbfw_patient.sitecode,
					pbfw_patient.PatientPK,
                    pbfw_patient.visitdate AS ANCDate4
             FROM   pbfw_patient
             WHERE  num = 4),
         testsatanc
         AS (SELECT Row_number()
                      OVER (
                        partition BY tests.sitecode, tests.patientpk
                        ORDER BY tests.testdate ASC ) AS NUM,
                    tests.patientpkhash,
                    tests.sitecode,
					tests.PatientPk
             FROM   ods.dbo.hts_clienttests tests
             WHERE  entrypoint IN ( 'PMTCT ANC', 'MCH' )),
         testedatanc
         AS (SELECT pat.patientpkhash,
                    pat.sitecode,
					pat.patientpk
             FROM   testsatanc pat
             WHERE  num = 1),
         testsatlandd
         AS (SELECT Row_number()
                      OVER (
                        partition BY tests.sitecode, tests.patientpk
                        ORDER BY tests.testdate ASC ) AS NUM,
                    tests.patientpkhash,
					tests.PatientPk,
                    tests.sitecode          
             FROM   ods.dbo.hts_clienttests tests
             WHERE  entrypoint IN ( 'Maternity', 'PMTCT MAT' )),
         testedatlandd
         AS (SELECT pat.patientpkhash,
                    pat.sitecode,
					pat.PatientPk
             FROM   testsatlandd AS Pat
             WHERE  num = 1),
 testsatpnc
         AS (SELECT Row_number()
                      OVER (
                        partition BY tests.sitecode, tests.patientpk
                        ORDER BY tests.testdate ASC ) AS NUM,
                    tests.patientpkhash,
					tests.PatientPk,
                    tests.sitecode
             FROM   ods.dbo.hts_clienttests tests
             WHERE  entrypoint IN ( 'PMTCT PNC', 'PNC' ,'POSTNATAL CARE CLINIC')
         ),
         testedatpnc
         AS (SELECT pat.patientpkhash,
                    pat.sitecode,
					pat.patientpk
             FROM   testsatpnc pat
             WHERE  num = 1),

Unsuppressed As (Select 
    PatientPKHash,
	PatientPK,
    Sitecode
 
from pbfw_patient

),
EAC As (Select
 Row_number()
                      OVER (
                        partition BY EAC.sitecode, EAC.patientpk
                        ORDER BY EAC.Visitdate ASC ) AS NUM,
    PatientPKHash,
    Sitecode,
	PatientPK,
    VisitDate
    from ODS.dbo.CT_EnhancedAdherenceCounselling EAC
   
),
EAC1 AS (Select * from EAC
where Num=1),

EAC2 AS (Select * from EAC
where Num=2),

EAC3 AS (Select * from EAC
where Num=3),

ReceivedEAC1 AS (
    Select 
    EAC1.PatientPKHash,
    EAC1.Sitecode,
	EAC1.patientpk
    from EAC1 as EAC1
    ),
    ReceivedEAC2 AS (
    Select 
    EAC2.PatientPKHash,
	EAC2.patientpk,
    EAC2.Sitecode
    from EAC2 as EAC2
	),
 ReceivedEAC3 AS (
    Select 
    EAC3.PatientPKHash,
	EAC3.PatientPK,
    EAC3.Sitecode
    from  EAC3 as EAC3
    ),
	 
Switches  as (Select 

 Row_number()
                      OVER (
                        partition BY pharm.sitecode, pharm.patientpk
                        ORDER BY pharm.Dispensedate Desc ) AS NUM,
    pharm.patientpk,
    pharm.Sitecode,
    case when RegimenChangedSwitched is not null then 1 Else 0 End as PBFWRegLineSwitch
    from  ODS.dbo.CT_PatientPharmacy pharm 
    where RegimenChangedSwitched is not null
 ),
  PBFWRegLineSwitch as (select * from Switches
  where NUM=1
  ),

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
                  
                    Case When ReceivedEAC1.PatientPK is not null Then 1 Else 0 End as ReceivedEAC1,
                    Case When ReceivedEAC2.patientpk is not null Then 1 Else 0 End as ReceivedEAC2,
                    Case When ReceivedEAC3.patientpk is not null Then 1 Else 0 End as ReceivedEAC3,
                    PBFWRegLineSwitch
             FROM   pbfw_patient AS Patient
                    LEFT JOIN ancdate2
                           ON Patient.patientpk = ancdate2.patientpk
                              AND Patient.sitecode = ancdate2.sitecode
                    LEFT JOIN ancdate3
                           ON Patient.patientpk = ancdate3.patientpk
                              AND Patient.sitecode = ancdate3.sitecode
                    LEFT JOIN ancdate4
                           ON Patient.patientpk = ancdate4.patientpk
                              AND Patient.sitecode = ancdate4.sitecode
                    LEFT JOIN testedatanc
                           ON Patient.patientpk = testedatanc.patientpk
                              AND Patient.sitecode = testedatanc.sitecode
                    LEFT JOIN testedatlandd
                           ON Patient.patientpk =
                              testedatlandd.patientpk
                              AND Patient.sitecode = testedatlandd.sitecode
                    LEFT JOIN testedatpnc
                           ON Patient.patientpk =
                              testedatpnc.patientpk
                              AND Patient.sitecode = testedatpnc.sitecode
                    Left join ReceivedEAC1 on Patient.patientpk=ReceivedEAC1.patientpk and Patient.sitecode=ReceivedEAC1.sitecode
                    Left join ReceivedEAC2 on Patient.patientpk=ReceivedEAC2.patientpk and Patient.sitecode=ReceivedEAC2.sitecode
                    Left join ReceivedEAC3 on Patient.patientpk=ReceivedEAC3.patientpk and Patient.sitecode=ReceivedEAC3.sitecode
                   Left join PBFWRegLineSwitch on Patient.patientpk=PBFWRegLineSwitch.patientpk and Patient.Sitecode=PBFWRegLineSwitch.sitecode
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
           ANCDate1.datekey AS ANCDate1Key,
           ANCDate2.datekey AS ANCDate2Key,
           ANCDate3.datekey AS ANCDate3Key,
           ANCDate4.datekey AS ANCDate4Key,
           ReceivedEAC1,
           ReceivedEAC2,
           ReceivedEAC3,
           PBFWRegLineSwitch
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

