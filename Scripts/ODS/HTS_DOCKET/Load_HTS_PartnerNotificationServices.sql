BEGIN
		--truncate table [ODS].[dbo].[HTS_PartnerNotificationServices]
		MERGE [ODS].[dbo].[HTS_PartnerNotificationServices] AS a
			USING(SELECT DISTINCT a.ID,a.[FacilityName]
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

				
				and a.DateElicited  = b.DateElicited
				and a.Dob  = b.Dob
				and a.ID = b.ID

			)
	WHEN NOT MATCHED THEN 
		INSERT(ID,FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,PartnerPatientPk,KnowledgeOfHivStatus,PartnerPersonID,CccNumber,IpvScreeningOutcome,ScreenedForIpv,PnsConsent,RelationsipToIndexClient,LinkedToCare,MaritalStatus,PnsApproach,FacilityLinkedTo,Gender,CurrentlyLivingWithIndexClient,Age,DateElicited,Dob,LinkDateLinkedToCare) 
		VALUES(ID,FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,PartnerPatientPk,KnowledgeOfHivStatus,PartnerPersonID,CccNumber,IpvScreeningOutcome,ScreenedForIpv,PnsConsent,RelationsipToIndexClient,LinkedToCare,MaritalStatus,PnsApproach,FacilityLinkedTo,Gender,CurrentlyLivingWithIndexClient,Age,DateElicited,Dob,LinkDateLinkedToCare)

	WHEN MATCHED THEN
		UPDATE SET 
			
				a.[KnowledgeOfHivStatus]			=b.[KnowledgeOfHivStatus],
				
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
				a.[LinkDateLinkedToCare]			=b.[LinkDateLinkedToCare];
	
END
	
