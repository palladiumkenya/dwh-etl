BEGIN
		MERGE [ODS].[dbo].[HTS_ClientTests] AS a
			USING(SELECT distinct a.[Id]
						  ,a.[FacilityName]
						  ,a.[SiteCode]
						  ,a.[PatientPk]
						  ,a.[Emr]
						  ,a.[Project]
						  ,a.[EncounterId]
						  ,[TestDate]
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
					  FROM [HTSCentral].[dbo].[HtsClientTests](NoLock) a
					INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
					  on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode
					   where a.FinalTestResult is not null
					   ) AS b 
				ON(
					a.PatientPK  = b.PatientPK 
				and a.SiteCode = b.SiteCode						
				)
		WHEN NOT MATCHED THEN 
			INSERT(FacilityName,SiteCode,PatientPk,Emr,Project,EncounterId,TestDate,EverTestedForHiv,MonthsSinceLastTest,ClientTestedAs,EntryPoint,TestStrategy,TestResult1,TestResult2,FinalTestResult,PatientGivenResult,TbScreening,ClientSelfTested,CoupleDiscordant,TestType,Consent) 
			VALUES(FacilityName,SiteCode,PatientPk,Emr,Project,EncounterId,TestDate,EverTestedForHiv,MonthsSinceLastTest,ClientTestedAs,EntryPoint,TestStrategy,TestResult1,TestResult2,FinalTestResult,PatientGivenResult,TbScreening,ClientSelfTested,CoupleDiscordant,TestType,Consent)
		
	   WHEN MATCHED THEN
			UPDATE SET 
					a.[FacilityName]		=b.[FacilityName],    
					a.[Emr]					=b.[Emr],
					a.[Project]				=b.[Project],
					a.[EncounterId]			=b.[EncounterId],
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


		WHEN NOT MATCHED BY SOURCE 
			THEN
				/* The Record is in the target table but doen't exit on the source table*/
			Delete;
END