	with cte AS (
	Select
	PatientId,
	ID,

	 ROW_NUMBER() OVER (PARTITION BY PatientId,ID ORDER BY
	PatientId,ID) Row_Num
	FROM [DWAPICentral].[dbo].[PatientBaselinesExtract](NoLock)
	)
delete from cte 
	Where Row_Num >1