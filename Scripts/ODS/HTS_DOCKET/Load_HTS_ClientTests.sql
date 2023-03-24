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
						  ,a.[EntryPoint]
						  ,a.[TestStrategy]
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
					  Inner join ( select ct.sitecode,ct.patientPK,ct.TestResult1,ct.TestResult2,ct.FinalTestResult,ct.TestDate,ct.TestType,ct.EncounterId,ct.TestStrategy,ct.EntryPoint,max(DateExtracted)MaxDateExtracted  from [HTSCentral].[dbo].[HtsClientTests] ct
									group by ct.sitecode,ct.patientPK,ct.TestResult1,ct.TestResult2,ct.FinalTestResult,ct.TestDate,ct.TestType,ct.EncounterId,ct.TestStrategy,ct.EntryPoint)tn
									on a.sitecode = tn.sitecode and a.patientPK = tn.patientPK 
									and a.DateExtracted = tn.MaxDateExtracted
									and a.TestResult1 = tn.TestResult1
									and a.TestResult2 = tn.TestResult2
									and a.FinalTestResult = tn.FinalTestResult
									and a.TestDate = tn.TestDate
									and a.TestType = tn.TestType
									and a.EntryPoint = tn.EntryPoint
									and a.TestStrategy = tn.TestStrategy
									and a.EncounterId = tn.EncounterId
				inner JOIN  [HTSCentral].[dbo].Clients(NoLock) b								
				ON a.[SiteCode] = b.[SiteCode] and a.PatientPK=b.PatientPK 			
				
				where a.FinalTestResult is not null
					   ) AS b 
				ON(
				--a.ID = b.ID
				a.sitecode = b.sitecode
				and a.PatientPK  = b.PatientPK 
				and a.TestResult1 = b.TestResult1
				and a.TestResult2 = b.TestResult2
				and a.FinalTestResult = b.FinalTestResult
				and a.TestDate = b.TestDate
				and a.TestType = b.TestType
				and a.EntryPoint = b.EntryPoint
				and a.TestStrategy = b.TestStrategy
				and a.EncounterId = b.EncounterId

				)
		
	   WHEN MATCHED THEN
			UPDATE SET 
					a.[FacilityName]		=b.[FacilityName],    
					a.[EverTestedForHiv]	=b.[EverTestedForHiv],
					a.[MonthsSinceLastTest]	=b.[MonthsSinceLastTest],
					a.[ClientTestedAs]		=b.[ClientTestedAs],
					a.[EntryPoint]			=b.[EntryPoint],
					a.[PatientGivenResult]	=b.[PatientGivenResult],
					a.[TbScreening]			=b.[TbScreening],
					a.[ClientSelfTested]	=b.[ClientSelfTested],
					a.[CoupleDiscordant]	=b.[CoupleDiscordant],
					a.[Consent]				=b.[Consent]

		WHEN NOT MATCHED THEN 
			INSERT(FacilityName,SiteCode,PatientPk,Emr,Project,EncounterId,TestDate,EverTestedForHiv,MonthsSinceLastTest,ClientTestedAs,EntryPoint,TestStrategy,TestResult1,TestResult2,FinalTestResult,PatientGivenResult,TbScreening,ClientSelfTested,CoupleDiscordant,TestType,Consent,Setting,Approach,HtsRiskCategory,HtsRiskScore) 
			VALUES(FacilityName,SiteCode,PatientPk,Emr,Project,EncounterId,TestDate,EverTestedForHiv,MonthsSinceLastTest,ClientTestedAs,EntryPoint,TestStrategy,TestResult1,TestResult2,FinalTestResult,PatientGivenResult,TbScreening,ClientSelfTested,CoupleDiscordant,TestType,Consent,Setting,Approach,HtsRiskCategory,HtsRiskScore);

		
END