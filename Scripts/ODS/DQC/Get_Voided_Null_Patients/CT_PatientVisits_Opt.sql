WITH cte AS (
  SELECT [SiteCode],Count(1)NullPatientPK_IDHash
	FROM [ODS].[dbo].[CT_PatientVisits_Opt]
	WHERE PatientPKHash IS NULL OR PatientIDHash IS NULL AND [voided] = 0
	GROUP BY [SiteCode]
	HAVING Count(1) > 1
)
SELECT COUNT(*) FROM cte
