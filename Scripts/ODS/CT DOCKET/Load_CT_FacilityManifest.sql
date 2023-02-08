TRUNCATE table [ODS].[dbo].[CT_FacilityManifest];
MERGE [ODS].[dbo].[CT_FacilityManifest] AS a
	USING( SELECT DISTINCT 
			Emr,Project,Voided,Processed,SiteCode,PatientCount,DateRecieved,[Name],EmrName,EmrSetup,UploadMode,[Start],[End],Tag
		   FROM [DWAPICentral].[dbo].[FacilityManifest](NoLock)
		) AS b 
	ON(a.SiteCode =b.SiteCode)
		WHEN NOT MATCHED THEN 
	INSERT(Voided,Processed,SiteCode,PatientCount,DateRecieved,[Name],EmrName,EmrSetup,UploadMode,[Start],[End],Tag,CreatedOn)
	VALUES(Voided,Processed,SiteCode,PatientCount,DateRecieved,[Name],EmrName,EmrSetup,UploadMode,[Start],[End],Tag,Getdate())
	
	WHEN MATCHED THEN
    UPDATE SET 		
		a.[Voided]		=b.[Voided]	,	
		a.[Processed]	=b.[Processed],	
		a.[PatientCount]=b.[PatientCount],
		a.[DateRecieved]=b.[DateRecieved],
		a.[Name]		=b.[Name]	,	
		a.[EmrName]		=b.[EmrName],		
		a.[EmrSetup]	=b.[EmrSetup],	
		a.[UploadMode]	=b.[UploadMode],	
		a.[Start]		=b.[Start],		
		a.[End]			=b.[End],			
		a.[Tag]			=b.[Tag];
	--WHEN NOT MATCHED BY SOURCE 
	--THEN
	--/* The Record is in the target table but doen't exit on the source table*/
	--	Delete;


