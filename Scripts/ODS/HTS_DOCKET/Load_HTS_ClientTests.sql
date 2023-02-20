
BEGIN
  --truncate table [ODS].[dbo].[HTS_ClientTests]
		MERGE [ODS].[dbo].[HTS_ClientTests] AS a
			USING(SELECT distinct
			              a.ID
						  ,a.[FacilityName]

						  ,a.[SiteCode]
						  ,a.[PatientPk]
						  ,a.[Emr]
						  ,a.[Project]
						  ,a.[EncounterId]
						  ,[TestDate]
						  --,a.DateExtracted
						  ,[EverTestedForHiv]
						  ,[MonthsSinceLastTest]
						  ,a.[ClientTestedAs]
						  ,[EntryPoint]
						  ,[TestStrategy]
						  ,[TestResult1]
						  ,[TestResult2]
						  ,[FinalTestResult]
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
				inner JOIN  [HTSCentral].[dbo].Clients(NoLock) b								
				ON a.[SiteCode] = b.[SiteCode] and a.PatientPK=b.PatientPK 
				where a.FinalTestResult is not null
					   ) AS b 
				ON(
				a.ID = b.ID
				and a.PatientPK  = b.PatientPK 

				)
		
	   WHEN MATCHED THEN
			UPDATE SET 
					a.[FacilityName]		=b.[FacilityName],    
				
					a.[TestDate]			=b.[TestDate],
					a.[EverTestedForHiv]	=b.[EverTestedForHiv],
					a.[MonthsSinceLastTest]	=b.[MonthsSinceLastTest],
					a.[ClientTestedAs]		=b.[ClientTestedAs],
					a.[EntryPoint]			=b.[EntryPoint],
					a.[TestStrategy]		=b.[TestStrategy],
					a.[TestResult1]			=b.[TestResult1],
					a.[TestResult2]			=b.[TestResult2],
					a.[FinalTestResult]		=b.[FinalTestResult],
					a.[PatientGivenResult]	=b.[PatientGivenResult],
					a.[TbScreening]			=b.[TbScreening],
					a.[ClientSelfTested]	=b.[ClientSelfTested],
					a.[CoupleDiscordant]	=b.[CoupleDiscordant],
					a.[TestType]			=b.[TestType],
					a.[Consent]				=b.[Consent]

		WHEN NOT MATCHED THEN 
			INSERT(FacilityName,SiteCode,PatientPk,Emr,Project,EncounterId,TestDate,EverTestedForHiv,MonthsSinceLastTest,ClientTestedAs,EntryPoint,TestStrategy,TestResult1,TestResult2,FinalTestResult,PatientGivenResult,TbScreening,ClientSelfTested,CoupleDiscordant,TestType,Consent,Setting,Approach,HtsRiskCategory,HtsRiskScore) 
			VALUES(FacilityName,SiteCode,PatientPk,Emr,Project,EncounterId,TestDate,EverTestedForHiv,MonthsSinceLastTest,ClientTestedAs,EntryPoint,TestStrategy,TestResult1,TestResult2,FinalTestResult,PatientGivenResult,TbScreening,ClientSelfTested,CoupleDiscordant,TestType,Consent,Setting,Approach,HtsRiskCategory,HtsRiskScore);

		
END