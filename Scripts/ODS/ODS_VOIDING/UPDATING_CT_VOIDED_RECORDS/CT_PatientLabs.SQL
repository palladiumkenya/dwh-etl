UPDATE a
	SET a.voided =1
FROM [ODS].[dbo].[CT_PatientLabs] a
	JOIN [ODS].[dbo].[CT_Patient] b ON	a.SiteCode = b.SiteCode AND a.PatientPK = b.PatientPK
WHERE b.voided =1 ;