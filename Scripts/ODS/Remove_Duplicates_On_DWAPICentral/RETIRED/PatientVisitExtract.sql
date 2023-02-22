	with cte AS (
	Select
	PatientID,
	visitID,
	VisitDate,
	
	 ROW_NUMBER() OVER (PARTITION BY PatientID,visitID,VisitDate ORDER BY
	 PatientID,visitID,VisitDate ) Row_Num
						FROM [DWAPICentral].[dbo].[PatientVisitExtract] WITH (NoLock)  
	)
delete from cte  
	Where Row_Num >1