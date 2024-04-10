---Ushauri_PatientAppointments
UPDATE a
	SET PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2)
FROM [ODS].[dbo].[Ushauri_PatientAppointments] a
WHERE PatientPKHash IS NULL;

UPDATE a
	SET  UshauriPatientPKHash =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[UshauriPatientPk]  as nvarchar(36))), 2),
		 PatientIDHash  =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.PatientID  as nvarchar(36))), 2) ,
		 NUPIHash  =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[NUPI]  as nvarchar(36))), 2) 
FROM [ODS].[dbo].[Ushauri_PatientAppointments] a

----End 
---Ushauri_Patient
UPDATE a
	SET PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2)
FROM [ODS].[dbo].[Ushauri_Patient] a
WHERE PatientPKHash IS NULL;


UPDATE a
	SET  UshauriPatientPKHash =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[UshauriPatientPk]  as nvarchar(36))), 2),
		 PatientIDHash  =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.PatientID  as nvarchar(36))), 2) ,
		 NUPIHash  =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[NUPI]  as nvarchar(36))), 2) 
FROM [ODS].[dbo].[Ushauri_Patient] a

--Ushauri_Heis

UPDATE a
	SET  UshauriPatientPKHash =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[UshauriPatientPk]  as nvarchar(36))), 2)
FROM [ODS].[dbo].[Ushauri_HEI] a
WHERE PatientPKHash IS NULL;

UPDATE a
	SET  PatientPKHash =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[PatientPk]  as nvarchar(36))), 2)
FROM [ODS].[dbo].[Ushauri_HEI] a
WHERE PatientPKHash IS NULL;


----End