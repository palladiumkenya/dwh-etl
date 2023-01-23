	with cte AS (
	Select
	PatientId,
	ExitDate,

	 ROW_NUMBER() OVER (PARTITION BY PatientId,ExitDate ORDER BY
	PatientId,ExitDate) Row_Num
	FROM [DWAPICentral].[dbo].[PatientStatusExtract]PS WITH (NoLock)
	)
delete  from cte 
	Where Row_Num >1