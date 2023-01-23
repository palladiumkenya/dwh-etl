	with cte AS (
	Select
	PP.PatientId,
	DispenseDate,
	Drug,
	TreatmentType,
	 ROW_NUMBER() OVER (PARTITION BY PP.PatientId,DispenseDate,Drug,TreatmentType ORDER BY
	PP.PatientId,DispenseDate,Drug,TreatmentType ) Row_Num
	FROM  [DWAPICentral].[dbo].[PatientPharmacyExtract](Nolock) PP
	
	)
	delete from cte 
	Where Row_Num >1