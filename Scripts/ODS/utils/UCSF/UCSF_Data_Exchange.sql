USE UCSFDWAPICentral
GO
/****** Object:  StoredProcedure [dbo].[DataRequestUCSFDWAPICentral]    Script Date: 6/13/2023 10:27:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter proc [dbo].[DataRequestUCSFDWAPICentral]
as
BEGIN

-- 2. Patients Extracts

exec OpenSession;
----Patients
IF OBJECT_ID(N'[UCSFDWAPICentral].[dbo].[Patients]', N'U') IS NOT NULL 
	BEGIN
		DROP TABLE [UCSFDWAPICentral].[dbo].[Patients]
	END

BEGIN
		SELECT distinct 
		NULL AS FacilityCode,
		Null AS County,
		--p.PatientPID as PatientPK,
		ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientPID AS NVARCHAR(20)))as PatientPK,
		--p.PatientCCCNumber  as PatientID,
		ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientCCCNumber AS NVARCHAR(20)))as PatientID,
		F.Code as SiteCode,
		Gender,
		cast(DOB as Date)DOB,
		cast(DateConfirmedHIVPositive as Date)DateConfirmedHIVPositive,
		cast(RegistrationAtCCC as Date)RegistrationAtCCC,
		cast(RegistrationATPMTCT as Date)RegistrationATPMTCT,
		cast(RegistrationAtTBClinic as Date)RegistrationAtTBClinic,
		TransferInDate,
		PatientSource,
		MaritalStatus,
		EducationLevel,
		Orphan,
		Inschool,
		PatientType,
		PopulationType,
		KeyPopulationType,
		PreviousARTExposure,
		PreviousARTStartDate,
		NULL AS ContactRelation,
		cast(LastVisit as Date)LastVisit,
		StatusATCCC,
		statusAtPMTCT,
		statusAtTBClinic,
		PatientResidentCounty,
		PatientResidentSubCounty,
		PatientResidentLocation,
		PatientResidentSubLocation,
		PatientResidentWard,
		NULL AS [Age],
		P.Pkv AS MPIPKV,
		CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', UPPER(CAST(p.Nupi  as NVARCHAR(36)))), 2) as NupiHash		
		INTO [UCSFDWAPICentral].[dbo].[Patients]
		from Dwapicentral.dbo.PatientExtract(NoLock) p
		inner join Dwapicentral.dbo.facility(NoLock) f on p.FacilityId=f.Id and f.Voided=0
		Where f.Code>0 and Gender is not null  and p.gender!='Unknown' and p.Voided = 0


END
---- 3. ART Extracts

IF OBJECT_ID(N'[UCSFDWAPICentral].[dbo].[ART]', N'U') IS NOT NULL 

	BEGIN
		DROP TABLE [UCSFDWAPICentral].[dbo].[ART]
	END

	BEGIN	
		SELECT distinct
		NULL AS FacilityCode,
		NULL AS County,
		--p.PatientPID AS PatientPK
		ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientPID AS NVARCHAR(20))) AS PatientPK,
		--p.PatientCCCNumber  as PatientID,
		ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientCCCNumber AS NVARCHAR(20)))as PatientID,
		F.Code as SiteCode,
		cast(a.DOB as Date) DOB,
		cast(a.StartARTDate as Date)StartARTDate,
		cast(a.PreviousARTStartDate as Date)PreviousARTStartDate ,
		cast(a.StartARTAtThisFacility as Date) StartARTAtThisFacility,
		a.PreviousARTRegimen,
		a.StartRegimen,
		a.StartRegimenLine,
		cast(a.LastARTDate as Date)LastARTDate,
		a.LastRegimen,
		a.LastRegimenLine,
		a.Duration,
		a.ExpectedReturn,
		cast(a.LastVisit as Date) LastVisit,
		a.ExitReason,
		cast(a.ExitDate as Date) ExitDate
		INTO [UCSFDWAPICentral].[dbo].[ART]
		from Dwapicentral.dbo.PatientExtract(NoLock) p
		inner join Dwapicentral.dbo.PatientArtExtract(NoLock) a on a.PatientId=p.Id
		inner join Dwapicentral.dbo.facility(NoLock) f on p.FacilityId=f.Id AND f.Voided=0
		Where f.Code>0 and p.Gender is not null  and p.gender!='Unknown' and p.Voided = 0
	END

-- 4. LABS

IF OBJECT_ID(N'[UCSFDWAPICentral].[dbo].[Labs]', N'U') IS NOT NULL 

		BEGIN
			DROP TABLE [UCSFDWAPICentral].[dbo].[Labs]
		END

		BEGIN	
			Select 
			NULL AS FacilityCode,
			NULL AS County,
			a.VisitId,
			--p.PatientPID  AS PatientPK,
			ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientPID AS NVARCHAR(20))) AS PatientPK,
			--p.PatientCCCNumber  as PatientID,
			ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientCCCNumber AS NVARCHAR(20)))as PatientID,
			F.Code as SiteCode,
			cast(a.OrderedbyDate as Date)OrderedbyDate,
			cast(a.ReportedByDate as Date)ReportedByDate,
			TestName,
			TestResult,
			Reason
			INTO [UCSFDWAPICentral].[dbo].[Labs]
			from Dwapicentral.dbo.PatientExtract(NoLock) p
			inner join Dwapicentral.dbo.PatientLaboratoryExtract(NoLock) a on a.PatientId=p.Id
			inner join Dwapicentral.dbo.facility(NoLock) f on p.FacilityId=f.Id and f.Voided=0
			Where f.code>0 and p.Gender is not null  and p.gender!='Unknown' and p.Voided = 0
			
		END

-- 5. BASELINES

IF OBJECT_ID(N'[UCSFDWAPICentral].[dbo].[Baselines]', N'U') IS NOT NULL 

	BEGIN
		DROP TABLE [UCSFDWAPICentral].[dbo].[Baselines]
	END

	BEGIN
		Select 
		NULL AS FacilityCode,
		NULL AS County,
		--p.PatientPID AS PatientPK
		ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientPID AS NVARCHAR(20))) AS PatientPK,
		--p.PatientCCCNumber  as PatientID,
		ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientCCCNumber AS NVARCHAR(20)))as PatientID,
		F.Code as SiteCode,
		a.eCD4,
		cast(a.eCD4Date as Date)eCD4Date,
		a.eWHO,
		cast(a.eWHODate as Date)eWHODate,
		a.bCD4,
		cast(a.bCD4Date as Date)bCD4Date,
		a.bWHO,
		cast(a.bWHODate as Date)bWHODate,
		lastWHO,
		cast(a.lastWHODate as Date)lastWHODate,
		lastCD4,
		cast(a.lastCD4Date as Date)lastCD4Date,
		m12CD4,
		cast(a.m12CD4Date as Date)m12CD4Date,
		m6CD4,
		cast(a.m6CD4Date as Date)m6CD4Date,
		a.bWAB,
		cast(a.bWABDate as Date)bWABDate,
		lastWAB,
		cast(a.lastWABDate as Date)lastWABDate
		INTO [UCSFDWAPICentral].[dbo].[Baselines]
		from DWAPICEntral.dbo.PatientExtract(NoLock) p
		inner join DWAPICEntral.dbo.PatientBaselinesExtract(NoLock) a on a.PatientId=p.Id
		inner join DWAPICEntral.dbo.facility(NoLock) f on p.FacilityId=f.Id and f.Voided=0
		Where f.code>0 and p.Gender is not null  and p.gender!='Unknown' and p.Voided = 0
	END

-- 6. Patient Last Status

IF OBJECT_ID(N'[UCSFDWAPICentral].[dbo].[PatientStatus]', N'U') IS NOT NULL 

	BEGIN
		DROP TABLE [UCSFDWAPICentral].[dbo].[PatientStatus]
	END	

	BEGIN
		Select
		NULL AS FacilityCode,
		NULL AS County,
		--p.PatientPID AS PatientPK
		ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientPID AS NVARCHAR(20))) AS PatientPK,
		--p.PatientCCCNumber  as PatientID,
		ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientCCCNumber AS NVARCHAR(20)))as PatientID,
		F.Code as SiteCode,
		a.ExitReason,
		a.ExitDescription,
		cast(a.ExitDate as Date)ExitDate
		,a.ReasonForDeath
		,a.TOVerified
		,a.TOVerifiedDate
		,a.ReEnrollmentDate
		,a.SpecificDeathReason
		,a.DeathDate
		,a.EffectiveDiscontinuationDate
		INTO [UCSFDWAPICentral].[dbo].[PatientStatus]
		from Dwapicentral.dbo.PatientExtract(NoLock) p
		inner join Dwapicentral.dbo.PatientStatusExtract(NoLock) a on a.PatientId=p.Id
		inner join Dwapicentral.dbo.facility(NoLock) f on p.FacilityId=f.Id and f.Voided=0
		Where  f.Code>0 and p.Gender is not null  and p.gender!='Unknown' and p.Voided = 0
	END


-- 7. Pharmacy

IF OBJECT_ID(N'[UCSFDWAPICentral].[dbo].[Pharmacy]', N'U') IS NOT NULL 

	BEGIN
		DROP TABLE [UCSFDWAPICentral].[dbo].[Pharmacy]
	END
	BEGIN
			Select
			NULL AS FacilityCode,
			NULL AS County,
			--CAST(p.PatientPID AS NVARCHAR(50)) AS PatientPK,
			ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientPID AS NVARCHAR(20))) AS PatientPK,
			--p.PatientCCCNumber  as PatientID,
			ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientCCCNumber AS NVARCHAR(20)))as PatientID,
			F.Code as SiteCode,
			a.VisitID,
			a.Drug,
			cast(a.DispenseDate as Date)DispenseDate,
			Duration,
			cast(a.ExpectedReturn as Date)ExpectedReturn,
			TreatmentType,
			PeriodTaken,
			ProphylaxisType,
			Provider,
			RegimenLine
			INTO [UCSFDWAPICentral].[dbo].[Pharmacy]
			from Dwapicentral.dbo.PatientExtract p
			inner join Dwapicentral.dbo.PatientPharmacyExtract a on a.PatientId=p.Id
			inner join Dwapicentral.dbo.facility f on p.FacilityId=f.Id and f.Voided=0
			Where f.code>0 and p.Gender is not null  and p.gender!='Unknown' and p.Voided = 0;

	END


-- 8. Visits

IF OBJECT_ID(N'[UCSFDWAPICentral].[dbo].[Visits]', N'U') IS NOT NULL 

	BEGIN
		DROP TABLE [UCSFDWAPICentral].[dbo].[Visits]
	END
	BEGIN
			Select
			NULL AS FacilityCode,
			NULL AS County,
			--CAST(p.PatientPID AS NVARCHAR(50)) AS PatientPK,
			ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientPID AS NVARCHAR(20))) AS PatientPK,
			--p.PatientCCCNumber  as PatientID,
			ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientCCCNumber AS NVARCHAR(20)))as PatientID,
			a.VisitID,
			F.Code as SiteCode,
			cast(a.VisitDate as Date)VisitDate,
			a.Service,
			a.visitType,
			a.WhoStage,
			a.WabStage,
			a.Pregnant,
			cast(a.LMP as date) LMP,
			cast(a.EDD as date) EDD,
			a.Height,
			a.Weight,
			a.BP,
			a.OI,
			cast(a.OIDate as date) OIDate,
			cast(a.SubstitutionFirstLineRegimenDate as date) SubstitutionFirstLineRegimenDate,
			a.SubstitutionFirstLineRegimenReason,
			cast(a.SubstitutionSecondLineRegimenDate as date) SubstitutionSecondLineRegimenDate,
			a.SubstitutionSecondLineRegimenReason,
			cast(a.SecondLineRegimenChangeDate as date) SecondLineRegimenChangeDate,
			a.SecondLineRegimenChangeReason,
			Adherence,
			AdherenceCategory,
			FamilyPlanningMethod,
			PWP,
			GestationAge,
			StabilityAssessment,
			DifferentiatedCare,
			a.PopulationType,
			a.KeyPopulationType,
			cast(NextAppointmentDate as Date)NextAppointmentDate
			INTO [UCSFDWAPICentral].[dbo].[Visits]
			from Dwapicentral.dbo.PatientExtract(NoLock) p
			inner join Dwapicentral.dbo.PatientVisitExtract(NoLock) a on a.PatientId=p.Id
			inner join Dwapicentral.dbo.facility(NoLock) f on p.FacilityId=f.Id and f.Voided=0
			Where f.code>0 and p.Gender is not null  and p.gender!='Unknown' and p.Voided = 0

	END

	---IPT
	IF OBJECT_ID(N'[UCSFDWAPICentral].[dbo].[Ipt]', N'U') IS NOT NULL 
		BEGIN
			DROP TABLE [UCSFDWAPICentral].[dbo].[Ipt]
		END
		BEGIN
				SELECT DISTINCT
						--CAST(p.PatientPID AS NVARCHAR(50)) AS PatientPK,
						ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientPID AS NVARCHAR(20))) AS PatientPK,
						--p.PatientCCCNumber  as PatientID,
						ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientCCCNumber AS NVARCHAR(20)))as PatientID,
						F.Code AS SiteCode,F.Name AS FacilityName,
						IE.[VisitId] AS VisitID,IE.[VisitDate] AS VisitDate,P.[Emr] AS Emr,
						CASE
							P.[Project]
							WHEN 'I-TECH' THEN 'Kenya HMIS II'
							WHEN 'HMIS' THEN 'Kenya HMIS II'
							ELSE P.[Project]
						END AS Project,
						IE.[OnTBDrugs] AS OnTBDrugs,IE.[OnIPT] AS OnIPT,IE.[EverOnIPT] AS EverOnIPT,IE.[Cough] AS Cough,
						IE.[Fever] AS Fever,IE.[NoticeableWeightLoss] AS NoticeableWeightLoss,IE.[NightSweats] AS NightSweats,
						IE.[Lethargy] AS Lethargy,IE.[ICFActionTaken] AS ICFActionTaken,IE.[TestResult] AS TestResult,
						IE.[TBClinicalDiagnosis] AS TBClinicalDiagnosis,IE.[ContactsInvited] AS ContactsInvited,
						IE.[EvaluatedForIPT] AS EvaluatedForIPT,IE.[StartAntiTBs] AS StartAntiTBs,IE.[TBRxStartDate] AS TBRxStartDate,
						IE.[TBScreening] AS TBScreening,IE.[IPTClientWorkUp] AS IPTClientWorkUp,IE.[StartIPT] AS StartIPT,
						IE.[IndicationForIPT] AS IndicationForIPT
				
					   INTO [UCSFDWAPICentral].[dbo].[Ipt]
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[IptExtract](NoLock) IE ON IE.[PatientId] = P.ID AND IE.Voided = 0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
					WHERE P.gender != 'Unknown';
		END

	---DefaulterTracing

	IF OBJECT_ID(N'[UCSFDWAPICentral].[dbo].[DefaulterTracing]', N'U') IS NOT NULL 
		BEGIN
			DROP TABLE [UCSFDWAPICentral].[dbo].[DefaulterTracing]
		END
	BEGIN
			SELECT distinct 
						--p.PatientPID AS PatientPK
						ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientPID AS NVARCHAR(20))) AS PatientPK
						--p.PatientCCCNumber  as PatientID,
						,ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientCCCNumber AS NVARCHAR(20)))as PatientID
						  ,P.[Emr]
						  ,P.[Project]
						  ,F.Code AS SiteCode
						  ,F.Name AS FacilityName 
						  ,[VisitID]
						  ,Cast([VisitDate] As Date)[VisitDate]
						  ,[EncounterId]
						  ,[TracingType]
						  ,[TracingOutcome]
						  ,[AttemptNumber]
						  ,[IsFinalTrace]
						  ,[TrueStatus]
						  ,[CauseOfDeath]
						  ,[Comments]
						  ,Cast([BookingDate] As Date)[BookingDate]
						  INTO [UCSFDWAPICentral].[dbo].[DefaulterTracing]
					  FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
					  INNER JOIN [DWAPICentral].[dbo].[DefaulterTracingExtract](NoLock) C ON C.[PatientId]= P.ID AND C.Voided=0
					  INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0
					WHERE P.gender != 'Unknown' 
	END

------ ADD ROW Ids
	--BEGIN
	--		ALTER TABLE[UCSFDWAPICentral].[dbo]. Patients		ADD [LiveRowId] [bigint] IDENTITY(1,1) NOT NULL;		
	--		ALTER TABLE[UCSFDWAPICentral].[dbo]. ART				ADD [LiveRowId] [bigint] IDENTITY(1,1) NOT NULL;		
	--		ALTER TABLE[UCSFDWAPICentral].[dbo]. Baselines		ADD [LiveRowId] [bigint] IDENTITY(1,1) NOT NULL;		
	--		ALTER TABLE[UCSFDWAPICentral].[dbo]. PatientStatus	ADD [LiveRowId] [bigint] IDENTITY(1,1) NOT NULL;		
	--		ALTER TABLE [UCSFDWAPICentral].[dbo].Pharmacy		ADD [LiveRowId] [bigint] IDENTITY(1,1) NOT NULL;		
	--		ALTER TABLE [UCSFDWAPICentral].[dbo].Visits			ADD [LiveRowId] [bigint] IDENTITY(1,1) NOT NULL;		
	--		ALTER TABLE [UCSFDWAPICentral].[dbo].Labs			ADD [LiveRowId] [bigint] IDENTITY(1,1) NOT NULL;
	--END


--14. EnhancedAdherenceCounselling

IF OBJECT_ID(N'[UCSFDWAPICentral].[dbo].[EnhancedAdherenceCounselling]', N'U') IS NOT NULL 

	BEGIN
		DROP TABLE [UCSFDWAPICentral].[dbo].[EnhancedAdherenceCounselling]
	END
	BEGIN
			SELECT 
			--p.PatientPID AS PatientPK
			ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientPID AS NVARCHAR(20))) AS PatientPK,
			--p.PatientCCCNumber  as PatientID,
			ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientCCCNumber AS NVARCHAR(20)))as PatientID,			
			F.Code AS SiteCode,
			F.Name AS FacilityName,
			--NULL AS SatelliteName,
			EAC.[VisitId] AS VisitID,
			EAC.[VisitDate] AS VisitDate,
			P.[Emr] AS Emr,
			CASE
				P.[Project]
				WHEN 'I-TECH' THEN 'Kenya HMIS II'
				WHEN 'HMIS' THEN 'Kenya HMIS II'
				ELSE P.[Project]
			END AS Project,
			EAC.[SessionNumber] AS SessionNumber,
			EAC.[DateOfFirstSession] AS DateOfFirstSession,
			EAC.[PillCountAdherence] AS PillCountAdherence,
			EAC.[MMAS4_1] AS MMAS4_1,
			EAC.[MMAS4_2] AS MMAS4_2,
			EAC.[MMAS4_3] AS MMAS4_3,
			EAC.[MMAS4_4] AS MMAS4_4,
			EAC.[MMSA8_1] AS MMSA8_1,
			EAC.[MMSA8_2] AS MMSA8_2,
			EAC.[MMSA8_3] AS MMSA8_3,
			EAC.[MMSA8_4] AS MMSA8_4,
			EAC.[MMSAScore] AS MMSAScore,
			EAC.[EACRecievedVL] AS EACRecievedVL,
			EAC.[EACVL] AS EACVL,
			EAC.[EACVLConcerns] AS EACVLConcerns,
			EAC.[EACVLThoughts] AS EACVLThoughts,
			EAC.[EACWayForward] AS EACWayForward,
			EAC.[EACCognitiveBarrier] AS EACCognitiveBarrier,
			EAC.[EACBehaviouralBarrier_1] AS EACBehaviouralBarrier_1,
			EAC.[EACBehaviouralBarrier_2] AS EACBehaviouralBarrier_2,
			EAC.[EACBehaviouralBarrier_3] AS EACBehaviouralBarrier_3,
			EAC.[EACBehaviouralBarrier_4] AS EACBehaviouralBarrier_4,
			EAC.[EACBehaviouralBarrier_5] AS EACBehaviouralBarrier_5,
			EAC.[EACEmotionalBarriers_1] AS EACEmotionalBarriers_1,
			EAC.[EACEmotionalBarriers_2] AS EACEmotionalBarriers_2,
			EAC.[EACEconBarrier_1] AS EACEconBarrier_1,
			EAC.[EACEconBarrier_2] AS EACEconBarrier_2,
			EAC.[EACEconBarrier_3] AS EACEconBarrier_3,
			EAC.[EACEconBarrier_4] AS EACEconBarrier_4,
			EAC.[EACEconBarrier_5] AS EACEconBarrier_5,
			EAC.[EACEconBarrier_6] AS EACEconBarrier_6,
			EAC.[EACEconBarrier_7] AS EACEconBarrier_7,
			EAC.[EACEconBarrier_8] AS EACEconBarrier_8,
			EAC.[EACReviewImprovement] AS EACReviewImprovement,
			EAC.[EACReviewMissedDoses] AS EACReviewMissedDoses,
			EAC.[EACReviewStrategy] AS EACReviewStrategy,
			EAC.[EACReferral] AS EACReferral,
			EAC.[EACReferralApp] AS EACReferralApp,
			EAC.[EACReferralExperience] AS EACReferralExperience,
			EAC.[EACHomevisit] AS EACHomevisit,
			EAC.[EACAdherencePlan] AS EACAdherencePlan,
			EAC.[EACFollowupDate] AS EACFollowupDate,
			NULL AS Ident,
			GETDATE() AS DateImported
			-- EAC.[Voided],
			-- EAC.[Processed],
			-- EAC.[Created],
			---LTRIM(RTRIM(STR(F.Code))) + '-' + LTRIM(RTRIM(P.[PatientCccNumber])) + '-' + LTRIM(RTRIM(STR(P.[PatientPID]))) AS PKV
			-- 0 AS KnockOutRecord,
			--P.PatientPID AS PatientUID
			INTO [UCSFDWAPICentral].[dbo].[EnhancedAdherenceCounselling]
		FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
		INNER JOIN [DWAPICentral].[dbo].[EnhancedAdherenceCounsellingExtract](NoLock) EAC ON EAC.[PatientId] = P.ID AND EAC.Voided = 0
		INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
		WHERE P.gender != 'Unknown'  AND F.Code >0
	END


--19. DefaulterTracing

IF OBJECT_ID(N'[UCSFDWAPICentral].[dbo].[DefaulterTracing]', N'U') IS NOT NULL 

	BEGIN
		DROP TABLE [UCSFDWAPICentral].[dbo].[DefaulterTracing]
	END
	BEGIN
			SELECT 
				--p.PatientPID AS PatientPK
			ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientPID AS NVARCHAR(20))) AS PatientPK,
			--p.PatientCCCNumber  as PatientID,
			ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(p.PatientCCCNumber AS NVARCHAR(20)))as PatientID,
			  P.[Emr]
			  ,P.[Project]
			  ,F.Code AS SiteCode
			  ,F.Name AS FacilityName 
			  ,[VisitID]
			  ,Cast([VisitDate] As Date)[VisitDate]
			  ,[EncounterId]
			  ,[TracingType]
			  ,[TracingOutcome]
			  ,[AttemptNumber]
			  ,[IsFinalTrace]
			  ,[TrueStatus]
			  ,[CauseOfDeath]
			  ,[Comments]
			  ,Cast([BookingDate] As Date)[BookingDate]
			 ,getdate() as [DateImported] 
			INTO [UCSFDWAPICentral].[dbo].[DefaulterTracing]
		  FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
		  INNER JOIN [DWAPICentral].[dbo].[DefaulterTracingExtract](NoLock) C ON C.[PatientId]= P.ID AND C.Voided=0
		  INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0
		WHERE P.gender != 'Unknown'  AND F.Code > 0
	END
	
----------------------------------- END OF C&T
-----------------------------------HTS
----20. HTS_ClientLinkages

IF OBJECT_ID(N'[UCSFDWAPICentral].[dbo].[HTS_ClientLinkages]', N'U') IS NOT NULL 
	BEGIN
		DROP TABLE [UCSFDWAPICentral].[dbo].[HTS_ClientLinkages]
	END
	BEGIN
		SELECT 
	  
		  DISTINCT 
		  a.[FacilityName]
		  ,a.[SiteCode]
		 ,CAST(a.PatientPk AS NVARCHAR(50)) as PatientPk	
		--,ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(a.PatientPk AS NVARCHAR(20))) AS PatientPK
		,a.[HtsNumber]
		--,ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(a.[HtsNumber] AS NVARCHAR(20)))as HtsNumber		  			  
		  ,a.[Emr]
		  ,a.[Project]
		  ,[EnrolledFacilityName]
		  ,CAST ([ReferralDate] AS DATE) AS [ReferralDate]
		  ,CAST([DateEnrolled] AS DATE) AS [DateEnrolled]
 
		  ,CAST([DatePrefferedToBeEnrolled] AS DATE ) AS [DatePrefferedToBeEnrolled]
		  ,CASE WHEN [FacilityReferredTo]='Other Facility' THEN NULL ELSE [FacilityReferredTo] END AS [FacilityReferredTo] 
		  ,[HandedOverTo]
		  ,[HandedOverToCadre]
		  ,[ReportedCCCNumber]
		  --,ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST([ReportedCCCNumber] AS NVARCHAR(20)))as ReportedCCCNumber	
		  ,CASE WHEN CAST([ReportedStartARTDate] AS DATE) = '0001-01-01' THEN NULL ELSE CAST([ReportedStartARTDate] AS DATE) END AS [ReportedStartARTDate]
		INTO [UCSFDWAPICentral].[dbo].[HTS_ClientLinkages]
		 FROM [HTSCentral].[dbo].[ClientLinkages](NoLock) a
		 INNER JOIN (
						SELECT distinct SiteCode,PatientPK, MAX(DateExtracted) AS MaxDateExtracted
						FROM  [HTSCentral].[dbo].[ClientLinkages](NoLock)
						GROUP BY SiteCode,PatientPK
							) tm 
				     ON a.[SiteCode] = tm.[SiteCode] and a.PatientPK=tm.PatientPK and a.DateExtracted = tm.MaxDateExtracted
  INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
  on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode
  WHERE a.DateExtracted > '2019-09-08'
		GROUP BY a.[FacilityName]
		  ,a.[SiteCode]
		  ,a.[PatientPk]		  
		  ,a.[HtsNumber]
		  ,a.[Emr]
		  ,a.[Project]
		  --,CAST(a.[DateExtracted] AS DATE) 
		  ,[EnrolledFacilityName]
		  ,CAST([DateEnrolled] AS DATE)  
		  ,[FacilityReferredTo]
		   ,[HandedOverTo]
		  ,[HandedOverToCadre]
		  ,[ReportedCCCNumber]
		  ,[ReferralDate]
		  ,[DatePrefferedToBeEnrolled]
		  ,CAST([ReportedStartARTDate] AS DATE);

		  UPDATE cl
		SET PatientPk			=  ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(cl.PatientPk AS NVARCHAR(20))),
			[HtsNumber]			= ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(cl.[HtsNumber] AS NVARCHAR(20))),
			ReportedCCCNumber	= ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(cl.ReportedCCCNumber AS NVARCHAR(20)))
		FROM [UCSFDWAPICentral].[dbo].[HTS_ClientLinkages] cl

	END
--21. Hts_ClientTracing

IF OBJECT_ID(N'[UCSFDWAPICentral].[dbo].[Hts_ClientTracing]', N'U') IS NOT NULL 
	BEGIN
		DROP TABLE [UCSFDWAPICentral].[dbo].[Hts_ClientTracing]
	END
	BEGIN
			SELECT DISTINCT a.[FacilityName]
			  ,a.[SiteCode]
			 ,CAST(a.PatientPk AS NVARCHAR(50)) as PatientPk	
			 --,ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(a.PatientPk AS NVARCHAR(20))) AS PatientPK
			,a.[HtsNumber]
			--,ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(a.[HtsNumber] AS NVARCHAR(20)))as HtsNumber	
			  ,a.[Emr]
			  ,a.[Project]
			  ,[TracingType]
			  ,[TracingDate]
			  ,[TracingOutcome]
			  INTO [UCSFDWAPICentral].[dbo].[Hts_ClientTracing]
		 FROM [HTSCentral].[dbo].[HtsClientTracing] (NoLock)a
			INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
			on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode;

		UPDATE ct
		SET PatientPk =  ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(ct.PatientPk AS NVARCHAR(20))),
			[HtsNumber]= ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(ct.[HtsNumber] AS NVARCHAR(20)))
		FROM [UCSFDWAPICentral].[dbo].[Hts_ClientTracing] ct
	END

--22. HTS_Clients

	--DROP TABLE [NDWH].[dbo].[FactARTHistory];
	
IF OBJECT_ID(N'[UCSFDWAPICentral].[dbo].[HTS_Clients]', N'U') IS NOT NULL 
	BEGIN
		DROP TABLE [UCSFDWAPICentral].[dbo].[HTS_Clients]
	END
	BEGIN 
		SELECT  distinct [HtsNumber],
		  a.[Emr]
		  ,a.[Project]
		  ,CAST(a.PatientPk AS NVARCHAR(50)) as PatientPk	
		--,ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(a.PatientPk AS NVARCHAR(20))) AS PatientPK
		  ,a.[SiteCode]
		  ,[FacilityName]
		  ,[Serial]
		  ,CAST ([Dob] AS DATE) AS [Dob]
		  ,CASE WHEN LEFT([Gender],1)='M' THEN 'MALE'
			WHEN LEFT([Gender],1)='F' THEN 'FEMALE'
			WHEN LEFT([Gender],1)='1' THEN 'MALE'
			WHEN LEFT([Gender],1)='2' THEN 'FEMALE'END AS Gender
		  ,[MaritalStatus]
		  ,[KeyPopulationType]
		  ,CASE 
			WHEN [KeyPopulationType] IS NULL OR [KeyPopulationType] IN ('NA','N/A') THEN 'General Population' 
			WHEN[KeyPopulationType] IS NOT NULL AND [KeyPopulationType] NOT IN ('NA','N/A') THEN 'Key Population' END [PopulationType]
		  ,[PatientDisabled] AS [DisabilityType]
		  ,CASE WHEN [PatientDisabled] IS NOT NULL THEN 'Yes' ELSE 'No' END AS [PatientDisabled]
		  ,[County]
		  ,[SubCounty]
		  ,[Ward]
		  ,NUll NUPIHash
		  ,Pkv AS MPIPKV
		  INTO [UCSFDWAPICentral].[dbo].[HTS_Clients]
	  FROM [HTSCentral].[dbo].[Clients](NoLock) a
	  INNER JOIN (
					SELECT SiteCode,PatientPK, MAX(datecreated) AS Maxdatecreated
					FROM  [HTSCentral].[dbo].[Clients](NoLock)
					GROUP BY SiteCode,PatientPK
				) tm 
				ON a.[SiteCode] = tm.[SiteCode] and a.PatientPK=tm.PatientPK and a.datecreated = tm.Maxdatecreated
	where a.DateExtracted > '2019-09-08';

	UPDATE c
		SET PatientPk = ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(c.PatientPk AS NVARCHAR(20)))
		FROM [UCSFDWAPICentral].[dbo].[HTS_Clients]  c;

	END
--23. HTS_ClientTests
IF OBJECT_ID(N'[UCSFDWAPICentral].[dbo].[HTS_ClientTests]', N'U') IS NOT NULL 
	BEGIN
		DROP TABLE [UCSFDWAPICentral].[dbo].[HTS_ClientTests]
	END
	BEGIN
			SELECT distinct a.id, a.[FacilityName]
			  ,a.[SiteCode]
			  ,cast(a.PatientPk as nvarchar(50)) as PatientPk	
			--,ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(a.PatientPk AS NVARCHAR(20))) AS PatientPK
			  ,a.[Emr]
			  ,a.[Project]
			  ,a.[EncounterId]
			  ,a.[TestDate]
			  ,[EverTestedForHiv]
			  ,[MonthsSinceLastTest]
			  ,a.[ClientTestedAs]
			  ,[EntryPoint]
			  ,[TestStrategy]
			  ,[TestResult1]
			  ,[TestResult2]
			  ,a.[FinalTestResult]
			  ,[PatientGivenResult]
			  ,[TbScreening]
			  ,a.[ClientSelfTested]
			  ,a.[CoupleDiscordant]
			  ,a.[TestType]
			  ,[Consent]
			  INTO [UCSFDWAPICentral].[dbo].[HTS_ClientTests]
		  FROM [HTSCentral].[dbo].[HtsClientTests](NoLock) a
		  INNER JOIN ( select  ct.sitecode,ct.patientPK,ct.FinalTestResult,ct.TestDate,ct.EncounterId
										  ,max(DateExtracted)MaxDateExtracted  
									from [HTSCentral].[dbo].[HtsClientTests] ct	
									GROUP BY ct.sitecode,ct.patientPK,ct.FinalTestResult,ct.TestDate,ct.EncounterId
									)tn
			   ON  a.SiteCode = tn.SiteCode and a.PatientPk = tn.PatientPk and a.FinalTestResult = tn.FinalTestResult and a.TestDate = tn.TestDate
					and a.DateExtracted = tn.MaxDateExtracted --and a.EntryPoint = tn.EncounterId
			INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
			  on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode
			   where a.FinalTestResult is not null ;

		UPDATE ct
		SET PatientPk = ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(ct.PatientPk AS VARCHAR(max)))
		FROM [UCSFDWAPICentral].[dbo].[HTS_ClientTests]  ct
	END


--26. HTS_TestKits

IF OBJECT_ID(N'[UCSFDWAPICentral].[dbo].[HTS_TestKits]', N'U') IS NOT NULL 

	BEGIN
		DROP TABLE [UCSFDWAPICentral].[dbo].[HTS_TestKits]
	END
	BEGIN
		SELECT DISTINCT a.[FacilityName]
      ,a.[SiteCode]
	 ,CAST(a.PatientPk AS NVARCHAR(50)) as PatientPk	
		--,ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(a.PatientPk AS NVARCHAR(20))) AS PatientPK
		,a.[HtsNumber]
		--,ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(a.[HtsNumber] AS NVARCHAR(20)))as HtsNumber	
      ,a.[Emr]
      ,a.[Project]
      ,a.[EncounterId]
      ,a.[TestKitName1]
      ,a.[TestKitLotNumber1]
      ,[TestKitExpiry1]
      ,[TestResult1]
      ,a.[TestKitName2]
      ,a.[TestKitLotNumber2]
      ,[TestKitExpiry2]
      ,a.[TestResult2]
	  INTO [UCSFDWAPICentral].[dbo].[HTS_TestKits]
  FROM [HTSCentral].[dbo].[HtsTestKits](NoLock) a
  Inner join( select ct.sitecode,ct.patientPK,ct.[EncounterId],ct.[TestKitName1],ct.[TestResult2],ct.[TestKitLotNumber1],max(DateExtracted)MaxDateExtracted  from [HTSCentral].[dbo].[HtsTestKits] ct
									group by ct.sitecode,ct.patientPK,ct.[EncounterId],ct.[TestKitName1],ct.[TestResult2],ct.[TestKitLotNumber1])tn
									on a.sitecode = tn.sitecode and a.patientPK = tn.patientPK 
									and a.DateExtracted = tn.MaxDateExtracted
									and a.[EncounterId] = tn.[EncounterId]
									and a.[TestKitName1] =tn.[TestKitName1]
									and a.[TestResult2] =tn.[TestResult2]
									and a.[TestKitLotNumber1] = tn.[TestKitLotNumber1]
  INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
  on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode;
	
	UPDATE tk
		SET PatientPk = ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(tk.PatientPk AS NVARCHAR(20))),
			[HtsNumber]=ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(tk.[HtsNumber] AS NVARCHAR(20)))
		FROM [UCSFDWAPICentral].[dbo].[HTS_TestKits]  tk

	END


IF OBJECT_ID(N'[UCSFDWAPICentral].[dbo].[Hts_EligibilityExtract]', N'U') IS NOT NULL 

	BEGIN
		DROP TABLE [UCSFDWAPICentral].[dbo].[Hts_EligibilityExtract];
	END
BEGIN  
SELECT DISTINCT  a.[FacilityName]
      ,a.[SiteCode]
      ,CAST(a.PatientPk AS NVARCHAR(50)) as PatientPk	
	--,ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(a.PatientPk AS NVARCHAR(20))) AS PatientPK
		,a.[HtsNumber]
	--,ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(a.[HtsNumber] AS NVARCHAR(20)))as HtsNumber	
	  ,a.CccNumber
      ,a.[Emr]
      ,a.[Project]
      ,a.[Processed]
      ,a.[QueueId]
      ,a.[Status]
      ,a.[StatusDate]
      ,a.[EncounterId]
      ,a.[VisitID]
      ,a.[VisitDate]
      ,a.[PopulationType]
      ,[KeyPopulation]
      ,[PriorityPopulation]
      ,[Department]
      ,[PatientType]
      ,[IsHealthWorker]
      ,[RelationshipWithContact]
      ,[TestedHIVBefore]
      ,[WhoPerformedTest]
      ,[ResultOfHIV]
      ,[DateTestedSelf]
      ,[StartedOnART]
      ,[EverHadSex]
      ,[SexuallyActive]
      ,[NewPartner]
      ,[PartnerHIVStatus]
      ,a.[CoupleDiscordant]
      ,[MultiplePartners]
      ,[NumberOfPartners]
      ,[AlcoholSex]
      ,[MoneySex]
      ,[CondomBurst]
      ,[UnknownStatusPartner]
      ,[KnownStatusPartner]
      ,[Pregnant]
      ,[BreastfeedingMother]
      ,[ExperiencedGBV]
      ,[ContactWithTBCase]
      ,[Lethargy]
      ,[EverOnPrep]
      ,[CurrentlyOnPrep]
      ,[EverOnPep]
      ,[CurrentlyOnPep]
      ,[EverHadSTI]
      ,[CurrentlyHasSTI]
      ,[EverHadTB]
      ,[SharedNeedle]
      ,[NeedleStickInjuries]
      ,[TraditionalProcedures]
      ,[ChildReasonsForIneligibility]
      ,[EligibleForTest]
      ,[ReasonsForIneligibility]
      ,[SpecificReasonForIneligibility]
      ,a.[FacilityId]
      ,[Cough]
      ,[DateTestedProvider]
      ,[Fever]
      ,[MothersStatus]
      ,[NightSweats]
      ,[ReferredForTesting]
      ,[ResultOfHIVSelf]
      ,[ScreenedTB]
      ,[TBStatus]
      ,[WeightLoss]
      ,[AssessmentOutcome]
      ,[ForcedSex]
      ,[ReceivedServices]
      ,[TypeGBV]
      ,a.[DateCreated]
      ,[DateLastModified]
 
	  INTO [UCSFDWAPICentral].[dbo].Hts_EligibilityExtract 
  FROM [HTSCentral].[dbo].[HtsEligibilityExtract] (NoLock)a
  Inner join ( select ct.sitecode,ct.patientPK,ct.encounterID,ct.visitID,max(DateCreated)MaxDateCreated  from [HTSCentral].[dbo].[HtsEligibilityExtract] ct
									group by ct.sitecode,ct.patientPK,ct.encounterID,ct.visitID)tn
									on a.sitecode = tn.sitecode and a.patientPK = tn.patientPK
									and a.DateCreated = tn.MaxDateCreated
									and a.encounterID = tn.encounterID
									and a.visitID = tn.visitID
									
						Inner join ( select ct1.sitecode,ct1.patientPK,ct1.encounterID,ct1.visitID,max(ct1.DateExtracted)MaxDateExtracted  from [HTSCentral].[dbo].[HtsEligibilityExtract] ct1
									group by ct1.sitecode,ct1.patientPK,ct1.encounterID,ct1.visitID)tn1
									on a.sitecode = tn1.sitecode and a.patientPK = tn1.patientPK
									and a.DateExtracted = tn1.MaxDateExtracted
									and a.encounterID = tn1.encounterID
									and a.visitID = tn1.visitID
  INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
  on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode;

		UPDATE ee
		SET PatientPk = ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(ee.PatientPk AS NVARCHAR(20))),
			[HtsNumber]=ENCRYPTBYKEY(KEY_GUID('Key_NDW'), CAST(ee.[HtsNumber] AS NVARCHAR(20)))
		FROM [UCSFDWAPICentral].[dbo].[Hts_EligibilityExtract]  ee
  END

---------------------------------END OF HTS
exec CloseSession
-- THE END
END
go
exec [DataRequestUCSFDWAPICentral]
