with cte AS (
						Select
						PatientPK,
						Sitecode,
						visitID,
						VisitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,VisitDate ORDER BY
						PatientPK,Sitecode,visitID,VisitDate) Row_Num
						FROM [ODS].[dbo].[CT_Ipt](NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;