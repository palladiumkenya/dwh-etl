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
         combined_data_ct_hts
         AS (SELECT COALESCE(ct_patient_source.patientpkhash,
                    hts_patient_source.patientpkhash) AS
                    PatientPKHash,
                    COALESCE(ct_patient_source.sitecode,
                    hts_patient_source.sitecode)
                       AS SiteCode,
                    COALESCE(ct_patient_source.nupihash,
                    hts_patient_source.nupihash)
                       AS NUPI,
                    COALESCE(ct_patient_source.dob, hts_patient_source.dob)
                       AS DOB,
                    COALESCE(ct_patient_source.maritalstatus,
                    hts_patient_source.maritalstatus) AS
                    MaritalStatus,
                    COALESCE(ct_patient_source.gender,
                    hts_patient_source.gender)
                       AS Gender,
                    ct_patient_source.patientidhash,
                    ct_patient_source.patienttype
                       AS ClientType,
                    ct_patient_source.patientsource,
                    ct_patient_source.enrollmentwhokey,
                    ct_patient_source.dateenrollmentwhokey,
                    ct_patient_source.baselinewhokey,
                    ct_patient_source.datebaselinewhokey,
                    ct_patient_source.istxcurr,
                    hts_patient_source.htsnumberhash,
                    Cast(Getdate() AS DATE)
                       AS LoadDate
					   ,COALESCE(ct_patient_source.voided,hts_patient_source.voided) As voided
             FROM   ct_patient_source
                    FULL JOIN hts_patient_source
                           ON hts_patient_source.patientpkhash =
                              ct_patient_source.patientpkhash
                              AND ct_patient_source.sitecode =
                                  hts_patient_source.sitecode),
         combined_data_ct_hts_prep
         AS (SELECT COALESCE(combined_data_ct_hts.patientpkhash,
                    prep_patient_source.patientpkhash)
                       AS PatientPKHash,
                    COALESCE(combined_data_ct_hts.sitecode,
                    prep_patient_source.sitecode)
                       AS
                    SiteCode,
                    combined_data_ct_hts.nupi
                       AS NUPI,
                    COALESCE(combined_data_ct_hts.dob,
                    prep_patient_source.dateofbirth)
                       AS DOB,
                    COALESCE(combined_data_ct_hts.maritalstatus,
                    prep_patient_source.maritalstatus)
                                                 AS MaritalStatus,
                    COALESCE(combined_data_ct_hts.gender,
                    prep_patient_source.sex)
                       AS Gender,
                    combined_data_ct_hts.patientidhash,
                    COALESCE(combined_data_ct_hts.clienttype,
                       prep_patient_source.clienttype) AS
                    ClientType,
                    combined_data_ct_hts.patientsource,
                    combined_data_ct_hts.enrollmentwhokey,
                    combined_data_ct_hts.dateenrollmentwhokey,
                    combined_data_ct_hts.baselinewhokey,
                    combined_data_ct_hts.datebaselinewhokey,
                    combined_data_ct_hts.istxcurr,
                    combined_data_ct_hts.htsnumberhash,
                    prep_patient_source.prepnumber,
                    Cast(Format(prep_patient_source.prepenrollmentdate,
                         'yyyyMMdd')
                         AS
                         INT)
                       AS
                    PrepEnrollmentDateKey,
					COALESCE(combined_data_ct_hts.voided,prep_patient_source.voided) As Voided
             FROM   combined_data_ct_hts
                    FULL JOIN prep_patient_source
                           ON combined_data_ct_hts.patientpkhash =
                              prep_patient_source.patientpkhash
                              AND prep_patient_source.sitecode =
                                  combined_data_ct_hts.sitecode),
         combined_data_ct_hts_prep_pmtct
         AS (SELECT COALESCE(combined_data_ct_hts_prep.patientpkhash,
                               pmtct_patient_source.patientpkhash)
                       AS PatientPKHash,
                    COALESCE(combined_data_ct_hts_prep.sitecode,
                    pmtct_patient_source.sitecode) AS
                    SiteCode,
                    COALESCE(combined_data_ct_hts_prep.nupi,
                    pmtct_patient_source.nupihash)
                       AS Nupi,
                    COALESCE(combined_data_ct_hts_prep.dob,
                    pmtct_patient_source.dob)
                       AS DOB,
                    COALESCE(combined_data_ct_hts_prep.maritalstatus,
                    pmtct_patient_source.maritalstatus)
                       AS MaritalStatus,
                    COALESCE(combined_data_ct_hts_prep.gender,
                    pmtct_patient_source.gender)
                       AS
                    Gender,
                    combined_data_ct_hts_prep.patientidhash,
                    combined_data_ct_hts_prep.clienttype,
                    combined_data_ct_hts_prep.patientsource,
                    combined_data_ct_hts_prep.enrollmentwhokey,
                    combined_data_ct_hts_prep.dateenrollmentwhokey,
                    combined_data_ct_hts_prep.baselinewhokey,
                    combined_data_ct_hts_prep.datebaselinewhokey,
                    combined_data_ct_hts_prep.istxcurr,
                    combined_data_ct_hts_prep.htsnumberhash,
                    combined_data_ct_hts_prep.prepenrollmentdatekey,
                    combined_data_ct_hts_prep.prepnumber,
                    pmtct_patient_source.patientmnchidhash,
                    pmtct_patient_source.firstenrollmentatmnchdatekey,
                    Cast(Getdate() AS DATE)
                       AS LoadDate,
					   COALESCE(combined_data_ct_hts_prep.voided,pmtct_patient_source.voided) As Voided
             FROM   combined_data_ct_hts_prep
                    FULL JOIN pmtct_patient_source
                           ON combined_data_ct_hts_prep.patientpkhash =
                              pmtct_patient_source.patientpkhash
                              AND combined_data_ct_hts_prep.sitecode =
                                  pmtct_patient_source.sitecode),
        combined_matched_all_programs AS (
            SELECT combined_data_ct_hts_prep_pmtct.*, golden_id as GoldenId
            FROM combined_data_ct_hts_prep_pmtct LEFT JOIN MPI_MatchingOutput mmo ON mmo.site_code = combined_data_ct_hts_prep_pmtct.sitecode
            AND mmo.patient_pk_hash = combined_data_ct_hts_prep_pmtct.patientpkhash
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
             baselinewhokey,PrepEnrollmentDateKey,
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