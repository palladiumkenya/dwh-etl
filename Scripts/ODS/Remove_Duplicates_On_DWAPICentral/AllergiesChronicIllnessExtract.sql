	with cte AS (
	Select
	PatientId,
	VisitDate,VisitID,

	 ROW_NUMBER() OVER (PARTITION BY PatientId,VisitDate,VisitID ORDER BY
	PatientId,VisitDate,VisitID) Row_Num
	FROM [DWAPICentral].[dbo].[AllergiesChronicIllnessExtract](NoLock)
	)
delete  from cte 
	Where Row_Num >1 