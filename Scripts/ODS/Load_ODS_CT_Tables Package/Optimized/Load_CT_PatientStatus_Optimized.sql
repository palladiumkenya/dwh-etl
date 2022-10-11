BEGIN
		DECLARE		@MaxExitDate_Hist			DATETIME,
					@ExitDate					DATETIME
				
		SELECT @MaxExitDate_Hist =  MAX(MaxExitDate) FROM [ODS].[dbo].[CT_LopatientStatus_Log]  (NoLock);
		SELECT @ExitDate = MAX(ExitDate) FROM [DWAPICentral].[dbo].[PatientStatusExtract] WITH (NOLOCK) ;
		
		IF (SELECT COUNT(1) FROM [ODS].[dbo].[CT_LopatientStatus_Log] (NoLock) WHERE MaxExitDate = @ExitDate) > 0
		RETURN

			ELSE
				BEGIN
					
					INSERT INTO  [ODS].[dbo].[CT_PharmacyVisit_Log](MaxDispenseDate,LoadStartDateTime)
					VALUES(@ExitDate,GETDATE());
	       ---- Refresh [ODS].[dbo].[CT_PatientStatus]
		   INSERT INTO [ODS].[dbo].[CT_PatientStatus](PatientID,PatientPK,FacilityName,SiteCode,ExitDescription,ExitDate,ExitReason,Emr,Project,
		   CKV,TOVerified,TOVerifiedDate,ReEnrollmentDate,ReasonForDeath,SpecificDeathReason,DeathDate,EffectiveDiscontinuationDate)
			SELECT P.[PatientCccNumber] AS PatientID, 
							P.[PatientPID] AS PatientPK,
							F.Name AS FacilityName, 
							F.Code AS SiteCode
							,PS.[ExitDescription] ExitDescription
							,PS.[ExitDate] ExitDate
							,PS.[ExitReason] ExitReason
							,P.[Emr] Emr
							,CASE P.[Project] 
								WHEN 'I-TECH' THEN 'Kenya HMIS II' 
								WHEN 'HMIS' THEN 'Kenya HMIS II'
							ELSE P.[Project] 
							END AS [Project] 
							,LTRIM(RTRIM(STR(F.Code)))+'-'+LTRIM(RTRIM(P.[PatientCccNumber])) +'-'+LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV--Previously PKV
						  --,PS.[Voided] Voided
						  --,PS.[Processed] Processed
						  --,PS.[Created] Created
						  ,PS.TOVerified TOVerified
						,PS.TOVerifiedDate TOVerifiedDate
						,PS.ReEnrollmentDate ReEnrollmentDate

						,[ReasonForDeath]
						,[SpecificDeathReason]
						,Cast([DeathDate] as Date)[DeathDate]
						,EffectiveDiscontinuationDate
						
						FROM [DWAPICentral].[dbo].[PatientExtract] P WITH (NoLock)  
						INNER JOIN [DWAPICentral].[dbo].[PatientStatusExtract]PS WITH (NoLock)  ON PS.[PatientId]= P.ID AND PS.Voided=0
						INNER JOIN [DWAPICentral].[dbo].[Facility] F (NoLock)  ON P.[FacilityId] = F.Id AND F.Voided=0
						---INNER JOIN FacilityManifest_MaxDateRecieved(NoLock) a ON F.Code = a.SiteCode and a.[End] is not null and a.[Session] is not null
						WHERE p.gender!='Unknown' AND ExitDate > @MaxExitDate_Hist;

						UPDATE [ODS].[dbo].[CT_LopatientStatus_Log]
						SET LoadEndDateTime = GETDATE()
						WHERE MaxExitDate = @ExitDate;
				END
			---Remove any duplicate from [NDWH_DB].[dbo].[DimPatient]
			;WITH CTE AS   
				(  
					SELECT [PatientPK],[SiteCode],ExitDate,EffectiveDiscontinuationDate,ROW_NUMBER() 
					OVER (PARTITION BY [PatientPK],[SiteCode],ExitDate ,EffectiveDiscontinuationDate
					ORDER BY [PatientPK],[SiteCode],ExitDate,EffectiveDiscontinuationDate) AS dump_ 
					FROM [ODS].[dbo].[CT_PatientStatus] 
					)  
			
			DELETE FROM CTE WHERE dump_ >1;

			
	END