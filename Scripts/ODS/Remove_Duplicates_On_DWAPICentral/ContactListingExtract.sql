	with cte AS (
	Select
	PatientId,
	FacilityName,
	Contactage,
	RelationshipWithPatient,

	 ROW_NUMBER() OVER (PARTITION BY PatientId,FacilityName,Contactage,RelationshipWithPatient ORDER BY
	PatientId,FacilityName,Contactage,RelationshipWithPatient) Row_Num
	FROM [DWAPICentral].[dbo].[ContactListingExtract](NoLock)
	)
delete  from cte 
	Where Row_Num >1