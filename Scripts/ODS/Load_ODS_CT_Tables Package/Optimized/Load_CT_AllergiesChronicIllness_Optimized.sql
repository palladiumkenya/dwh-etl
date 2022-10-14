BEGIN
	       DECLARE @MaxVisitDate_Hist			DATETIME,
				   @VisitDate					DATETIME
				
		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS].[dbo].[CT_AllergiesChronicIllness_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[AllergiesChronicIllnessExtract] WITH (NOLOCK) 
		
		IF (SELECT COUNT(1) FROM [ODS].[dbo].[CT_AllergiesChronicIllness_Log](NoLock) WHERE MaxVisitDate = @VisitDate) > 0
		RETURN

			ELSE
				BEGIN
					
					INSERT INTO  [ODS].[dbo].[CT_AllergiesChronicIllness_Log](MaxVisitDate,LoadStartDateTime)
					VALUES(@VisitDate,GETDATE())

					INSERT INTO [ODS].[dbo].[CT_AllergiesChronicIllness](PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,
					ChronicIllness,ChronicOnsetDate,knownAllergies,AllergyCausativeAgent,AllergicReaction,AllergySeverity,
					AllergyOnsetDate,Skin,Eyes,ENT,Chest,CVS,Abdomen,CNS,Genitourinary,DateImported,CKV)
					SELECT
						P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,
						F.Name AS FacilityName,ACI.[VisitId] AS VisitID,ACI.[VisitDate] AS VisitDate, P.[Emr] AS Emr,
						CASE
							P.[Project]
							WHEN 'I-TECH' THEN 'Kenya HMIS II'
							WHEN 'HMIS' THEN 'Kenya HMIS II'
							ELSE P.[Project]
						END AS Project,
						ACI.[ChronicIllness] AS ChronicIllness,ACI.[ChronicOnsetDate] AS ChronicOnsetDate,ACI.[knownAllergies] AS knownAllergies,
						ACI.[AllergyCausativeAgent] AS AllergyCausativeAgent,ACI.[AllergicReaction] AS AllergicReaction,ACI.[AllergySeverity] AS AllergySeverity,
						ACI.[AllergyOnsetDate] AS AllergyOnsetDate,ACI.[Skin] AS Skin,ACI.[Eyes] AS Eyes,ACI.[ENT] AS ENT,ACI.[Chest] AS Chest,ACI.[CVS] AS CVS,
						ACI.[Abdomen] AS Abdomen,ACI.[CNS] AS CNS,ACI.[Genitourinary] AS Genitourinary,GETDATE() AS DateImported,
						LTRIM(RTRIM(STR(F.Code))) + '-' + LTRIM(RTRIM(P.[PatientCccNumber])) + '-' + LTRIM(RTRIM(STR(P.[PatientPID]))) AS PKV
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[AllergiesChronicIllnessExtract](NoLock) ACI ON ACI.[PatientId] = P.ID AND ACI.Voided = 0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
					WHERE P.gender != 'Unknown' and VisitDate > @MaxVisitDate_Hist					

					UPDATE [ODS].[dbo].[CT_AllergiesChronicIllness_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @VisitDate;

			END
			---Remove any duplicate from [ODS].[dbo].[CT_AllergiesChronicIllness]
			;WITH CTE AS   
				(  
					SELECT [PatientPK],[SiteCode],VisitDate,ROW_NUMBER() 
					OVER (PARTITION BY [PatientPK],[SiteCode],VisitDate
					ORDER BY [PatientPK],[SiteCode],VisitDate) AS dump_ 
					FROM [ODS].[dbo].[CT_AllergiesChronicIllness]
					)  
			
			DELETE FROM CTE WHERE dump_ >1;

			
	END