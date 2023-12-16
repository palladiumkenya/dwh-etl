with cte AS (
						Select
						PatientPK,
						Sitecode,
						OrderedbyDate,
						TestResult,
						TestName,voided,
						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,OrderedbyDate,voided,TestResult,TestName ORDER BY
						OrderedbyDate) Row_Num
						FROM [ODS].[dbo].[CT_PatientLabs](NoLock)
						)
					DELETE from cte 
						Where Row_Num >1 ;