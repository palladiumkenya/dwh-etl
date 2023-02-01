BEGIN
	MERGE [ODS].[dbo].[HTS_TestKits] AS a
	USING(SELECT DISTINCT a.[FacilityName]
		  ,a.[SiteCode]
		  ,a.[PatientPk]
		  ,a.[HtsNumber]
		  ,a.[Emr]
		  ,a.[Project]
		  ,a.[EncounterId]
		  ,a.[TestKitName1]
		  ,a.[TestKitLotNumber1]
		  ,a.[TestKitExpiry1]
		  ,a.[TestResult1]
		  ,a.[TestKitName2]
		  ,a.[TestKitLotNumber2]
		  ,[TestKitExpiry2]
		  ,[TestResult2]
	  FROM [HTSCentral].[dbo].[HtsTestKits](NoLock) a
	  INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
	  on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode) AS b 
	ON(
		a.PatientPK  = b.PatientPK 
	and a.SiteCode = b.SiteCode	
	
	and a.EncounterId  = b.EncounterId 
	and a.HtsNumber COLLATE Latin1_General_CI_AS = b.HtsNumber 
	and a.TestKitExpiry1 COLLATE Latin1_General_CI_AS = b.TestKitExpiry1 
	and a.TestKitExpiry2 COLLATE Latin1_General_CI_AS = b.TestKitExpiry2 
	and a.FacilityName COLLATE Latin1_General_CI_AS = b.FacilityName 
	and a.TestKitName1 COLLATE Latin1_General_CI_AS = b.TestKitName1 
	and a.TestKitName2 COLLATE Latin1_General_CI_AS = b.TestKitName2 
	and a.TestKitLotNumber1 COLLATE Latin1_General_CI_AS = b.TestKitLotNumber1 
	and a.TestKitLotNumber2 COLLATE Latin1_General_CI_AS = b.TestKitLotNumber2 
	and a.TestResult1 COLLATE Latin1_General_CI_AS = b.TestResult1 
	and a.TestResult2 COLLATE Latin1_General_CI_AS = b.TestResult2 
	and a.Project COLLATE Latin1_General_CI_AS = b.Project 
	)
	WHEN NOT MATCHED THEN 
		INSERT(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,EncounterId,TestKitName1,TestKitLotNumber1,TestKitExpiry1,TestResult1,TestKitName2,TestKitLotNumber2,TestKitExpiry2,TestResult2) 
		VALUES(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,EncounterId,TestKitName1,TestKitLotNumber1,TestKitExpiry1,TestResult1,TestKitName2,TestKitLotNumber2,TestKitExpiry2,TestResult2)
	WHEN MATCHED THEN
		UPDATE SET 
			a.[HtsNumber]			=b.[HtsNumber],
			a.[Emr]					=b.[Emr],
			a.[Project]				=b.[Project],
			a.[EncounterId]			=b.[EncounterId],
			a.[TestKitName1]		=b.[TestKitName1],
			a.[TestKitLotNumber1]	=b.[TestKitLotNumber1],
			a.[TestKitExpiry1]		=b.[TestKitExpiry1],
			a.[TestResult1]			=b.[TestResult1],
			a.[TestKitName2]		=b.[TestKitName2],
			a.[TestKitLotNumber2]	=b.[TestKitLotNumber2],
			a.[TestKitExpiry2]		=b.[TestKitExpiry2],
			a.[TestResult2]			=b.[TestResult2]

	WHEN NOT MATCHED BY SOURCE 
			THEN
				/* The Record is in the target table but doen't exit on the source table*/
			Delete;
END
