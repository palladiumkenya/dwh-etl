with cte AS (
						Select
						Sitecode,
						PatientPK,
						Contactage,
						RelationshipWithPatient,voided,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,Contactage,voided,RelationshipWithPatient ORDER BY
						PatientPK,Sitecode,Contactage,RelationshipWithPatient) Row_Num
						FROM [ODS].[dbo].[CT_ContactListing](NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;