IF OBJECT_ID(N'[REPORTING].[dbo].[Linelist_FACTART_Palantir]', N'U') IS NOT NULL 
	DROP TABLE [REPORTING].[dbo].[Linelist_FACTART_Palantir];
BEGIN

	--update a
	--set  a.ID = p.ID 
	--from [ODS].[dbo].[CT_Patient] a
	--inner join [DWAPICentral].[dbo].[PatientExtract]  P  with (NoLock)
	--on a.PatientPK = p.PatientPID
	--					INNER JOIN [DWAPICentral].[dbo].[Facility] F with (NoLock)  
	--					ON P.[FacilityId]  = F.Id  AND  a.SiteCode = f.code and F.Voided=0 	
	--					INNER JOIN (SELECT P.PatientPID,F.code,Max(P.created)MaxCreated FROM [DWAPICentral].[dbo].[PatientExtract]  P  with (NoLock)
	--								INNER JOIN [DWAPICentral].[dbo].[Facility] F with (NoLock)  
	--								ON P.[FacilityId]  = F.Id  AND F.Voided=0 
	--								GROUP BY  P.PatientPID,F.code)tn
	--						on P.PatientPID = tn.PatientPID and F.code = tn.code and P.Created = tn.MaxCreated
	--					WHERE P.Voided=0 and P.[Gender] is NOT NULL and p.gender!='Unknown'
		-- create table statement
		CREATE TABLE [REPORTING].[dbo].[Linelist_FACTART_Palantir](
																	[PatientIDHash] [nvarchar](100) NULL,
																	[PatientPKHash] [nvarchar](100) NULL,	
																	[SiteCode] [int] NULL,
																	Gender  nvarchar(20),
																	UniquePatientIDGuidHash  nvarchar(150),

																   ) 

		INSERT INTO [REPORTING].[dbo].[Linelist_FACTART_Palantir]([PatientIDHash],[PatientPKHash],[SiteCode],Gender,UniquePatientIDGuidHash)
		SELECT 
			a.PatientIDHash,
			a.PatientPKHash,
			a.SiteCode,
			a.Gender,
			--convert(nvarchar(64), hashbytes('SHA2_256', cast(b.Id  as nvarchar(36))), 2) UniquePatientIDGuid
			CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', UPPER(CAST(b.id as NVARCHAR(36)))), 2) as PatientID
		FROM Linelist_FACTART a
		LEFT JOIN [ODS].[DBO].CT_Patient b
		ON a.SiteCode = b.SiteCode and a.PatientPKHash = b.PatientPKHash
		WHERE county in ('Bomet','Uasin Gishu', 'Siaya') and ARTOutcome='V'

END


