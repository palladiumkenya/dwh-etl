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
						  ,a.[EncounterId]
						  ,a.[TestDate]
						  --,a.DateExtracted
						  ,[EverTestedForHiv]
						  ,[MonthsSinceLastTest]
						  ,a.[ClientTestedAs]
						  --,a.[EntryPoint]
						  ,mm.target_name as Entrypoint
						  --,a.[TestStrategy]
						  ,mp.Target_htsStrategy as TestStrategy
						  ,a.[TestResult1]
						  ,a.[TestResult2]
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
					 INNER JOIN ods.dbo.lkp_patient_source mm
						on a.entryPoint =mm.source_name
					 INNER JOIN ods.dbo.lkp_htsStrategy mp
						on a.TestStrategy = mp.Source_htsStrategy
					 INNER JOIN ( select  ct.sitecode,ct.patientPK,ct.TestResult1,ct.TestResult2,ct.FinalTestResult,ct.TestDate,ct.TestType,ct.EncounterId
										   ,mq.Target_htsStrategy as TestStrategy,mn.target_name as EntryPoint,max(DateExtracted)MaxDateExtracted  
									from [HTSCentral].[dbo].[HtsClientTests] ct								  
									INNER JOIN ods.dbo.lkp_patient_source mn
										on ct.entryPoint = mn.source_name
									INNER JOIN ods.dbo.lkp_htsStrategy mq
										on ct.TestStrategy = mq.Source_htsStrategy
									GROUP BY ct.sitecode,ct.patientPK,ct.TestResult1,ct.TestResult2,ct.FinalTestResult,ct.TestDate
											 ,ct.TestType,ct.EncounterId,ct.TestStrategy,mn.target_name,mq.Target_htsStrategy)tn
									on a.sitecode = tn.sitecode 
									and a.patientPK = tn.patientPK 
									and a.DateExtracted = tn.MaxDateExtracted
									and coalesce(a.TestResult1,'Empty') = coalesce(tn.TestResult1,'Empty')
									and coalesce(a.TestResult2,'Empty') = coalesce(tn.TestResult2,'Empty')
									and a.FinalTestResult = tn.FinalTestResult
									and coalesce(a.TestDate,'Empty') = coalesce(tn.TestDate,'Empty')
									and coalesce(a.TestType,'Empty') = coalesce(tn.TestType,'Empty')
									and mm.target_name = tn.EntryPoint
									and mp.Target_htsStrategy = tn.TestStrategy
									and a.EncounterId = tn.EncounterId
					INNER JOIN  [HTSCentral].[dbo].Clients(NoLock) b								
						ON a.[SiteCode] = b.[SiteCode] and a.PatientPK=b.PatientPK 			
				
					where a.FinalTestResult is not null
						   ) AS b 
					ON(
					--a.ID = b.ID
					a.sitecode = b.sitecode
					and a.PatientPK  = b.PatientPK 
					and coalesce(a.TestResult1,'Empty') = coalesce(b.TestResult1,'Empty')
					and coalesce(a.TestResult2,'Empty') = coalesce(b.TestResult2,'Empty')
					and a.FinalTestResult = b.FinalTestResult
					and a.TestDate = b.TestDate
					and coalesce(a.TestType,'Empty') = coalesce(b.TestType,'Empty')
					and coalesce(a.EntryPoint ,'Empty') = coalesce(b.EntryPoint ,'Empty')
					and coalesce(a.TestStrategy,'Empty') = coalesce(b.TestStrategy,'Empty')
					and a.EncounterId = b.EncounterId

					)		
	   WHEN MATCHED THEN
			UPDATE SET 
					   
					a.[EverTestedForHiv]	=b.[EverTestedForHiv],
					a.[MonthsSinceLastTest]	=b.[MonthsSinceLastTest],
					a.[ClientTestedAs]		=b.[ClientTestedAs],					
					a.[PatientGivenResult]	=b.[PatientGivenResult],
					a.[TbScreening]			=b.[TbScreening],
					a.[ClientSelfTested]	=b.[ClientSelfTested],
					a.[CoupleDiscordant]	=b.[CoupleDiscordant],
					a.[Consent]				=b.[Consent]

		WHEN NOT MATCHED THEN 
			INSERT(FacilityName,SiteCode,PatientPk,Emr,Project,EncounterId,TestDate,EverTestedForHiv,MonthsSinceLastTest,ClientTestedAs,EntryPoint,TestStrategy,TestResult1,TestResult2,FinalTestResult,PatientGivenResult,TbScreening,ClientSelfTested,CoupleDiscordant,TestType,Consent,Setting,Approach,HtsRiskCategory,HtsRiskScore) 
			VALUES(FacilityName,SiteCode,PatientPk,Emr,Project,EncounterId,TestDate,EverTestedForHiv,MonthsSinceLastTest,ClientTestedAs,EntryPoint,TestStrategy,TestResult1,TestResult2,FinalTestResult,PatientGivenResult,TbScreening,ClientSelfTested,CoupleDiscordant,TestType,Consent,Setting,Approach,HtsRiskCategory,HtsRiskScore);

		
END