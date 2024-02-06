UPDATE a
    SET a.PatientPK = null,a.PatientPKHash =null
FROM [ODS].[dbo].[Ushauri_Patient] a;

UPDATE a
    SET a.PatientPK = p.PatientPK
FROM [ODS].[dbo].[Ushauri_Patient] a
    JOIN [ODS].[dbo].[CT_Patient] p
ON  a.sitecode = p.sitecode AND a.patientID = p.patientID;


UPDATE a
    SET a.PatientPK = a.UshauriPatientPK
FROM [ODS].[dbo].[Ushauri_Patient] a
WHERE a.PatientPK IS NULL;

UPDATE a
	SET PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2)
FROM [ODS].[dbo].[Ushauri_Patient] a
WHERE PatientPKHash IS NULL;


UPDATE a
	SET  UshauriPatientPKHash =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[UshauriPatientPk]  as nvarchar(36))), 2),
		 PatientIDHash  =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.PatientID  as nvarchar(36))), 2) ,
		 NUPIHash  =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[NUPI]  as nvarchar(36))), 2) 
FROM [ODS].[dbo].[Ushauri_Patient] a