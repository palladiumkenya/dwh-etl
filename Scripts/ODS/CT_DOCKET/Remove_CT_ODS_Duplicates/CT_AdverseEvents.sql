with cte AS (
						Select
						Sitecode,
						PatientPK,
						VisitDate,voided,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,,voided,VisitDate ORDER BY
						PatientPK,Sitecode,VisitDate) Row_Num
						FROM  [ODS].[dbo].[CT_AdverseEvents](NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;