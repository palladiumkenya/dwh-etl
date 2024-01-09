with cte AS (
				Select
				PatientPK,
				sitecode,id,

				 ROW_NUMBER() OVER (PARTITION BY PatientPK,sitecode,id ORDER BY
				PatientPK,sitecode) Row_Num
				FROM [ODS].[DBO].CT_PatientBaselines(NoLock)
				)
			delete  from cte 
				Where Row_Num >1;