UPDATE a
	SET a.voided = 1, a.VoidingSource = 1
FROM [ODS].[dbo].[CT_AllergiesChronicIllness] a
JOIN [ODS].[dbo].[CT_Patient] b ON a.SiteCode = b.SiteCode AND a.PatientPK = b.PatientPK
WHERE b.voided = 1;
