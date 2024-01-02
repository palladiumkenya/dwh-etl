with cte AS (
						Select
						Sitecode,
						PatientPK,
						visitID,
						VisitDate,voided,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,voided,VisitDate ORDER BY
						PatientPK,Sitecode,visitID,VisitDate) Row_Num
						FROM [ODS].[dbo].[CT_AllergiesChronicIllness](NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;