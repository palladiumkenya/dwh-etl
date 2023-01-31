
BEGIN
 
	 DECLARE		@MaxVisitDate_Hist			DATETIME,
					@VisitDate					DATETIME
				
			SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS].[dbo].[CT_AllergiesChronicIllness_Log]  (NoLock)
			SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[AllergiesChronicIllnessExtract] WITH (NOLOCK) 					
					
			INSERT INTO  [ODS].[dbo].[CT_AllergiesChronicIllness_Log](MaxVisitDate,LoadStartDateTime)
			VALUES(@VisitDate,GETDATE())

			--CREATE INDEX CT_AllergiesChronicIllness ON [ODS].[dbo].[CT_AllergiesChronicIllness] (sitecode,PatientPK);
	       ---- Refresh [ODS].[dbo].[CT_AllergiesChronicIllness]
			MERGE [ODS].[dbo].[CT_AllergiesChronicIllness] AS a
				USING(SELECT
						P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,ACI.ID,
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
						LTRIM(RTRIM(STR(F.Code))) + '-' + LTRIM(RTRIM(P.[PatientCccNumber])) + '-' + LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV,
						p.ID as PatientUnique_ID
						,ACI.PatientId as UniquePatientAllergiesChronicIllnessId
						,ACI.ID as AllergiesChronicIllnessUnique_ID
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[AllergiesChronicIllnessExtract](NoLock) ACI ON ACI.[PatientId] = P.ID AND ACI.Voided = 0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0

					WHERE P.gender != 'Unknown') AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitDate = b.VisitDate
						and a.VisitID = b.VisitID
						and a.PatientUnique_ID = b.UniquePatientAllergiesChronicIllnessId
						--and a.AllergiesChronicIllnessUnique_ID = b.AllergiesChronicIllnessUnique_ID
						)

					WHEN NOT MATCHED THEN 
						INSERT(PatientUnique_ID,AllergiesChronicIllnessUnique_ID,PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,ChronicIllness,ChronicOnsetDate,knownAllergies,AllergyCausativeAgent,AllergicReaction,AllergySeverity,AllergyOnsetDate,Skin,Eyes,ENT,Chest,CVS,Abdomen,CNS,Genitourinary,DateImported,CKV) 
						VALUES(PatientUnique_ID,ID,PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,ChronicIllness,ChronicOnsetDate,knownAllergies,AllergyCausativeAgent,AllergicReaction,AllergySeverity,AllergyOnsetDate,Skin,Eyes,ENT,Chest,CVS,Abdomen,CNS,Genitourinary,DateImported,CKV)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.PatientID				=b.PatientID,
							a.FacilityName			=b.FacilityName,
							a.Emr					=b.Emr,
							a.Project				=b.Project,
							a.ChronicIllness		=b.ChronicIllness,
							a.ChronicOnsetDate		=b.ChronicOnsetDate,
							a.knownAllergies		=b.knownAllergies,
							a.AllergyCausativeAgent	=b.AllergyCausativeAgent,
							a.AllergicReaction		=b.AllergicReaction,
							a.AllergySeverity		=b.AllergySeverity,
							a.AllergyOnsetDate		=b.AllergyOnsetDate,
							a.Skin					=b.Skin,
							a.Eyes					=b.Eyes,
							a.ENT					=b.ENT,
							a.Chest					=b.Chest,
							a.CVS					=b.CVS,
							a.Abdomen				=b.Abdomen,
							a.CNS					=b.CNS,
							a.Genitourinary			=b.Genitourinary,
							a.DateImported			=b.DateImported,
							a.CKV					=b.CKV;

					--WHEN NOT MATCHED BY SOURCE 
					--	THEN
					--	/* The Record is in the target table but doen't exit on the source table*/
					--		Delete;
					--					WITH CTE AS   
					--	(  
					--		SELECT [PatientPK],[SiteCode],VisitDate,VisitID,ROW_NUMBER() 
					--		OVER (PARTITION BY [PatientPK],[SiteCode],VisitDate,VisitID
					--		ORDER BY [PatientPK],[SiteCode],VisitDate,VisitID) AS dump_ 
					--		FROM [ODS].[dbo].[CT_AllergiesChronicIllness] 
					--		)  
			
					--DELETE FROM CTE WHERE dump_ >1;

					UPDATE [ODS].[dbo].[CT_AllergiesChronicIllness_Log]
						SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @VisitDate;
					
					INSERT INTO [ODS].[dbo].[CT_AllergiesChronicIllnessCount_Log]([SiteCode],[CreatedDate],[AllergiesChronicIllnessCount])
					SELECT SiteCode,GETDATE(),COUNT(SiteCode) AS PatientPharmacyCount 
					FROM [ODS].[dbo].[CT_AllergiesChronicIllness] 
					--WHERE @MaxCreatedDate  > @MaxCreatedDate
					GROUP BY SiteCode;

					--DROP INDEX CT_AllergiesChronicIllness ON [ODS].[dbo].[CT_AllergiesChronicIllness];
					---Remove any duplicate from [ODS].[dbo].[CT_AllergiesChronicIllness]


	END
