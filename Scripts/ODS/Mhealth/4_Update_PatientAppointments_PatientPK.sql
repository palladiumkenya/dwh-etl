UPDATE a
    SET a.PatientPK = null,a.PatientPKHash =null
FROM [ODS].[dbo].[Ushauri_PatientAppointments]  a;

UPDATE a
    SET a.PatientPK = p.PatientPK
FROM [ODS].[dbo].[Ushauri_PatientAppointments] a
    JOIN [ODS].[dbo].[CT_Patient] p
ON  a.sitecode = p.sitecode AND a.patientID = p.patientID;


