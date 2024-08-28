/* Renaming patientPK column coming from mhealth to UshauriPatientPK for the purpose of matching patient from C&T to  ones coming from ushauri. */
BEGIN


		IF EXISTS (SELECT * FROM sys.columns      /* 1st if confirms if the PatientPK column exists on [ODS].[dbo].[Mhealth_Ushauri_Patient] exists on ODS   */
					WHERE Name = N'PatientPK'
					AND Object_ID = Object_ID(N'[ODS].[dbo].[Mhealth_Ushauri_Patient]'))
		BEGIN
			  IF  NOT EXISTS (SELECT *					/* If above condition is met, check if Ushauri_Patient exists. If it exists escape. If it doesn't exist create it*/
							 FROM   INFORMATION_SCHEMA.COLUMNS
							 WHERE  TABLE_NAME = 'Mhealth_Ushauri_Patient'
							 AND COLUMN_NAME = 'UshauriPatientPK')

					BEGIN
						EXEC sp_rename '[ODS].[dbo].[Mhealth_Ushauri_Patient].PatientPK', 'UshauriPatientPK', 'COLUMN';
					END

		END

		IF EXISTS (SELECT * FROM sys.columns      /* 1st if confirms if the PatientPK column exists on [ODS].[dbo].[Mhealth_Ushauri_Patient] exists on ODS   */
				WHERE Name = N'PatientPKHash'
				AND Object_ID = Object_ID(N'[ODS].[dbo].[Mhealth_Ushauri_Patient]'))
		BEGIN
			  IF  NOT EXISTS (SELECT *					/* If above condition is met, check if Ushauri_Patient exists. If it exists escape. If it doesn't exist create it*/
							FROM   INFORMATION_SCHEMA.COLUMNS
							WHERE  TABLE_NAME = 'Mhealth_Ushauri_Patient'
							AND COLUMN_NAME = 'PatientPKHash')

					BEGIN
						EXEC sp_rename '[ODS].[dbo].[Mhealth_Ushauri_Patient].PatientPKHash', 'PatientPKHash', 'COLUMN';
					END

		END

		IF NOT EXISTS (
			  SELECT
				*
			  FROM
				INFORMATION_SCHEMA.COLUMNS
			  WHERE
				TABLE_NAME = 'Mhealth_Ushauri_Patient' AND COLUMN_NAME = 'patientPK')
			BEGIN
			  ALTER TABLE [ODS].[dbo].[Mhealth_Ushauri_Patient]
				ADD patientPK int NULL
			END;

		IF NOT EXISTS (
			  SELECT
				*
			  FROM
				INFORMATION_SCHEMA.COLUMNS
			  WHERE
				TABLE_NAME = 'Mhealth_Ushauri_Patient' AND COLUMN_NAME = 'PatientPKHash')
			BEGIN
			  alter table [ODS].[dbo].[Mhealth_Ushauri_Patient]
					add PatientPKHash nvarchar(150) null
			END;

		IF NOT EXISTS (
			  SELECT
				*
			  FROM
				INFORMATION_SCHEMA.COLUMNS
			  WHERE
				TABLE_NAME = 'Mhealth_Ushauri_Patient' AND COLUMN_NAME = 'UshauriPatientPKHash')
			BEGIN
			  alter table [ODS].[dbo].[Mhealth_Ushauri_Patient]
					add UshauriPatientPKHash nvarchar(150) null
			END;

END
