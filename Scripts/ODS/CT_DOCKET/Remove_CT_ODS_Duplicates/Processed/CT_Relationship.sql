with cte AS (
						Select
						PatientPK,
						Sitecode,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,voided ORDER BY
						PatientPK,Sitecode desc) Row_Num
						FROM ODS.dbo.CT_Relationships(NoLock)
						)
					Delete from cte 
						Where Row_Num >1 ;