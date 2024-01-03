	with cte AS (
				Select
				PatientPK,
				sitecode,
				lastvisit,voided,
				 ROW_NUMBER() OVER (PARTITION BY PatientPK,sitecode,voided,lastvisit ORDER BY
				PatientPK,sitecode,lastvisit desc) Row_Num
				FROM [ODS].[dbo].[CT_ARTPatients](NoLock)
				)
			delete from cte 
				Where Row_Num >1;