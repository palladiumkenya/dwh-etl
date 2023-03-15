IF OBJECT_ID(N'[REPORTING].[dbo].[Linelist_FACTART_Palantir]', N'U') IS NOT NULL 
	DROP TABLE [REPORTING].[dbo].[Linelist_FACTART_Palantir];
BEGIN
		-- create table statement
		CREATE TABLE [REPORTING].[dbo].[Linelist_FACTART_Palantir](
																	[PatientIDHash] [nvarchar](100) NULL,
																	[PatientPKHash] [nvarchar](100) NULL,	
																	[SiteCode] [int] NULL,
																	Gender  nvarchar(20),
																	UniquePatientIDGuid  nvarchar(150)
																   ) 

		INSERT INTO [REPORTING].[dbo].[Linelist_FACTART_Palantir]([PatientIDHash],[PatientPKHash],[SiteCode],Gender,UniquePatientIDGuid)
		SELECT 
			a.PatientIDHash,
			a.PatientPKHash,
			a.SiteCode,
			a.Gender,
			b.Id as UniquePatientIDGuid
		FROM Linelist_FACTART a
		LEFT JOIN [ODS].[DBO].CT_Patient b
		ON a.SiteCode = b.SiteCode and a.PatientPKHash = b.PatientPKHash
		WHERE county in ('Bomet',' Uasin Gishu', 'Siaya') and ARTOutcome='V'

END


