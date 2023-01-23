BEGIN
		MERGE [ODS].[dbo].[HTS_PositivePatients_new] AS a
			USING(SELECT  
					  DISTINCT
					   f.Name 
					  ,c.[SiteCode]
					  ,c.[Dob]
					  ,LEFT(c.[Gender],1) AS [Gender]
					  ,c.[PatientPK]
					  ,'NO' as [dead]
					  ,NULL as [death_date]
					  ,ct.[EncounterId] as visit_id
					  ,ct.[EncounterId] as [encounter_id]
					  ,ct.[TestDate] as [TestDate]
					  ,ct.[TestType]
					  ,c.[populationtype] as [population_type]
					  ,c.[KeyPopulationType] as [key_population_type]
					  ,ct.[EverTestedForHiv] as [ever_tested_for_hiv]
					  ,ct.[MonthsSinceLastTest] as [months_since_last_test]
					  ,c.[PatientDisabled] as [patient_disabled]
					  ,c.[DisabilityType] as [disability_type]
					  ,ct.[Consent] as [patient_consented]
					  ,ct.[ClientTestedAs] as [client_tested_as]
					  ,ct.[TestStrategy] as [test_strategy]
					  ,tk.TestKitName1 as  [test_1_kit_name]
					  ,tk.TestKitExpiry1 as  [test_1_kit_expiry]
					  ,ct.TestResult1 as  [test_1_result]
					  ,tk.TestKitName2 as [test_2_kit_name]
					  ,tk.TestKitExpiry2 as  [test_2_kit_expiry]
					  ,ct.TestResult2 as  [test_2_result]
					  ,ct.FinalTestResult [final_test_result]
					  ,ct.PatientGivenResult as  [patient_given_result]
					  ,ct.CoupleDiscordant as  [couple_discordant]
					  ,ct.TbScreening as  [tb_screening]
					  ,ct.ClientSelfTested as [patient_had_hiv_self_test]
					  ,trace.TracingOutcome as [tracing_status]
					  ,trace.TracingType  as [tracing_type]
					  ,lnk.ReportedCCCNumber as ReportedCCCNumber
					  ,lnk.EnrolledFacilityName as  [facility_linked_to]
					  ,lnk.[CKV]
					  --,CASE WHEN lnk.[PatientUID] IS NOT NULL THEN lnk.[PatientUID] ELSE cnew.NewUID END AS [ClientUPI]
					  --,lnk.[PatientUID]
					  ,lnk.CCCNumber AS [LinkedCCC_Number]
					  --INTO stg_HTS_PositivePatients_new
				  FROM hts_clients c 
				  inner join CT_FacilityManifest f on c.SiteCode =F.SiteCode
				  INNER JOIN hts_ClientTests ct ON ct.PatientPk=c.PatientPk AND ct.SiteCode=c.SiteCode
				  --inner join temp_new_ids cnew ON cnew.PatientPk=c.PatientPk AND cnew.SiteCode=c.SiteCode
				  LEFT JOIN vw_hts_ClientLinkages lnk on lnk.PatientPk=c.PatientPk AND ct.SiteCode = lnk.SiteCode
				  left join (select * from (
				  SELECT ROW_NUMBER() OVER(PARTITION BY sitecode, patientpk ORDER BY TracingDate desc) as Num, [SiteCode]
					  ,[PatientPk]
					  ,[TracingType]
					  ,[TracingOutcome], TracingDate
				  FROM [HTSCentral].[dbo].[HtsClientTracing]) a
				  where a.num=1) trace on trace.PatientPk=c.PatientPk AND ct.SiteCode = trace.SiteCode
				  LEFT JOIN (select * from (SELECT ROW_NUMBER() OVER(PARTITION BY sitecode, patientpk, EncounterId ORDER BY [TestKitExpiry1] desc) as Num, [SiteCode], EncounterId
					  ,[PatientPk]
					  ,[TestKitName1]
					  ,[TestKitLotNumber1]
					  ,[TestKitExpiry1]
					  ,[TestResult1]
					  ,[TestKitName2]
					  ,[TestKitLotNumber2]
					  ,[TestKitExpiry2]
					  ,[TestResult2]
				  FROM [HTSCentral].[dbo].HtsTestKits) a
				  where a.num=1) tk on tk.EncounterId = ct.EncounterId and ct.SiteCode = tk.SiteCode and tk.PatientPk = ct.PatientPk
				  WHERE FinalTestResult = 'Positive' 
			) AS b 
				ON(
					a.PatientPK  = b.PatientPK 
					and a.SiteCode = b.SiteCode						
				)
		WHEN NOT MATCHED THEN 
			INSERT(FacilityName,SiteCode,Dob,Gender,PatientPK,dead,death_date,visit_id,encounter_id,TestDate,TestType,population_type,key_population_type,ever_tested_for_hiv,months_since_last_test,patient_disabled,disability_type,patient_consented,client_tested_as,test_strategy,test_1_kit_name,test_1_kit_expiry,test_1_result,test_2_kit_name,test_2_kit_expiry,test_2_result,final_test_result,patient_given_result,couple_discordant,tb_screening,patient_had_hiv_self_test,tracing_status,tracing_type,ReportedCCCNumber,facility_linked_to,PKV,LinkedCCC_Number) 
			VALUES([Name],SiteCode,Dob,Gender,PatientPK,dead,death_date,visit_id,encounter_id,TestDate,TestType,population_type,key_population_type,ever_tested_for_hiv,months_since_last_test,patient_disabled,disability_type,patient_consented,client_tested_as,test_strategy,test_1_kit_name,test_1_kit_expiry,test_1_result,test_2_kit_name,test_2_kit_expiry,test_2_result,final_test_result,patient_given_result,couple_discordant,tb_screening,patient_had_hiv_self_test,tracing_status,tracing_type,ReportedCCCNumber,facility_linked_to,CKV,LinkedCCC_Number)
		
		WHEN MATCHED THEN
			UPDATE SET 

			a.[FacilityName]				=b.[Name],				
			a.[SiteCode]					=b.[SiteCode],
			a.[Dob]							=b.[Dob],	
			a.[Gender]						=b.[Gender]	,
			a.[PatientPK]					=b.[PatientPK],
			a.[dead]						=b.[dead],
			a.[death_date]					=b.[death_date],
			a.[visit_id]					=b.[visit_id],
			a.[encounter_id]				=b.[encounter_id],
			a.[TestDate]					=b.[TestDate],
			a.[TestType]					=b.[TestType],
			a.[population_type]				=b.[population_type],	
			a.[key_population_type]			=b.[key_population_type],	
			a.[ever_tested_for_hiv]			=b.[ever_tested_for_hiv],	
			a.[months_since_last_test]		=b.[months_since_last_test],
			a.[patient_disabled]			=b.[patient_disabled],
			a.[disability_type]				=b.[disability_type],	
			a.[patient_consented]			=b.[patient_consented],
			a.[client_tested_as]			=b.[client_tested_as],
			a.[test_strategy]				=b.[test_strategy]	,
			a.[test_1_kit_name]				=b.[test_1_kit_name],	
			a.[test_1_kit_expiry]			=b.[test_1_kit_expiry],
			a.[test_1_result]				=b.[test_1_result],
			a.[test_2_kit_name]				=b.[test_2_kit_name],	
			a.[test_2_kit_expiry]			=b.[test_2_kit_expiry],
			a.[test_2_result]				=b.[test_2_result],
			a.[final_test_result]			=b.[final_test_result]	,
			a.[patient_given_result]		=b.[patient_given_result],
			a.[couple_discordant]			=b.[couple_discordant],
			a.[tb_screening]				=b.[tb_screening],
			a.[patient_had_hiv_self_test]	=b.[patient_had_hiv_self_test],
			a.[tracing_status]				=b.[tracing_status]	,
			a.[tracing_type]				=b.[tracing_type],
			a.[ReportedCCCNumber]			=b.[ReportedCCCNumber],
			a.[facility_linked_to]			=b.[facility_linked_to],
			a.[CKV]							=b.[CKV],	
			a.[LinkedCCC_Number]			=b.[LinkedCCC_Number]
		WHEN NOT MATCHED BY SOURCE 
			THEN
				/* The Record is in the target table but doen't exit on the source table*/
			Delete;
END
