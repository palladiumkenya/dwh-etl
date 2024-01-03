	with cte AS (
						Select
						PatientPK,
						Sitecode,
						visitID,
						visitDate,voided,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,voided,visitDate ORDER BY
						visitDate desc) Row_Num
						FROM [ODS].[dbo].[CT_DrugAlcoholScreening](NoLock)
						)
					delete from cte 
						Where Row_Num >1 ;