with cte AS (
						Select
						PatientPK,
						Sitecode,
						visitID,
						visitDate,voided,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,voided,visitDate ORDER BY
						PatientPK,Sitecode,visitID,visitDate) Row_Num
						FROM [ODS].[dbo].[CT_Otz](NoLock)
						)
					delete from cte 
						Where Row_Num >1 ;