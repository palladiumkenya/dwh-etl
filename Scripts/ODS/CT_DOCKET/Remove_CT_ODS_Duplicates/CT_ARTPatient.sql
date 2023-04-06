	with cte AS (
				Select
				PatientPK,
				sitecode,
				lastvisit,
				 ROW_NUMBER() OVER (PARTITION BY PatientPK,sitecode,lastvisit ORDER BY
				PatientPK,sitecode,lastvisit desc) Row_Num
				FROM [ODS].[dbo].[CT_ARTPatients](NoLock)
				)
			delete from cte 
				Where Row_Num >1;