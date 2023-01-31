BEGIN
		--truncate table [ODS].[dbo].[HTS_PartnerNotificationServices]
		MERGE [ODS].[dbo].[HTS_PartnerNotificationServices] AS a
			USING(SELECT DISTINCT a.[FacilityName]
				  ,a.[SiteCode]
				  ,a.[PatientPk]
				  ,a.[HtsNumber]
				  ,a.[Emr]
				  ,a.[Project]
				  ,[PartnerPatientPk]
				  ,[KnowledgeOfHivStatus]
				  ,[PartnerPersonID]
				  ,[CccNumber]
				  ,[IpvScreeningOutcome]
				  ,[ScreenedForIpv]
				  ,[PnsConsent]
				  ,[RelationsipToIndexClient]
				  ,[LinkedToCare]
				  ,Cl.[MaritalStatus]
				  ,[PnsApproach]
				  ,[FacilityLinkedTo]
				  ,LEFT([Sex], 1) AS Gender
				  ,[CurrentlyLivingWithIndexClient]    
				  ,[Age]
				  ,[DateElicited]
				  ,Cl.[Dob]
				  ,[LinkDateLinkedToCare]
			  FROM [HTSCentral].[dbo].[HtsPartnerNotificationServices](NoLock) a
			INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
			  on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode
			  ) AS b 
			ON(
				a.PatientPK  = b.PatientPK 
				and a.SiteCode = b.SiteCode	
				
				and a.PartnerPersonID  = b.PartnerPersonID 
				and a.PartnerPatientPk  = b.PartnerPatientPk 

				and a.HtsNumber COLLATE Latin1_General_CI_AS = b.HtsNumber 
				and a.KnowledgeOfHivStatus COLLATE Latin1_General_CI_AS = b.KnowledgeOfHivStatus  
				and a.PnsApproach COLLATE Latin1_General_CI_AS = b.PnsApproach 
				and a.MaritalStatus COLLATE Latin1_General_CI_AS = b.MaritalStatus 
				and a.RelationsipToIndexClient COLLATE Latin1_General_CI_AS = b.RelationsipToIndexClient 
				and a.CurrentlyLivingWithIndexClient COLLATE Latin1_General_CI_AS = b.CurrentlyLivingWithIndexClient
				and a.Age  = b.Age 
				and a.CccNumber COLLATE Latin1_General_CI_AS = b.CccNumber 
				and a.Gender COLLATE Latin1_General_CI_AS = b.Gender 
				and a.FacilityLinkedTo COLLATE Latin1_General_CI_AS = b.FacilityLinkedTo 
				and a.DateElicited  = b.DateElicited
				and a.Dob  = b.Dob

			)
	WHEN NOT MATCHED THEN 
		INSERT(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,PartnerPatientPk,KnowledgeOfHivStatus,PartnerPersonID,CccNumber,IpvScreeningOutcome,ScreenedForIpv,PnsConsent,RelationsipToIndexClient,LinkedToCare,MaritalStatus,PnsApproach,FacilityLinkedTo,Gender,CurrentlyLivingWithIndexClient,Age,DateElicited,Dob,LinkDateLinkedToCare) 
		VALUES(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,PartnerPatientPk,KnowledgeOfHivStatus,PartnerPersonID,CccNumber,IpvScreeningOutcome,ScreenedForIpv,PnsConsent,RelationsipToIndexClient,LinkedToCare,MaritalStatus,PnsApproach,FacilityLinkedTo,Gender,CurrentlyLivingWithIndexClient,Age,DateElicited,Dob,LinkDateLinkedToCare)

	WHEN MATCHED THEN
		UPDATE SET 
				a.[FacilityName]					=b.[FacilityName],											
				a.[HtsNumber]						=b.[HtsNumber],
				a.[Emr]								=b.[Emr],	
				a.[Project]							=b.[Project],	
				a.[PartnerPatientPk]				=b.[PartnerPatientPk]	,
				a.[KnowledgeOfHivStatus]			=b.[KnowledgeOfHivStatus],
				a.[PartnerPersonID]					=b.[PartnerPersonID],	
				a.[CccNumber]						=b.[CccNumber],
				a.[IpvScreeningOutcome]				=b.[IpvScreeningOutcome],	
				a.[ScreenedForIpv]					=b.[ScreenedForIpv]	,
				a.[PnsConsent]						=b.[PnsConsent],
				a.[RelationsipToIndexClient]		=b.[RelationsipToIndexClient],
				a.[LinkedToCare]					=b.[LinkedToCare],
				a.[MaritalStatus]					=b.[MaritalStatus],
				a.[PnsApproach]						=b.[PnsApproach],	
				a.[FacilityLinkedTo]				=b.[FacilityLinkedTo],
				a.[Gender]							=b.[Gender],
				a.[CurrentlyLivingWithIndexClient]	=b.[CurrentlyLivingWithIndexClient],
				a.[Age]								=b.[Age],	
				a.[DateElicited]					=b.[DateElicited],
				a.[Dob]								=b.[Dob],	
				a.[LinkDateLinkedToCare]			=b.[LinkDateLinkedToCare]
		
		WHEN NOT MATCHED BY SOURCE 
			THEN
				/* The Record is in the target table but doen't exit on the source table*/
			Delete;
END
	

