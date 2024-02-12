BEGIN
    WITH ct_patient_source
         AS (SELECT DISTINCT patients.patientidhash,
                             patients.patientpkhash,
                             patients.patientid,
                             patients.patientpk,
                             patients.sitecode,
                             gender,
                             Cast(dob AS DATE)
                                AS DOB,
                             maritalstatus,
                             nupihash,
                             patienttype,
                             patientsource,
                             baselines.ewho
                                AS EnrollmentWHOKey,
                             Cast(Format(COALESCE(ewhodate, '1900-01-01'),
                                  'yyyyMMdd') AS
                                  INT) AS
                             DateEnrollmentWHOKey,
                             bwho
                                AS BaseLineWHOKey,
                             Cast(Format(COALESCE(bwhodate, '1900-01-01'),
                                  'yyyyMMdd') AS
                                  INT) AS
                             DateBaselineWHOKey,
                             CASE
                               WHEN outcomes.artoutcome = 'V' THEN 1
                               ELSE 0
                             END
                                AS IsTXCurr,
                             Cast(Getdate() AS DATE)
                                AS LoadDate,
								patients.voided
             FROM   ods.dbo.ct_patient AS patients
                    LEFT JOIN ods.dbo.ct_patientbaselines AS baselines
                           ON patients.patientpkhash = baselines.patientpkhash
                              AND patients.sitecode = baselines.sitecode and baselines.voided=0
                    LEFT JOIN ods.dbo.intermediate_artoutcomes AS outcomes
                           ON outcomes.patientpkhash = patients.patientpkhash
                              AND outcomes.sitecode = patients.sitecode

            ),
         hts_patient_source
         AS (SELECT DISTINCT htsnumberhash,
                             patientpkhash,
                             patientpk,
                             sitecode,
                             Cast(dob AS DATE) AS DOB,
                             gender,
                             maritalstatus,
                             nupihash,
							 clients.voided
             FROM   ods.dbo.hts_clients AS clients
   
            ),
         prep_patient_source
         AS (SELECT DISTINCT patientpkhash,
                             patientpk,
                             prepnumber,
                             sitecode,
                             prepenrollmentdate,
                             sex,
                             dateofbirth,
                             clienttype,
                             maritalstatus
							 ,voided
             FROM   ods.dbo.prep_patient),
         pmtct_patient_source
         AS (SELECT DISTINCT patientpkhash,
                             patientpk,
                             sitecode,
                             dob,
                             gender,
                             nupihash,
                             patientmnchidhash,
                             maritalstatus,
                             Cast(Format(firstenrollmentatmnch, 'yyyyMMdd') AS
                                  INT)
                             AS
                             FirstEnrollmentAtMnchDateKey
							 ,voided
             FROM   ods.dbo.mnch_patient),

