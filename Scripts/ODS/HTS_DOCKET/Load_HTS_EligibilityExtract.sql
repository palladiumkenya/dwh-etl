
BEGIN
 --truncate table [ODS].[dbo].[HTS_EligibilityExtract]
		MERGE [ODS].[dbo].[HTS_EligibilityExtract] AS a
			USING(SELECT DISTINCT  a.[FacilityName],a.[SiteCode],a.[PatientPk],a.[HtsNumber],a.[Emr],a.[Project],a.[Processed],a.[QueueId],a.[Status]
							,a.[StatusDate],a.[EncounterId],[VisitID],a.[VisitDate],a.[PopulationType],[KeyPopulation],[PriorityPopulation],[Department]
							,[PatientType],[IsHealthWorker],[RelationshipWithContact],[TestedHIVBefore],[WhoPerformedTest],[ResultOfHIV],[DateTestedSelf]
							,[StartedOnART],[CCCNumber],[EverHadSex],[SexuallyActive],[NewPartner],[PartnerHIVStatus],a.[CoupleDiscordant],[MultiplePartners]
							,[NumberOfPartners],[AlcoholSex],[MoneySex],[CondomBurst],[UnknownStatusPartner],[KnownStatusPartner],[Pregnant],[BreastfeedingMother]
							,[ExperiencedGBV],[ContactWithTBCase],[Lethargy],[EverOnPrep],[CurrentlyOnPrep],[EverOnPep],[CurrentlyOnPep],[EverHadSTI],[CurrentlyHasSTI]
							,[EverHadTB],[SharedNeedle],[NeedleStickInjuries],[TraditionalProcedures],[ChildReasonsForIneligibility],[EligibleForTest]
							,[ReasonsForIneligibility],[SpecificReasonForIneligibility],a.[FacilityId],[Cough],[DateTestedProvider],[Fever],[MothersStatus]
							,[NightSweats],[ReferredForTesting],[ResultOfHIVSelf],[ScreenedTB],[TBStatus],[WeightLoss],[AssessmentOutcome],[ForcedSex]
							,[ReceivedServices],[TypeGBV],
							   convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[PatientPk]  as nvarchar(36))), 2) PatientPKHash,
					       convert(nvarchar(64), hashbytes('SHA2_256', cast(a.HtsNumber  as nvarchar(36))), 2)HtsNumberHash,
						   convert(nvarchar(64), hashbytes('SHA2_256', cast(LTRIM(RTRIM(a.PatientPk)) +'-'+LTRIM(RTRIM(a.HtsNumber)) as nvarchar(100))), 2) as CKVHash
						FROM [HTSCentral].[dbo].[HtsEligibilityExtract] (NoLock)a
						INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
						on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode					
					
				) AS b 
				ON(
					a.PatientPK  = b.PatientPK 
					and a.SiteCode = b.SiteCode	
					and a.EncounterId COLLATE Latin1_General_CI_AS = b.EncounterId
					and a.EverHadSex COLLATE Latin1_General_CI_AS = b.EverHadSex
					and a.PartnerHIVStatus COLLATE Latin1_General_CI_AS = b.PartnerHIVStatus
					and a.HtsNumber COLLATE Latin1_General_CI_AS = b.HtsNumber
					and a.CurrentlyOnPep COLLATE Latin1_General_CI_AS = b.CurrentlyOnPep
					and a.CurrentlyHasSTI COLLATE Latin1_General_CI_AS = b.CurrentlyHasSTI
					and a.AlcoholSex COLLATE Latin1_General_CI_AS = b.AlcoholSex
					--and a.DateTestedProvider COLLATE Latin1_General_CI_AS = b.DateTestedProvider
					and a.ExperiencedGBV COLLATE Latin1_General_CI_AS = b.ExperiencedGBV
					and a.IsHealthWorker COLLATE Latin1_General_CI_AS = b.IsHealthWorker
					and a.ResultOfHIV COLLATE Latin1_General_CI_AS = b.ResultOfHIV
					and a.KnownStatusPartner COLLATE Latin1_General_CI_AS = b.KnownStatusPartner
					and a.TestedHIVBefore COLLATE Latin1_General_CI_AS = b.TestedHIVBefore
					and a.RelationshipWithContact COLLATE Latin1_General_CI_AS = b.RelationshipWithContact
					and a.WeightLoss COLLATE Latin1_General_CI_AS = b.WeightLoss
					and a.Cough COLLATE Latin1_General_CI_AS = b.Cough
					--and a.NumberOfPartners COLLATE Latin1_General_CI_AS = b.NumberOfPartners
					and a.ReferredForTesting COLLATE Latin1_General_CI_AS = b.ReferredForTesting					
					and a.PopulationType COLLATE Latin1_General_CI_AS = b.PopulationType
					and a.KeyPopulation COLLATE Latin1_General_CI_AS = b.KeyPopulation
					and a.CurrentlyOnPrep COLLATE Latin1_General_CI_AS = b.CurrentlyOnPrep
					and a.ReceivedServices COLLATE Latin1_General_CI_AS = b.ReceivedServices
					and a.EligibleForTest COLLATE Latin1_General_CI_AS = b.EligibleForTest
					and a.PatientType COLLATE Latin1_General_CI_AS = b.PatientType
					and a.Fever COLLATE Latin1_General_CI_AS = b.Fever
					and a.NightSweats COLLATE Latin1_General_CI_AS = b.NightSweats
					and a.Department COLLATE Latin1_General_CI_AS = b.Department

				)
		WHEN NOT MATCHED THEN 
			INSERT(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,Processed,QueueId,Status,StatusDate,EncounterId,VisitID,VisitDate,PopulationType,KeyPopulation,PriorityPopulation,Department,PatientType,IsHealthWorker,RelationshipWithContact,TestedHIVBefore,WhoPerformedTest,ResultOfHIV,DateTestedSelf,StartedOnART,CCCNumber,EverHadSex,SexuallyActive,NewPartner,PartnerHIVStatus,CoupleDiscordant,MultiplePartners,NumberOfPartners,AlcoholSex,MoneySex,CondomBurst,UnknownStatusPartner,KnownStatusPartner,Pregnant,BreastfeedingMother,ExperiencedGBV,ContactWithTBCase,Lethargy,EverOnPrep,CurrentlyOnPrep,EverOnPep,CurrentlyOnPep,EverHadSTI,CurrentlyHasSTI,EverHadTB,SharedNeedle,NeedleStickInjuries,TraditionalProcedures,ChildReasonsForIneligibility,EligibleForTest,ReasonsForIneligibility,SpecificReasonForIneligibility,Cough,DateTestedProvider,Fever,MothersStatus,NightSweats,ReferredForTesting,ResultOfHIVSelf,ScreenedTB,TBStatus,WeightLoss,AssessmentOutcome,ForcedSex,ReceivedServices,TypeGBV,PatientPKHash,HtsNumberHash) 
			VALUES(FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,Processed,QueueId,Status,StatusDate,EncounterId,VisitID,VisitDate,PopulationType,KeyPopulation,PriorityPopulation,Department,PatientType,IsHealthWorker,RelationshipWithContact,TestedHIVBefore,WhoPerformedTest,ResultOfHIV,DateTestedSelf,StartedOnART,CCCNumber,EverHadSex,SexuallyActive,NewPartner,PartnerHIVStatus,CoupleDiscordant,MultiplePartners,NumberOfPartners,AlcoholSex,MoneySex,CondomBurst,UnknownStatusPartner,KnownStatusPartner,Pregnant,BreastfeedingMother,ExperiencedGBV,ContactWithTBCase,Lethargy,EverOnPrep,CurrentlyOnPrep,EverOnPep,CurrentlyOnPep,EverHadSTI,CurrentlyHasSTI,EverHadTB,SharedNeedle,NeedleStickInjuries,TraditionalProcedures,ChildReasonsForIneligibility,EligibleForTest,ReasonsForIneligibility,SpecificReasonForIneligibility,Cough,DateTestedProvider,Fever,MothersStatus,NightSweats,ReferredForTesting,ResultOfHIVSelf,ScreenedTB,TBStatus,WeightLoss,AssessmentOutcome,ForcedSex,ReceivedServices,TypeGBV,PatientPKHash,HtsNumberHash)
		
		WHEN MATCHED THEN
			UPDATE SET 
					a.[FacilityName]					=b.[FacilityName],         
					a.[HtsNumber]						=b.[HtsNumber],
					a.[Emr]								=b.[Emr],
					a.[Project]							=b.[Project],
					a.[Processed]						=b.[Processed],
					a.[QueueId]							=b.[QueueId],
					a.[Status]							=b.[Status]	,
					a.[StatusDate]						=b.[StatusDate],
					a.[EncounterId]						=b.[EncounterId],
					a.[VisitID]							=b.[VisitID],
					a.[VisitDate]						=b.[VisitDate],
					a.[PopulationType]					=b.[PopulationType]	,
					a.[KeyPopulation]					=b.[KeyPopulation],
					a.[PriorityPopulation]				=b.[PriorityPopulation]	,
					a.[Department]						=b.[Department]	,
					a.[PatientType]						=b.[PatientType],
					a.[IsHealthWorker]					=b.[IsHealthWorker],
					a.[RelationshipWithContact]			=b.[RelationshipWithContact],
					a.[TestedHIVBefore]					=b.[TestedHIVBefore],
					a.[WhoPerformedTest]				=b.[WhoPerformedTest],
					a.[ResultOfHIV]						=b.[ResultOfHIV],
					a.[DateTestedSelf]					=b.[DateTestedSelf],
					a.[StartedOnART]					=b.[StartedOnART],
					a.[CCCNumber]						=b.[CCCNumber],
					a.[EverHadSex]						=b.[EverHadSex]	,
					a.[SexuallyActive]					=b.[SexuallyActive]	,
					a.[NewPartner]						=b.[NewPartner]	,
					a.[PartnerHIVStatus]				=b.[PartnerHIVStatus],
					a.[CoupleDiscordant]				=b.[CoupleDiscordant],
					a.[MultiplePartners]				=b.[MultiplePartners],
					a.[NumberOfPartners]				=b.[NumberOfPartners],
					a.[AlcoholSex]						=b.[AlcoholSex]	,
					a.[MoneySex]						=b.[MoneySex]	,
					a.[CondomBurst]						=b.[CondomBurst],
					a.[UnknownStatusPartner]			=b.[UnknownStatusPartner],
					a.[KnownStatusPartner]				=b.[KnownStatusPartner]	,
					a.[Pregnant]						=b.[Pregnant],
					a.[BreastfeedingMother]				=b.[BreastfeedingMother],
					a.[ExperiencedGBV]					=b.[ExperiencedGBV]	,
					a.[ContactWithTBCase]				=b.[ContactWithTBCase],
					a.[Lethargy]						=b.[Lethargy],
					a.[EverOnPrep]						=b.[EverOnPrep]	,
					a.[CurrentlyOnPrep]					=b.[CurrentlyOnPrep],
					a.[EverOnPep]						=b.[EverOnPep],
					a.[CurrentlyOnPep]					=b.[CurrentlyOnPep]	,
					a.[EverHadSTI]						=b.[EverHadSTI]	,
					a.[CurrentlyHasSTI]					=b.[CurrentlyHasSTI],
					a.[EverHadTB]						=b.[EverHadTB]	,
					a.[SharedNeedle]					=b.[SharedNeedle]	,
					a.[NeedleStickInjuries]				=b.[NeedleStickInjuries],
					a.[TraditionalProcedures]			=b.[TraditionalProcedures],
					a.[ChildReasonsForIneligibility]	=b.[ChildReasonsForIneligibility],
					a.[EligibleForTest]					=b.[EligibleForTest],
					a.[ReasonsForIneligibility]			=b.[ReasonsForIneligibility],
					a.[SpecificReasonForIneligibility]	=b.[SpecificReasonForIneligibility]	,
					a.[Cough]							=b.[Cough]				,
					a.[DateTestedProvider]				=b.[DateTestedProvider]	,
					a.[Fever]							=b.[Fever]				,
					a.[MothersStatus]					=b.[MothersStatus]		,
					a.[NightSweats]						=b.[NightSweats]		,
					a.[ReferredForTesting]				=b.[ReferredForTesting]	,
					a.[ResultOfHIVSelf]					=b.[ResultOfHIVSelf]	,
					a.[ScreenedTB]						=b.[ScreenedTB]	,
					a.[TBStatus]						=b.[TBStatus],
					a.[WeightLoss]						=b.[WeightLoss]	,
					a.[AssessmentOutcome]				=b.[AssessmentOutcome],
					a.[ForcedSex]						=b.[ForcedSex],
					a.[ReceivedServices]				=b.[ReceivedServices],
					a.[TypeGBV]							=b.[TypeGBV];


		--WHEN NOT MATCHED BY SOURCE 
		--	THEN
		--		/* The Record is in the target table but doen't exit on the source table*/
		--	Delete;
END