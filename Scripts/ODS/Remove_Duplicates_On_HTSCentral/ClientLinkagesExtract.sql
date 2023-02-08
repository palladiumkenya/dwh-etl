	with cte AS (
	Select
	PatientPK,
	Sitecode,
	DateExtracted,

	 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,DateExtracted ORDER BY
	PatientPK,Sitecode,DateExtracted) Row_Num
	FROM [HTSCentral].[dbo].[ClientLinkages](NoLock)
	)
delete from cte 
	Where Row_Num >1 


		