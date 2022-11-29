BEGIN
	       DECLARE @MaxVisitDate_Hist			DATETIME,
				   @VisitDate					DATETIME
				
		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS].[dbo].[CT_EnhancedAdherenceCounselling_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[EnhancedAdherenceCounsellingExtract](NoLock)
		
		IF (SELECT COUNT(1) FROM [ODS].[dbo].[CT_EnhancedAdherenceCounselling_Log](NoLock) WHERE MaxVisitDate = @MaxVisitDate_Hist) > 0
		RETURN

			ELSE
				BEGIN
					
					INSERT INTO  [ODS].[dbo].[CT_EnhancedAdherenceCounselling_Log](MaxVisitDate,LoadStartDateTime)
					VALUES(@MaxVisitDate_Hist,GETDATE())

					INSERT INTO [ODS].[dbo].[CT_EnhancedAdherenceCounselling](PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,
					SessionNumber,DateOfFirstSession,PillCountAdherence,MMAS4_1,MMAS4_2,MMAS4_3,MMAS4_4,
					MMSA8_1,MMSA8_2,MMSA8_3,MMSA8_4,MMSAScore,EACRecievedVL,EACVL,EACVLConcerns,EACVLThoughts,EACWayForward,
					EACCognitiveBarrier,EACBehaviouralBarrier_1,EACBehaviouralBarrier_2,EACBehaviouralBarrier_3,EACBehaviouralBarrier_4,EACBehaviouralBarrier_5,
					EACEmotionalBarriers_1,EACEmotionalBarriers_2,EACEconBarrier_1,EACEconBarrier_2,EACEconBarrier_3,EACEconBarrier_4,EACEconBarrier_5,EACEconBarrier_6,EACEconBarrier_7,EACEconBarrier_8,
					EACReviewImprovement,EACReviewMissedDoses,EACReviewStrategy,EACReferral,EACReferralApp,EACReferralExperience,EACHomevisit,
					EACAdherencePlan,EACFollowupDate,DateImported,CKV)
					SELECT
						P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,F.Name AS FacilityName,
						EAC.[VisitId] AS VisitID,EAC.[VisitDate] AS VisitDate,P.[Emr] AS Emr,
						CASE
							P.[Project]
							WHEN 'I-TECH' THEN 'Kenya HMIS II'
							WHEN 'HMIS' THEN 'Kenya HMIS II'
							ELSE P.[Project]
						END AS Project,
						EAC.[SessionNumber],EAC.[DateOfFirstSession],EAC.[PillCountAdherence],EAC.[MMAS4_1],
						EAC.[MMAS4_2],EAC.[MMAS4_3],EAC.[MMAS4_4],EAC.[MMSA8_1],EAC.[MMSA8_2],EAC.[MMSA8_3],EAC.[MMSA8_4],
						EAC.[MMSAScore],EAC.[EACRecievedVL],EAC.[EACVL],EAC.[EACVLConcerns],EAC.[EACVLThoughts],EAC.[EACWayForward],
						EAC.[EACCognitiveBarrier],EAC.[EACBehaviouralBarrier_1],EAC.[EACBehaviouralBarrier_2],EAC.[EACBehaviouralBarrier_3],
						EAC.[EACBehaviouralBarrier_4],EAC.[EACBehaviouralBarrier_5],EAC.[EACEmotionalBarriers_1],EAC.[EACEmotionalBarriers_2],
						EAC.[EACEconBarrier_1],EAC.[EACEconBarrier_2],EAC.[EACEconBarrier_3],EAC.[EACEconBarrier_4],EAC.[EACEconBarrier_5],
						EAC.[EACEconBarrier_6],EAC.[EACEconBarrier_7],EAC.[EACEconBarrier_8],EAC.[EACReviewImprovement],EAC.[EACReviewMissedDoses],
						EAC.[EACReviewStrategy],EAC.[EACReferral],EAC.[EACReferralApp],EAC.[EACReferralExperience],EAC.[EACHomevisit],
						EAC.[EACAdherencePlan],EAC.[EACFollowupDate],GETDATE() AS DateImported,   
						LTRIM(RTRIM(STR(F.Code))) + '-' + LTRIM(RTRIM(P.[PatientCccNumber])) + '-' + LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[EnhancedAdherenceCounsellingExtract](NoLock) EAC ON EAC.[PatientId] = P.ID AND EAC.Voided = 0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
					WHERE P.gender != 'Unknown'  and VisitDate > @MaxVisitDate_Hist					

					UPDATE [ODS].[dbo].[CT_EnhancedAdherenceCounselling_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @MaxVisitDate_Hist;

			END
			---Remove any duplicate from [ODS].[dbo].[CT_EnhancedAdherenceCounselling]
			;WITH CTE AS   
				(  
					SELECT [PatientPK],[SiteCode],ROW_NUMBER() 
					OVER (PARTITION BY [PatientPK],[SiteCode]
					ORDER BY [PatientPK],[SiteCode]) AS dump_ 
					FROM [ODS].[dbo].[CT_EnhancedAdherenceCounselling]
					)  
			
			DELETE FROM CTE WHERE dump_ >1;

			
	END