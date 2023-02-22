--	with cte AS (
--	Select
--	PatientId,

--	 ROW_NUMBER() OVER (PARTITION BY PatientId ORDER BY
--	PatientId,ID) Row_Num
--	FROM [DWAPICentral].[dbo].[PatientBaselinesExtract](NoLock)
--	)
--delete from cte 
--	Where Row_Num >1


	with cte AS (
	Select
	a.PatientId,
	a.Created,

	 ROW_NUMBER() OVER (PARTITION BY a.PatientId,a.Created ORDER BY
	a.PatientId,a.Created) Row_Num
	FROM [DWAPICentral].[dbo].[PatientBaselinesExtract] a with (NoLock)
	INNER JOIN ( SELECT PatientId,MAX(Created)MaxCreated FROM [DWAPICentral].[dbo].[PatientBaselinesExtract](NoLock)
					GROUP BY PatientId
				)tn
				on a.PatientId = tn.PatientId and a.Created = tn.MaxCreated
	)
delete from cte 
	Where Row_Num >1;