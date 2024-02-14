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

					INSERT INTO [ODS_logs].[dbo].[CT_IptCount_Log]([SiteCode],[CreatedDate],[IptCount])
					SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS IptCount 
					FROM [ODS].[dbo].[CT_Ipt] 
					GROUP BY SiteCode;