ushauri_patient_source_nonEMR
         AS (SELECT DISTINCT 
                             ushauri.patientpkhash,
                             ushauri.PatientIDHash,
                             ushauri.patientpk,
                             ushauri.sitecode,
                             ushauri.patienttype,
                             ushauri.patientsource,
                             Try_convert(date,ushauri.DOB) AS DOB,
                             ushauri.gender,
                             ushauri.maritalstatus,
                             ushauri.nupihash,
                             baselines.ewho
                                AS EnrollmentWHOKey,
                             Cast(Format(COALESCE(ewhodate, '1900-01-01'),
                                  'yyyyMMdd') AS
                                  INT) AS
                             DateEnrollmentWHOKey,
                             bwho
                                AS BaseLineWHOKey,
                             Cast(Format(COALESCE(bwhodate, '1900-01-01'),
                                  'yyyyMMdd') AS
                                  INT) AS
                             DateBaselineWHOKey,
                             CASE
                               WHEN outcomes.artoutcome = 'V' THEN 1
                               ELSE 0
                             END
                                AS IsTXCurr,
                                ushauri.SiteType
             FROM   ods.dbo.Ushauri_Patient AS ushauri
             LEFT JOIN ods.dbo.CT_Patient As patient
              ON ushauri.PatientPKHash=patient.PatientPKHash
              AND ushauri.SiteCode=patient.SiteCode
              LEFT JOIN ods.dbo.ct_patientbaselines AS baselines
              ON ushauri.patientpkhash = baselines.patientpkhash
                AND ushauri.sitecode = baselines.sitecode and baselines.voided=0
             LEFT JOIN ods.dbo.intermediate_artoutcomes AS outcomes
                ON outcomes.patientpkhash = ushauri.patientpkhash
                AND outcomes.sitecode = ushauri.sitecode
                where Patient.PatientPKHash is null and patient.voided=0
             
              ),

         combined_data_ct_hts_ushauri
         AS (SELECT COALESCE(ct_patient_source.patientpkhash,
                    hts_patient_source.patientpkhash,ushauri_patient_source_nonEMR.patientpkhash) AS
                    PatientPKHash,
                    COALESCE(ct_patient_source.sitecode,
                    hts_patient_source.sitecode,ushauri_patient_source_nonEMR.sitecode)
                       AS SiteCode,
                    COALESCE(ct_patient_source.nupihash,
                    hts_patient_source.nupihash,ushauri_patient_source_nonEMR.nupihash)
                       AS NUPI,
                    COALESCE(ct_patient_source.dob, hts_patient_source.dob,ushauri_patient_source_nonEMR.dob)
                       AS DOB,
                    COALESCE(ct_patient_source.maritalstatus,
                    hts_patient_source.maritalstatus,ushauri_patient_source_nonEMR.maritalstatus) AS
                    MaritalStatus,
                    COALESCE(ct_patient_source.gender,
                    hts_patient_source.gender,ushauri_patient_source_nonEMR.gender)
                       AS Gender,
                    COALESCE (ct_patient_source.patientidhash,ushauri_patient_source_nonEMR.patientidhash) As PatientIdhash,
                    COALESCE (ct_patient_source.patienttype,ushauri_patient_source_nonEMR.patienttype) AS ClientType,
                    COALESCE(ct_patient_source.patientsource,ushauri_patient_source_nonEMR.patientsource) As Patientsource,
                    COALESCE(ct_patient_source.enrollmentwhokey,ushauri_patient_source_nonEMR.enrollmentwhokey) As enrollmentwhokey,
                    COALESCE(ct_patient_source.dateenrollmentwhokey,ushauri_patient_source_nonEMR.dateenrollmentwhokey) As dateenrollmentwhokey,
                    COALESCE (ct_patient_source.baselinewhokey,ushauri_patient_source_nonEMR.baselinewhokey) As baselinewhokey,
                    COALESCE (ct_patient_source.datebaselinewhokey,ushauri_patient_source_nonEMR.datebaselinewhokey) As datebaselinewhokey,
                    COALESCE(ct_patient_source.istxcurr,ushauri_patient_source_nonEMR.istxcurr) As istxcurr,
                    hts_patient_source.htsnumberhash,
                    sitetype,
                    Cast(Getdate() AS DATE)
                       AS LoadDate
					   ,COALESCE(ct_patient_source.voided,hts_patient_source.voided) As voided
             FROM   ct_patient_source
                    FULL JOIN hts_patient_source
                     ON hts_patient_source.patientpkhash =
                              ct_patient_source.patientpkhash
                    AND ct_patient_source.sitecode =
                                  hts_patient_source.sitecode
                    FULL JOIN ushauri_patient_source_nonEMR
                    ON ushauri_patient_source_nonEMR.PatientPKHash=ct_patient_source.PatientPKHash
                    AND ushauri_patient_source_nonEMR.SiteCode=ct_patient_source.SiteCode
                                  ),
         combined_data_ct_hts_prep_ushauri
         AS (SELECT COALESCE(combined_data_ct_hts_ushauri.patientpkhash,
                    prep_patient_source.patientpkhash)
                       AS PatientPKHash,
                    COALESCE(combined_data_ct_hts_ushauri.sitecode,
                    prep_patient_source.sitecode)
                       AS
                    SiteCode,
                    combined_data_ct_hts_ushauri.nupi
                       AS NUPI,
                    COALESCE(combined_data_ct_hts_ushauri.dob,
                    prep_patient_source.dateofbirth)
                       AS DOB,
                    COALESCE(combined_data_ct_hts_ushauri.maritalstatus,
                    prep_patient_source.maritalstatus)
                                                 AS MaritalStatus,
                    COALESCE(combined_data_ct_hts_ushauri.gender,
                    prep_patient_source.sex)
                       AS Gender,
                    combined_data_ct_hts_ushauri.patientidhash,
                    COALESCE(combined_data_ct_hts_ushauri.clienttype,
                       prep_patient_source.clienttype) AS
                    ClientType,
                    combined_data_ct_hts_ushauri.patientsource,
                    combined_data_ct_hts_ushauri.enrollmentwhokey,
                    combined_data_ct_hts_ushauri.dateenrollmentwhokey,
                    combined_data_ct_hts_ushauri.baselinewhokey,
                    combined_data_ct_hts_ushauri.datebaselinewhokey,
                    combined_data_ct_hts_ushauri.istxcurr,
                    combined_data_ct_hts_ushauri.htsnumberhash,
                    prep_patient_source.prepnumber,
                    Cast(Format(prep_patient_source.prepenrollmentdate,
                         'yyyyMMdd')
                         AS
                         INT)
                       AS
                    PrepEnrollmentDateKey,
                    Sitetype,
					COALESCE(combined_data_ct_hts_ushauri.voided,prep_patient_source.voided) As Voided
             FROM   combined_data_ct_hts_ushauri
                    FULL JOIN prep_patient_source
                           ON combined_data_ct_hts_ushauri.patientpkhash =
                              prep_patient_source.patientpkhash
                              AND prep_patient_source.sitecode =
                                  combined_data_ct_hts_ushauri.sitecode),
         combined_data_ct_hts_prep_pmtct_ushauri
         AS (SELECT COALESCE(combined_data_ct_hts_prep_ushauri.patientpkhash,
                               pmtct_patient_source.patientpkhash)
                       AS PatientPKHash,
                    COALESCE(combined_data_ct_hts_prep_ushauri.sitecode,
                    pmtct_patient_source.sitecode) AS
                    SiteCode,
                    COALESCE(combined_data_ct_hts_prep_ushauri.nupi,
                    pmtct_patient_source.nupihash)
                       AS Nupi,
                    COALESCE(combined_data_ct_hts_prep_ushauri.dob,
                    pmtct_patient_source.dob)
                       AS DOB,
                    COALESCE(combined_data_ct_hts_prep_ushauri.maritalstatus,
                    pmtct_patient_source.maritalstatus)
                       AS MaritalStatus,
                    COALESCE(combined_data_ct_hts_prep_ushauri.gender,
                    pmtct_patient_source.gender)
                       AS
                    Gender,
                    combined_data_ct_hts_prep_ushauri.patientidhash,
                    combined_data_ct_hts_prep_ushauri.clienttype,
                    combined_data_ct_hts_prep_ushauri.patientsource,
                    combined_data_ct_hts_prep_ushauri.enrollmentwhokey,
                    combined_data_ct_hts_prep_ushauri.dateenrollmentwhokey,
                    combined_data_ct_hts_prep_ushauri.baselinewhokey,
                    combined_data_ct_hts_prep_ushauri.datebaselinewhokey,
                    combined_data_ct_hts_prep_ushauri.istxcurr,
                    combined_data_ct_hts_prep_ushauri.htsnumberhash,
                    combined_data_ct_hts_prep_ushauri.prepenrollmentdatekey,
                    combined_data_ct_hts_prep_ushauri.prepnumber,
                    pmtct_patient_source.patientmnchidhash,
                    pmtct_patient_source.firstenrollmentatmnchdatekey,
                    sitetype,
                    Cast(Getdate() AS DATE)
                       AS LoadDate,
					   COALESCE(combined_data_ct_hts_prep_ushauri.voided,pmtct_patient_source.voided) As Voided
             FROM   combined_data_ct_hts_prep_ushauri
                    FULL JOIN pmtct_patient_source
                           ON combined_data_ct_hts_prep_ushauri.patientpkhash =
                              pmtct_patient_source.patientpkhash
                              AND combined_data_ct_hts_prep_ushauri.sitecode =
                                  pmtct_patient_source.sitecode),
        combined_matched_all_programs AS (
            SELECT combined_data_ct_hts_prep_pmtct_ushauri.*, golden_id as GoldenId
            FROM combined_data_ct_hts_prep_pmtct_ushauri LEFT JOIN ODS.dbo.MPI_MatchingOutput mmo ON mmo.site_code = combined_data_ct_hts_prep_pmtct_ushauri.sitecode
            AND mmo.patient_pk_hash = combined_data_ct_hts_prep_pmtct_ushauri.patientpkhash
        )
    MERGE [NDWH].[DBO].[dimpatient] AS a
    using (SELECT combined_matched_all_programs.patientidhash,
                  combined_matched_all_programs.patientpkhash,
                  combined_matched_all_programs.htsnumberhash,
                  combined_matched_all_programs.prepnumber,
                  combined_matched_all_programs.sitecode,
                  combined_matched_all_programs.nupi,
                  combined_matched_all_programs.goldenid,
                  combined_matched_all_programs.dob,
                  combined_matched_all_programs.maritalstatus,
                  CASE
                    WHEN combined_matched_all_programs.gender = 'M' THEN
                    'Male'
                    WHEN combined_matched_all_programs.gender = 'F' THEN
                    'Female'
                    ELSE combined_matched_all_programs.gender
                  END AS Gender,
                  combined_matched_all_programs.clienttype,
                  combined_matched_all_programs.patientsource,
                  combined_matched_all_programs.enrollmentwhokey,
                  combined_matched_all_programs.datebaselinewhokey,
                  combined_matched_all_programs.baselinewhokey,
                  combined_matched_all_programs.prepenrollmentdatekey,
                  combined_matched_all_programs.istxcurr,
                  combined_matched_all_programs.patientmnchidhash,
                  combined_matched_all_programs.firstenrollmentatmnchdatekey,
                  combined_matched_all_programs.loaddate,
				  combined_matched_all_programs.voided
           FROM   combined_matched_all_programs) AS b
    ON ( a.sitecode = b.sitecode
         AND a.patientpkhash = b.patientpkhash
		 and a.voided  = b.voided
        )
    WHEN NOT matched THEN
      INSERT(patientidhash,
             patientpkhash,
             htsnumberhash,
             prepnumber,
             sitecode,
             nupi,
             goldenid,
             dob,
             maritalstatus,
             gender,
             clienttype,
             patientsource,
             enrollmentwhokey,
             datebaselinewhokey,
             baselinewhokey,PrepEnrollmentDateKey,
             istxcurr,
             loaddate,
			 voided)
      VALUES(patientidhash,
             patientpkhash,
             htsnumberhash,
             prepnumber,
             sitecode,
             nupi,
             goldenid,
             dob,
             maritalstatus,
             gender,
             clienttype,
             patientsource,
             enrollmentwhokey,
             datebaselinewhokey,
             baselinewhokey,
             PrepEnrollmentDateKey,
             istxcurr,
             loaddate,
			 voided)
    WHEN matched THEN
      UPDATE SET a.maritalstatus = b.maritalstatus,
                 a.clienttype		= b.clienttype,
                 a.patientsource	= b.patientsource,
				 a.patientidhash   = b.patientidhash,
                 a.nupi				= b.nupi,
                 a.goldenid      = b.goldenid,
                 a.dob				= b.dob,
                 a.gender			= b.gender,
                 a.prepnumber		= b.prepnumber,
				 a.IsTXCurr          = b.IsTXCurr,
				 a.enrollmentwhokey  =b.enrollmentwhokey,
				 a.baselinewhokey  =b.baselinewhokey,
				 a.PrepEnrollmentDateKey = b.PrepEnrollmentDateKey,
				 a.voided				= b.voided;
END 


select 
    ushauripatientpk,
    Emr,
    PatientPK

 from ODS.dbo.Ushauri_Patient
 where emr='KenyaEMR'
