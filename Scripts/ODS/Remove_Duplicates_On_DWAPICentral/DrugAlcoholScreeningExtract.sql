	with cte AS (
	Select
	PatientID,
	VisitID,
	VisitDate,
	FacilityName,
	 ROW_NUMBER() OVER (PARTITION BY PatientID,VisitID,VisitDate,FacilityName ORDER BY
	PatientID,VisitID,VisitDate,FacilityName ) Row_Num
	FROM [DWAPICentral].[dbo].[DrugAlcoholScreeningExtract](NoLock)
	)
delete from cte 
	Where Row_Num >1