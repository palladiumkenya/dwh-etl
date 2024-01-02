with cte AS (
									Select
									PatientPK,
									SiteCode,
									ExitDate,voided,

									 ROW_NUMBER() OVER (PARTITION BY SiteCode,PatientPK,voided,ExitDate ORDER BY
									EffectiveDiscontinuationDate,ReEnrollmentDate desc) Row_Num
									FROM [ODS].[dbo].[CT_PatientStatus]PS WITH (NoLock)
									)
								delete  from cte 
									Where Row_Num >1