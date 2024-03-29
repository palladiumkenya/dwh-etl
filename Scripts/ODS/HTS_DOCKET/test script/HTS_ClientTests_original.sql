BEGIN
  --truncate table [ODS].[dbo].[HTS_ClientTests]
		MERGE [ODS].[dbo].[HTS_ClientTests] AS a
			USING(SELECT distinct
			             -- a.ID
						  a.[FacilityName]

						  ,a.[SiteCode]
						  ,a.[PatientPk]
						  ,a.[Emr]
						  ,a.[Project]
						  ,coalesce(a.[EncounterId],-1)EncounterId
						  ,a.[TestDate]
						  --,a.DateExtracted
						  ,[EverTestedForHiv]
						  ,[MonthsSinceLastTest]
						  ,a.[ClientTestedAs]
						  --,a.[EntryPoint]
						  --,mm.target_name as Entrypoint
						  ,coalesce(mm.target_name,NULL,a.[EntryPoint],null,'Empty') as Entrypoint
						  --,a.[TestStrategy]
						 -- ,mp.Target_htsStrategy as TestStrategy
						  ,coalesce(mp.Target_htsStrategy,NULL,a.[TestStrategy],null,'Empty') as TestStrategy
						  ,coalesce(a.[TestResult1],'empty')TestResult1
						  ,coalesce(a.[TestResult2],'empty')TestResult2
						  ,a.[FinalTestResult]
						  ,[PatientGivenResult]
						  ,[TbScreening]
						  ,a.[ClientSelfTested]
						  ,a.[CoupleDiscordant]
						  ,a.[TestType]
						  ,[Consent]
						  ,Setting
						  ,Approach                                                           
						  ,HtsRiskCategory
						  ,HtsRiskScore
							  
					 FROM [HTSCentral].[dbo].[HtsClientTests](NoLock) a					  
					 LEFT JOIN ods.dbo.lkp_patient_source mm
						on a.entryPoint =mm.source_name
					 LEFT JOIN ods.dbo.lkp_htsStrategy mp
						on a.TestStrategy = mp.Source_htsStrategy
					 INNER JOIN ( select  ct.sitecode,ct.patientPK,ct.TestResult1,ct.TestResult2,ct.FinalTestResult,ct.TestDate,ct.TestType,ct.EncounterId
										   ,mq.Target_htsStrategy, ct.TestStrategy,mn.target_name, ct.EntryPoint,max(DateExtracted)MaxDateExtracted  
									from [HTSCentral].[dbo].[HtsClientTests] ct								  
									LEFT JOIN ods.dbo.lkp_patient_source mn
										on ct.entryPoint = mn.source_name
									LEFT JOIN ods.dbo.lkp_htsStrategy mq
										on ct.TestStrategy = mq.Source_htsStrategy
									GROUP BY ct.sitecode,ct.patientPK,ct.TestResult1,ct.TestResult2,ct.FinalTestResult,ct.TestDate
											 ,ct.TestType,ct.EncounterId,ct.TestStrategy,mn.target_name,mq.Target_htsStrategy
											,ct.EntryPoint)tn
									on a.sitecode = tn.sitecode 
									and a.patientPK = tn.patientPK 
									and a.DateExtracted = tn.MaxDateExtracted
									and coalesce(a.TestResult1,'Empty') = coalesce(tn.TestResult1,'Empty')
									and coalesce(a.TestResult2,'Empty') = coalesce(tn.TestResult2,'Empty')
									and a.FinalTestResult = tn.FinalTestResult
									and coalesce(a.TestDate,'Empty') = coalesce(tn.TestDate,'Empty')
									and coalesce(a.TestType,'Empty') = coalesce(tn.TestType,'Empty')
									and coalesce(mm.target_name,NULL,a.[EntryPoint],null,'Empty') = coalesce(tn.target_name,NULL,a.[EntryPoint],null,'Empty')
									and coalesce(mp.Target_htsStrategy,NULL,a.[TestStrategy],null,'Empty') = coalesce(tn.Target_htsStrategy,NULL,tn.[TestStrategy],null,'Empty')
									and coalesce(a.EncounterId,-1) = coalesce(tn.EncounterId,-1)
					INNER JOIN  [HTSCentral].[dbo].Clients(NoLock) c								
						ON a.[SiteCode] = c.[SiteCode] and a.PatientPK=c.PatientPK 			
				
					where a.FinalTestResult is not null
						   ) AS b 
					ON(
					--a.ID = b.ID
					a.sitecode = b.sitecode
					and a.PatientPK  = b.PatientPK 
					and a.TestResult1 = b.TestResult1					
					and coalesce(a.TestResult2,'Empty') = coalesce(b.TestResult2,'Empty')
					and a.FinalTestResult = b.FinalTestResult
					and a.TestDate = b.TestDate
					and a.TestType = b.TestType
					and a.EntryPoint = b.EntryPoint 
					and a.TestStrategy = b.TestStrategy
					and a.EncounterId = b.EncounterId

					)		
	  -- WHEN MATCHED THEN
			--UPDATE SET 
					   
			--		a.[EverTestedForHiv]	=b.[EverTestedForHiv],
			--		a.[MonthsSinceLastTest]	=b.[MonthsSinceLastTest],
			--		a.[ClientTestedAs]		=b.[ClientTestedAs],					
			--		a.[PatientGivenResult]	=b.[PatientGivenResult],
			--		a.[TbScreening]			=b.[TbScreening],
			--		a.[ClientSelfTested]	=b.[ClientSelfTested],
			--		a.[CoupleDiscordant]	=b.[CoupleDiscordant],
			--		a.[Consent]				=b.[Consent]

		WHEN NOT MATCHED THEN 
			INSERT(FacilityName,SiteCode,PatientPk,Emr,Project,EncounterId,TestDate,EverTestedForHiv,MonthsSinceLastTest,ClientTestedAs,EntryPoint,TestStrategy,TestResult1,TestResult2,FinalTestResult,PatientGivenResult,TbScreening,ClientSelfTested,CoupleDiscordant,TestType,Consent,Setting,Approach,HtsRiskCategory,HtsRiskScore) 
			VALUES(FacilityName,SiteCode,PatientPk,Emr,Project,EncounterId,TestDate,EverTestedForHiv,MonthsSinceLastTest,ClientTestedAs,EntryPoint,TestStrategy,TestResult1,TestResult2,FinalTestResult,PatientGivenResult,TbScreening,ClientSelfTested,CoupleDiscordant,TestType,Consent,Setting,Approach,HtsRiskCategory,HtsRiskScore);

END
