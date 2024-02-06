BEGIN
		IF  EXISTS(SELECT * FROM sys.columns  
           WHERE Name = N'PatientPK' 
             AND Object_ID = Object_ID(N'[ODS].[dbo].[Ushauri_Patient]'))
			 BEGIN
					EXEC sp_rename '[ODS].[dbo].[Ushauri_Patient].PatientPK', 'UshauriPatientPK', 'COLUMN';
			 END

		IF  EXISTS(SELECT * FROM sys.columns  
           WHERE Name = N'PatientPKHash' 
             AND Object_ID = Object_ID(N'[ODS].[dbo].[Ushauri_Patient]'))
			 BEGIN
					EXEC sp_rename '[ODS].[dbo].[Ushauri_Patient].PatientPKHash', 'UshauriPatientPKHash', 'COLUMN';
			 END
		
		IF NOT EXISTS (
			  SELECT
				*
			  FROM
				INFORMATION_SCHEMA.COLUMNS
			  WHERE
				TABLE_NAME = 'Ushauri_Patient' AND COLUMN_NAME = 'patientPK')
			BEGIN
			  ALTER TABLE [ODS].[dbo].[Ushauri_Patient]
				ADD patientPK int NULL
			END;

		IF NOT EXISTS (
			  SELECT
				*
			  FROM
				INFORMATION_SCHEMA.COLUMNS
			  WHERE
				TABLE_NAME = 'Ushauri_Patient' AND COLUMN_NAME = 'PatientPKHash')
			BEGIN
			  alter table [ODS].[dbo].[Ushauri_Patient]
					add PatientPKHash nvarchar(150) null
			END;

END