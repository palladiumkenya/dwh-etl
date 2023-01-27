ALTER TABLE HtsClientTests NOCHECK CONSTRAINT ALL;
	with cte AS (
	Select
	a.PatientPK,
	a.Sitecode,
	DateExtracted,

	 ROW_NUMBER() OVER (PARTITION BY a.PatientPK,a.Sitecode,a.DateExtracted ORDER BY
	a.PatientPK,a.Sitecode,a.DateExtracted) Row_Num
	FROM [HTSCentral].[dbo].[HtsClientTests](NoLock) a
					  INNER JOIN (
								SELECT SiteCode,PatientPK, MAX(DateExtracted) AS MaxDateExtracted
								FROM  [HTSCentral].[dbo].[HtsClientTests](NoLock)
								GROUP BY SiteCode,PatientPK
							) tm 
				ON a.[SiteCode] = tm.[SiteCode] and a.PatientPK=tm.PatientPK and a.DateExtracted = tm.MaxDateExtracted
				INNER JOIN (
								SELECT SiteCode,PatientPK, MAX(DateExtracted) AS MaxDateExtracted
								FROM  [HTSCentral].[dbo].Clients(NoLock)
								GROUP BY SiteCode,PatientPK
							) tn 
				ON a.[SiteCode] = tn.[SiteCode] and a.PatientPK=tn.PatientPK --and a.DateExtracted = tn.MaxDateExtracted
				where a.FinalTestResult is not null
	)
delete from cte 
	Where Row_Num >1 

	ALTER TABLE HtsClientTests WITH CHECK CHECK CONSTRAINT ALL;
