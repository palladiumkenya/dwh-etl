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
	 
	)
	WHEN NOT MATCHED THEN 
		INSERT(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,EncounterId,TestKitName1,TestKitLotNumber1,TestKitExpiry1,TestResult1,TestKitName2,TestKitLotNumber2,TestKitExpiry2,TestResult2) 
		VALUES(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,EncounterId,TestKitName1,TestKitLotNumber1,TestKitExpiry1,TestResult1,TestKitName2,TestKitLotNumber2,TestKitExpiry2,TestResult2)
	WHEN MATCHED THEN
		UPDATE SET 
			
			a.[TestKitName1]		=b.[TestKitName1],
			a.[TestKitLotNumber1]	=b.[TestKitLotNumber1],
			a.[TestKitExpiry1]		=b.[TestKitExpiry1],
			a.[TestResult1]			=b.[TestResult1],
			a.[TestKitName2]		=b.[TestKitName2],
			a.[TestKitLotNumber2]	=b.[TestKitLotNumber2],
			a.[TestKitExpiry2]		=b.[TestKitExpiry2],
			a.[TestResult2]			=b.[TestResult2];
END