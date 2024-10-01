WITH cte AS(
	SELECT [Sitecode],Count(1)NullPatientPK_IDHash
	FROM [ODS].[dbo].[CT_CancerScreening]
	WHERE PatientPKHash IS NULL OR PatientIDHash IS NULL AND [Voided] = 0
	GROUP BY [SiteCode]
	HAVING Count(1) > 1
)
SELECT COUNT(*) FROM cte
