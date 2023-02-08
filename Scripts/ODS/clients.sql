with cte AS (
	SELECT  
		a.PatientPK
		,a.SiteCode
		,DateCreated,
	ROW_NUMBER() OVER (PARTITION BY a.PatientPK,a.Sitecode,a.DateCreated ORDER BY
	a.PatientPK,a.Sitecode,a.DateCreated) Row_Num
	FROM [HTSCentral].[dbo].[Clients](NoLock) a
		INNER JOIN (
					SELECT SiteCode,PatientPK, MAX(datecreated) AS Maxdatecreated
					FROM  [HTSCentral].[dbo].[Clients](NoLock)
					GROUP BY SiteCode,PatientPK
								) tm 
					ON a.[SiteCode] = tm.[SiteCode] and a.PatientPK=tm.PatientPK and a.datecreated = tm.Maxdatecreated
					 WHERE a.DateExtracted > '2019-09-08')
delete from cte 
	Where Row_Num >1 