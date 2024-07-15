-- Update PatientPK with the one from ODS CT_Patients
UPDATE a
SET
    a.PatientPK = NULL,
    a.PatientPKHash = NULL
FROM
    [ODS].[dbo].[Ushauri_PatientLabs] a;

UPDATE a
SET
    a.PatientPK = p.PatientPK
FROM
    [ODS].[dbo].[Ushauri_PatientLabs] a
	JOIN [ODS].[dbo].[CT_PatientLabs] p
		ON a.SiteCode = p.SiteCode AND a.PatientID = p.PatientID;
