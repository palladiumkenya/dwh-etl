
BEGIN
		DECLARE		@MaxDateCreated_Hist			DATETIME,
				   @DateCreated					DATETIME
				
		SELECT @MaxDateCreated_Hist =  MAX(MaxDateCreated) FROM [ODS].[dbo].[CT_ContactListing_Log]  (NoLock)
		SELECT @MaxDateCreated_Hist = MAX(Created) FROM [DWAPICentral].[dbo].[ContactListingExtract](NoLock)
							
		INSERT INTO  [ODS].[dbo].[CT_ContactListing_Log](MaxDateCreated,LoadStartDateTime)
		VALUES(@MaxDateCreated_Hist,GETDATE())
			--CREATE INDEX CT_ContactListing ON [ODS].[dbo].[CT_ContactListing] (sitecode,PatientPK);
	       ---- Refresh [ODS].[dbo].[CT_ContactListing]
			MERGE [ODS].[dbo].[CT_ContactListing] AS a
				USING(SELECT
						P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,
						F.Name AS FacilityName,P.[Emr] AS Emr,
						CASE
							P.[Project]
							WHEN 'I-TECH' THEN 'Kenya HMIS II'
							WHEN 'HMIS' THEN 'Kenya HMIS II'
							ELSE P.[Project]
						END AS Project,
						CL.[PartnerPersonID] AS PartnerPersonID,CL.[ContactAge] AS ContactAge,CL.[ContactSex] AS ContactSex,
						CL.[ContactMaritalStatus] AS ContactMaritalStatus,CL.[RelationshipWithPatient] AS RelationshipWithPatient,
						CL.[ScreenedForIpv] AS ScreenedForIpv,CL.[IpvScreening] AS IpvScreening,
						CL.[IPVScreeningOutcome] AS IPVScreeningOutcome,
						CL.[CurrentlyLivingWithIndexClient] AS CurrentlyLivingWithIndexClient,
						CL.[KnowledgeOfHivStatus] AS KnowledgeOfHivStatus,CL.[PnsApproach] AS PnsApproach,
						GETDATE() AS DateImported,
						LTRIM(RTRIM(STR(F.Code)))+'-'+LTRIM(RTRIM(P.[PatientCccNumber]))+'-'+LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV, 
					  ContactPatientPK,
					  CL.Created as DateCreated
					  ,P.ID as  PatientUnique_ID
					  ,CL.PatientId as UniquePatientContactListingId
					  ,CL.ID as  ContactListingUnique_ID,
					  convert(nvarchar(64), hashbytes('SHA2_256', cast(P.[PatientPID]  as nvarchar(36))), 2) PatientPKHash,   
						convert(nvarchar(64), hashbytes('SHA2_256', cast(P.[PatientCccNumber]  as nvarchar(36))), 2) PatientIDHash,
						convert(nvarchar(64), hashbytes('SHA2_256', cast(LTRIM(RTRIM(STR(F.Code))) + '-' + LTRIM(RTRIM(P.[PatientCccNumber])) + '-' + LTRIM(RTRIM(STR(P.[PatientPID])))  as nvarchar(36))), 2) CKVHash

					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[ContactListingExtract](NoLock) CL ON CL.[PatientId] = P.ID AND CL.Voided = 0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
					WHERE P.gender != 'Unknown') AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.PatientUnique_ID =b.UniquePatientContactListingId
						and a.Contactage COLLATE SQL_Latin1_General_CP1_CI_AS= b.Contactage COLLATE SQL_Latin1_General_CP1_CI_AS
						and a.RelationshipWithPatient COLLATE SQL_Latin1_General_CP1_CI_AS =b.RelationshipWithPatient COLLATE SQL_Latin1_General_CP1_CI_AS
						--and a.ContactListingUnique_ID = b.ContactListingUnique_ID
						)

					WHEN NOT MATCHED THEN 
						INSERT(PatientID,PatientPK,SiteCode,FacilityName,Emr,Project,PartnerPersonID,ContactAge,ContactSex,ContactMaritalStatus,RelationshipWithPatient,ScreenedForIpv,IpvScreening,IPVScreeningOutcome,CurrentlyLivingWithIndexClient,KnowledgeOfHivStatus,PnsApproach,DateImported,CKV,ContactPatientPK,DateCreated,PatientUnique_ID,ContactListingUnique_ID,PatientPKHash,PatientIDHash,CKVHash) 
						VALUES(PatientID,PatientPK,SiteCode,FacilityName,Emr,Project,PartnerPersonID,ContactAge,ContactSex,ContactMaritalStatus,RelationshipWithPatient,ScreenedForIpv,IpvScreening,IPVScreeningOutcome,CurrentlyLivingWithIndexClient,KnowledgeOfHivStatus,PnsApproach,DateImported,CKV,ContactPatientPK,DateCreated,PatientUnique_ID,ContactListingUnique_ID,PatientPKHash,PatientIDHash,CKVHash)
				
					WHEN MATCHED THEN
						UPDATE SET 					
						a.FacilityName					=b.FacilityName,
						a.ContactAge					=b.ContactAge,
						a.ContactSex					=b.ContactSex,
						a.ContactMaritalStatus			=b.ContactMaritalStatus,
						a.RelationshipWithPatient		=b.RelationshipWithPatient,
						a.ScreenedForIpv				=b.ScreenedForIpv,
						a.IpvScreening					=b.IpvScreening,
						a.IPVScreeningOutcome			=b.IPVScreeningOutcome,
						a.CurrentlyLivingWithIndexClient=b.CurrentlyLivingWithIndexClient,
						a.KnowledgeOfHivStatus			=b.KnowledgeOfHivStatus,
						a.PnsApproach					=b.PnsApproach;

					--WHEN NOT MATCHED BY SOURCE 
					--	THEN
					--	/* The Record is in the target table but doen't exit on the source table*/
					--		Delete;	
				--					WITH CTE AS   
				--	(  
				--		SELECT [PatientPK],[SiteCode],Contactage,RelationshipWithPatient,ROW_NUMBER() 
				--		OVER (PARTITION BY [PatientPK],[SiteCode],Contactage,RelationshipWithPatient
				--		ORDER BY [PatientPK],[SiteCode],Contactage,RelationshipWithPatient) AS dump_ 
				--		FROM [ODS].[dbo].[CT_ContactListing] 
				--		)  
			
				--DELETE FROM CTE WHERE dump_ >1;

				UPDATE [ODS].[dbo].[CT_ContactListing_Log]
					SET LoadEndDateTime = GETDATE()
				WHERE MaxDateCreated = @MaxDateCreated_Hist;
				--DROP INDEX CT_ContactListing ON [ODS].[dbo].[CT_ContactListing];
				---Remove any duplicate from [ODS].[dbo].[CT_ContactListing]


	END
