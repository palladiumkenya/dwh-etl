;WITH Src_PatientConcat
AS(
		SELECT  DISTINCT F.Code,P.[PatientPID] as PatientPK,
				CONCAT(F.Code,P.[PatientPID]) As PatientConcatColumn
		FROM [DWAPICentral].[dbo].[PatientExtract]  P  with (NoLock)
			INNER JOIN [DWAPICentral].[dbo].[Facility] F with (NoLock)  
		ON P.[FacilityId]  = F.Id  AND F.Voided=0 							
		WHERE P.Voided=0 and P.[Gender] is NOT NULL and p.gender!='Unknown'
  ),
ODS_PatientConcat AS(
					SELECT SiteCode,PatientPK,
							CONCAT(SiteCode,PatientPK) AS ODSPatient
					FROM [ODS].[dbo].[CT_Patient]
)
	UPDATE [ODS].[dbo].[CT_Patient]
		SET VOIDED =1
	FROM [ODS].[dbo].[CT_Patient] a
	INNER JOIN ODS_PatientConcat b
		ON	a.SiteCode = b.SiteCode AND 
			a.PatientPK = b.PatientPK
	where b.ODSPatient NOT IN (SELECT PatientConcatColumn FROM Src_PatientConcat);