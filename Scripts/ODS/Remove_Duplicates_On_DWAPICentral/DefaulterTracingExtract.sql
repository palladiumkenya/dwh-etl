	with cte AS (
	Select
	PatientId,
	VisitID,
	FacilityName,
	 ROW_NUMBER() OVER (PARTITION BY PatientId,VisitID,FacilityName ORDER BY
	PatientId,VisitID,FacilityName) Row_Num
	From [DWAPICentral].[dbo].[DefaulterTracingExtract](NoLock)
	)
delete from cte 
	Where Row_Num >1