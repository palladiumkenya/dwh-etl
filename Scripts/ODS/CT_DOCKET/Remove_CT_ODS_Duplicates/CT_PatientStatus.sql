with cte AS (
									Select
									PatientPK,
									SiteCode,
									ExitDate,
									ExitReason,
									Lastvisit,

									 ROW_NUMBER() OVER (PARTITION BY PatientPK,ExitDate,SiteCode,ExitReason,Lastvisit ORDER BY
									ExitDate desc) Row_Num
									FROM [ODS].[dbo].[CT_PatientStatus]PS WITH (NoLock)
									)
								delete  from cte 
									Where Row_Num >1