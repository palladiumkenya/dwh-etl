BEGIN
		MERGE [ODS].[dbo].[HTS_ClientTracing] AS a
			USING(SELECT DISTINCT top 2 a.[FacilityName]
				  ,a.[SiteCode]
				  ,a.[PatientPk]
				  ,a.[HtsNumber]
				  ,a.[Emr]
				  ,a.[Project]     
				  ,[TracingType]
				  ,[TracingDate]
				  ,[TracingOutcome]
			  FROM [HTSCentral].[dbo].[HtsClientTracing] (NoLock)a
				INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
			  on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode
			  ) AS b 
			ON(
				a.PatientPK  = b.PatientPK 
			and a.SiteCode = b.SiteCode						
			)
	WHEN NOT MATCHED THEN 
		INSERT(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,TracingType,TracingDate,TracingOutcome) 
		VALUES(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,TracingType,TracingDate,TracingOutcome)

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
