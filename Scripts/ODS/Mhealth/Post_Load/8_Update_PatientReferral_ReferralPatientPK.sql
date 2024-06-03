/* Update of the ReferralpatientPK from the C&T patients.This are for the patients who are in ushauri and have been
registered in the EMR. Indentified using the patientCCCNumber */

UPDATE a
    SET a.ReferralpatientPK = p.PatientPK
FROM [ODS].[dbo].[Ushauri_PatientReferral] a
    JOIN [ODS].[dbo].[CT_Patient] p
ON  a.PatientID = p.PatientID;
