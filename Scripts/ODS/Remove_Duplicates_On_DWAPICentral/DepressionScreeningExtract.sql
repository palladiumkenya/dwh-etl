	with cte AS (
	Select
	PatientId,
	VisitID
	,VisitDate,
	 ROW_NUMBER() OVER (PARTITION BY PatientId,VisitID,VisitDate ORDER BY
	PatientId,VisitID,VisitDate) Row_Num
	From [DWAPICentral].[dbo].[DepressionScreeningExtract](NoLock)
	)
delete  from cte 
	Where Row_Num >1