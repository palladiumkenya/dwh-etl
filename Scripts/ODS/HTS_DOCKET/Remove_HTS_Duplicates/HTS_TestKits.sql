with cte AS ( Select           
		a.[PatientPk],           
		a.[SiteCode],            
		a.EncounterId,
		[TestKitName1],
		[TestResult2],
		[TestKitLotNumber1],ROW_NUMBER() OVER (PARTITION BY a.[PatientPk],a.[SiteCode],a.EncounterId,[TestKitName1],[TestResult2],[TestKitLotNumber1]
		ORDER BY a.[PatientPk],a.[SiteCode] desc) Row_Num
        FROM [ODS].[dbo].[HTS_TestKits]a)

delete from cte where Row_Num>1 