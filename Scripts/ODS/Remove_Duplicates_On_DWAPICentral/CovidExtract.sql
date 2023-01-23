	with cte AS (
	Select
	PatientId,
	Covid19AssessmentDate,
	VisitID,
	 ROW_NUMBER() OVER (PARTITION BY PatientId,Covid19AssessmentDate,VisitID ORDER BY
	PatientId,Covid19AssessmentDate,VisitID) Row_Num
	FROM [DWAPICentral].[dbo].[CovidExtract](NoLock)
	)
delete  from cte 
	Where Row_Num >1