	with cte AS (
	Select
	PatientId,
	VisitDate,
	AdverseEventRegimen,
	 ROW_NUMBER() OVER (PARTITION BY PatientId,VisitDate,AdverseEventRegimen ORDER BY
	PatientId,VisitDate,AdverseEventRegimen ) Row_Num
	FROM [DWAPICentral].[dbo].PatientAdverseEventExtract(NoLock)
	)
delete  from cte 
	Where Row_Num >1