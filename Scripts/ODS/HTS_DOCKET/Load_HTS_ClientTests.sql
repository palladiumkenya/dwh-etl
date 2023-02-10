
BEGIN
  --truncate table [ODS].[dbo].[HTS_ClientTests]
       ALTER TABLE [HTSCentral].[dbo].HtsClientTests ALTER COLUMN TestType nvarchar(4000) COLLATE Latin1_General_CI_AS;
	   ALTER TABLE [HTSCentral].[dbo].HtsClientTests ALTER COLUMN [EntryPoint] nvarchar(4000) COLLATE Latin1_General_CI_AS;
	   ALTER TABLE [HTSCentral].[dbo].HtsClientTests ALTER COLUMN [EverTestedForHiv] nvarchar(4000) COLLATE Latin1_General_CI_AS;
	   ALTER TABLE [HTSCentral].[dbo].HtsClientTests ALTER COLUMN [TestResult1] nvarchar(4000) COLLATE Latin1_General_CI_AS;
	   ALTER TABLE [HTSCentral].[dbo].HtsClientTests ALTER COLUMN [TestResult2] nvarchar(4000) COLLATE Latin1_General_CI_AS;
	   ALTER TABLE [HTSCentral].[dbo].HtsClientTests ALTER COLUMN [FinalTestResult] nvarchar(4000) COLLATE Latin1_General_CI_AS;
	   ALTER TABLE [HTSCentral].[dbo].HtsClientTests ALTER COLUMN FacilityName nvarchar(4000) COLLATE Latin1_General_CI_AS;
	   ALTER TABLE [ODS].[dbo].[HTS_ClientTests]	ALTER COLUMN CoupleDiscordant nvarchar(4000) COLLATE Latin1_General_CI_AS;
	   --ALTER TABLE [ODS].[dbo].[HTS_ClientTests]   ALTER COLUMN Consent nvarchar(4000)  COLLATE Latin1_General_CI_AS;
	   ALTER TABLE [HTSCentral].[dbo].HtsClientTests ALTER COLUMN ClientTestedAs nvarchar(4000) COLLATE Latin1_General_CI_AS;
	   ALTER TABLE [HTSCentral].[dbo].HtsClientTests ALTER COLUMN TbScreening nvarchar(4000) COLLATE Latin1_General_CI_AS; 
	   ALTER TABLE [HTSCentral].[dbo].HtsClientTests ALTER COLUMN PatientGivenResult nvarchar(4000) COLLATE Latin1_General_CI_AS;
	   ALTER TABLE [HTSCentral].[dbo].HtsClientTests ALTER COLUMN TestDate nvarchar(4000) COLLATE Latin1_General_CI_AS;
	  ALTER TABLE [HTSCentral].[dbo].HtsClientTests ALTER COLUMN [ClientSelfTested] nvarchar(4000) COLLATE Latin1_General_CI_AS; 
	 ALTER TABLE [HTSCentral].[dbo].HtsClientTests ALTER COLUMN MonthsSinceLastTest nvarchar(4000) COLLATE Latin1_General_CI_AS; 



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
						  ,HtsRiskScore,
							   convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[PatientPk]  as nvarchar(36))), 2) PatientPKHash
					  FROM [HTSCentral].[dbo].[HtsClientTests](NoLock) a
				inner JOIN  [HTSCentral].[dbo].Clients(NoLock) b								
				ON a.[SiteCode] = b.[SiteCode] and a.PatientPK=b.PatientPK 
				where a.FinalTestResult is not null
					   ) AS b 
				ON(
				a.ID = b.ID
				and a.PatientPK  = b.PatientPK 
				and a.SiteCode = b.SiteCode	
				--and a.TestStrategy = b.TestStrategy 
				--and a.[EncounterId] = b.[EncounterId]
				--and a.[EntryPoint] = b.[EntryPoint]
				--and a.[EverTestedForHiv] = b.[EverTestedForHiv]
				--and a.[TestResult1] = b.[TestResult1]
				--and a.[TestResult2] = b.[TestResult2]
				--and a.[FinalTestResult] = b.[FinalTestResult]								
				--and a.FacilityName = b.FacilityName
				--and a.TestDate =b.TestDate			
				--and a.CoupleDiscordant = b.CoupleDiscordant 
				--and a.Consent COLLATE Latin1_General_CI_AS = b.Consent
				--and a.ClientTestedAs = b.ClientTestedAs
				--and a.TbScreening = b.TbScreening
				--and a.PatientGivenResult =b.PatientGivenResult
				--and a. ClientSelfTested = b.ClientSelfTested
				--and a.MonthsSinceLastTest = b.MonthsSinceLastTest
				)
		
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

		WHEN NOT MATCHED THEN 
			INSERT(FacilityName,SiteCode,PatientPk,Emr,Project,EncounterId,TestDate,EverTestedForHiv,MonthsSinceLastTest,ClientTestedAs,EntryPoint,TestStrategy,TestResult1,TestResult2,FinalTestResult,PatientGivenResult,TbScreening,ClientSelfTested,CoupleDiscordant,TestType,Consent,Setting,Approach,HtsRiskCategory,HtsRiskScore,PatientPKHash) 
			VALUES(FacilityName,SiteCode,PatientPk,Emr,Project,EncounterId,TestDate,EverTestedForHiv,MonthsSinceLastTest,ClientTestedAs,EntryPoint,TestStrategy,TestResult1,TestResult2,FinalTestResult,PatientGivenResult,TbScreening,ClientSelfTested,CoupleDiscordant,TestType,Consent,Setting,Approach,HtsRiskCategory,HtsRiskScore,PatientPKHash);
		


		--WHEN NOT MATCHED BY SOURCE 
		--	THEN
		--		/* The Record is in the target table but doen't exit on the source table*/
		--	Delete;
		--	with cte AS (
		--	Select
		--	PatientPK,
		--	Sitecode,
		--	DateExtracted,

		--	 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,DateExtracted ORDER BY
		--	PatientPK,Sitecode,DateExtracted) Row_Num
		--	FROM [ODS].[dbo].[HTS_ClientTests](NoLock)
		--	)
		--delete from cte 
		--	Where Row_Num >1 ;


		
END