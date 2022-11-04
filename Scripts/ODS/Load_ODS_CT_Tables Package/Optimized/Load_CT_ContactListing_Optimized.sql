BEGIN
	       DECLARE @MaxDateCreated_Hist			DATETIME,
				   @DateCreated					DATETIME
				
		SELECT @MaxDateCreated_Hist =  MAX(MaxDateCreated) FROM [ODS].[dbo].[CT_ContactListing_Log]  (NoLock)
		SELECT @MaxDateCreated_Hist = MAX(Created) FROM [DWAPICentral].[dbo].[ContactListingExtract](NoLock)
		
		IF (SELECT COUNT(1) FROM [ODS].[dbo].[CT_ContactListing_Log](NoLock) WHERE MaxDateCreated = @MaxDateCreated_Hist) > 0
		RETURN

			ELSE
				BEGIN
					
					INSERT INTO  [ODS].[dbo].[CT_ContactListing_Log](MaxDateCreated,LoadStartDateTime)
					VALUES(@MaxDateCreated_Hist,GETDATE())

					INSERT INTO [ODS].[dbo].[CT_ContactListing](PatientID,PatientPK,SiteCode,FacilityName,Emr,Project,
					PartnerPersonID,ContactAge,ContactSex,ContactMaritalStatus,RelationshipWithPatient,ScreenedForIpv,IpvScreening,
					IPVScreeningOutcome,CurrentlyLivingWithIndexClient,KnowledgeOfHivStatus,PnsApproach,DateImported,CKV,ContactPatientPK,DateCreated)
					SELECT
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
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[ContactListingExtract](NoLock) CL ON CL.[PatientId] = P.ID AND CL.Voided = 0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
					WHERE P.gender != 'Unknown' and CL.Created > @MaxDateCreated_Hist					

					UPDATE [ODS].[dbo].[CT_ContactListing_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxDateCreated = @MaxDateCreated_Hist;

			END
			---Remove any duplicate from [ODS].[dbo].[CT_ContactListing]
			;WITH CTE AS   
				(  
					SELECT [PatientPK],[SiteCode],ROW_NUMBER() 
					OVER (PARTITION BY [PatientPK],[SiteCode]
					ORDER BY [PatientPK],[SiteCode]) AS dump_ 
					FROM [ODS].[dbo].[CT_ContactListing]
					)  
			
			DELETE FROM CTE WHERE dump_ >1;

			
	END