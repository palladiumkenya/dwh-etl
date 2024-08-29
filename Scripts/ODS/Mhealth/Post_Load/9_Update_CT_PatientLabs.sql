-- Update PatientPK with the one from ODS CT_Patients
UPDATE a
SET
    a.PatientPK = NULL,
    a.PatientPKHash = NULL
FROM
    [ODS].[dbo].[Mhealth_mLab_PatientLab] a;

UPDATE a
SET
    a.PatientPK = p.PatientPK
FROM
    [ODS].[dbo].[Mhealth_mLab_PatientLab] a
	JOIN [ODS].[dbo].[CT_Patient] p
		ON a.PatientID = p.PatientID;
