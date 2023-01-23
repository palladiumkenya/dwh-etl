with cte AS (
	Select
	P.PatientPID,
	P.[FacilityId],
	
	 ROW_NUMBER() OVER (PARTITION BY P.PatientPID,P.[FacilityId] ORDER BY
	P.PatientPID,P.[FacilityId]) Row_Num
FROM [DWAPICentral].[dbo].[PatientExtract]  P  with (NoLock)
												
						WHERE P.Voided=0 and P.[Gender] is NOT NULL and p.gender!='Unknown'
	)
	--select * from cte
	--where Row_Num =1

	delete from cte
	where Row_Num >1