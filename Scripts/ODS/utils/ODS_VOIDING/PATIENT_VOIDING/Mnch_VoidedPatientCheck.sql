;WITH Src_PatientConcat
AS(
		SELECT  DISTINCT p.Sitecode,P.PatientPK,
				CONCAT(p.Sitecode,P.PatientPK) As PatientConcatColumn
		FROM [MNCHCentral].[dbo].[MnchPatients] P(nolock)
			inner join (select tn.PatientPK,tn.SiteCode,max(tn.DateExtracted)MaxDateExtracted FROM [MNCHCentral].[dbo].[MnchPatients] (NoLock)tn
						group by tn.PatientPK,tn.SiteCode)tm
							on P.PatientPk = tm.PatientPk and p.SiteCode = tm.SiteCode and p.DateExtracted = tm.MaxDateExtracted
		INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id
  ),
ODS_PatientConcat AS(
					SELECT SiteCode,PatientPK,
							CONCAT(SiteCode,PatientPK) AS ODSPatient
					FROM [ODS].[dbo].[Mnch_Patient]
)
	UPDATE [ODS].[dbo].[mnch_Patient]
		SET VOIDED =1
	FROM [ODS].[dbo].[mnch_Patient] a
	INNER JOIN ODS_PatientConcat b
		ON	a.SiteCode = b.SiteCode AND 
			a.PatientPK = b.PatientPK
	where b.ODSPatient NOT IN (SELECT PatientConcatColumn FROM Src_PatientConcat);

