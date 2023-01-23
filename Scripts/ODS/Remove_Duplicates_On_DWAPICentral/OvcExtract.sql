	with cte AS (
	Select
	PatientId,
	FacilityName,
	VisitID,VisitDate,
	 ROW_NUMBER() OVER (PARTITION BY PatientId,VisitID,VisitDate,FacilityName ORDER BY
	PatientId,VisitID,VisitDate,FacilityName ) Row_Num
	FROM [DWAPICentral].[dbo].[OvcExtract](NoLock)
	)
delete  from cte 
	Where Row_Num >1