with cte AS (
						Select
						PatientPK,
						sitecode,
						visitID,
						DispenseDate,
						drug,voided,
						 ROW_NUMBER() OVER (PARTITION BY PatientPK,sitecode,visitID,voided,DispenseDate,drug ORDER BY
						DispenseDate desc) Row_Num
						FROM [ODS].[dbo].[CT_PatientPharmacy](NoLock)
						)
					delete from cte 
						Where Row_Num >1;