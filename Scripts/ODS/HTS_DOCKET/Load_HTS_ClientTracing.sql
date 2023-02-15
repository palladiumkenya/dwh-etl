
BEGIN
	
		ALTER TABLE [HTSCentral].[dbo].[HtsClientTracing]	ALTER COLUMN [TracingDate] nvarchar(4000) COLLATE Latin1_General_CI_AS;
		--ALTER TABLE [HTSCentral].[dbo].[HtsClientTracing]			ALTER COLUMN HtsNumber		nvarchar(4000) COLLATE Latin1_General_CI_AS;
		--ALTER TABLE [HTSCentral].[dbo].HtsClientTests ALTER COLUMN [EverTestedForHiv] nvarchar(4000) COLLATE Latin1_General_CI_AS;
		--ALTER TABLE [HTSCentral].[dbo].HtsClientTests ALTER COLUMN [TestResult1] nvarchar(4000) COLLATE Latin1_General_CI_AS;
		--ALTER TABLE [HTSCentral].[dbo].HtsClientTests ALTER COLUMN [TestResult2] nvarchar(4000) COLLATE Latin1_General_CI_AS;
	
		--Truncate table [ODS].[dbo].[HTS_ClientTracing]
		MERGE [ODS].[dbo].[HTS_ClientTracing] AS a
			USING(SELECT DISTINCT  a.[FacilityName]
				  ,a.[SiteCode]
				  ,a.[PatientPk]
				  ,a.[HtsNumber]
				  ,a.[Emr]
				  ,a.[Project]     
				  ,[TracingType]
				  ,[TracingDate]
				  ,[TracingOutcome],
					convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[PatientPk]  as nvarchar(36))), 2) PatientPKHash,
				convert(nvarchar(64), hashbytes('SHA2_256', cast(a.HtsNumber  as nvarchar(36))), 2)HtsNumberHash,
				convert(nvarchar(64), hashbytes('SHA2_256', cast(LTRIM(RTRIM(a.PatientPk)) +'-'+LTRIM(RTRIM(a.HtsNumber)) as nvarchar(100))), 2)as CKVHash
			  FROM [HTSCentral].[dbo].[HtsClientTracing] (NoLock)a
				INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
			  on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode
			  where a.TracingType is not null and a.TracingOutcome is not null
			  ) AS b 
			ON(
				a.PatientPK  = b.PatientPK 
			and a.SiteCode = b.SiteCode	
			and a.[TracingDate] = b.[TracingDate]
			and a.HtsNumber COLLATE Latin1_General_CI_AS = b.HtsNumber
			and a.TracingType COLLATE Latin1_General_CI_AS = b.TracingType
			and a.TracingOutcome COLLATE Latin1_General_CI_AS = b.TracingOutcome
			and a.FacilityName COLLATE Latin1_General_CI_AS = b.FacilityName
			)
	WHEN NOT MATCHED THEN 
		INSERT(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,TracingType,TracingDate,TracingOutcome,PatientPKHash,HtsNumberHash,CKVHash) 
		VALUES(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,TracingType,TracingDate,TracingOutcome,PatientPKHash,HtsNumberHash,CKVHash)

	WHEN MATCHED THEN
		UPDATE SET 
				a.[FacilityName]	=b.[FacilityName],
				a.[HtsNumber]		=b.[HtsNumber],
				a.[Emr]				=b.[Emr],
				a.[Project]			=b.[Project],
				a.[TracingType]		=b.[TracingType],
				a.[TracingDate]		=b.[TracingDate],
				a.[TracingOutcome]	=b.[TracingOutcome]

				WHEN NOT MATCHED BY SOURCE 
			THEN
				/* The Record is in the target table but doen't exit on the source table*/
			Delete;
END

