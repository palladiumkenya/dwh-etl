with cte AS (
						Select
						PatientPK,
						Sitecode,
						visitID,
						OrderedbyDate,
						TestResult,
						TestName,
						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,OrderedbyDate,TestResult,TestName ORDER BY
						OrderedbyDate) Row_Num
						FROM [ODS].[dbo].[CT_PatientLabs](NoLock)
						)
					DELETE from cte 
						Where Row_Num >1 ;