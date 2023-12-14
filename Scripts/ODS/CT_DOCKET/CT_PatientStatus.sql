
BEGIN
			;with cte AS ( Select      distinct      
			P.PatientPID,            
			PS.PatientId,            
			F.code,
			PS.exitdate,
			PS.ExitReason,
			p.Lastvisit,  ROW_NUMBER() OVER (PARTITION BY P.PatientPID,PS.PatientId,F.code,PS.exitdate ,PS.ExitReason,p.Lastvisit
			ORDER BY PS.exitdate desc) Row_Num
			FROM [DWAPICentral].[dbo].[PatientExtract] P WITH (NoLock)  
						INNER JOIN [DWAPICentral].[dbo].[PatientStatusExtract]PS WITH (NoLock)  ON PS.[PatientId]= P.ID AND PS.Voided=0
						INNER JOIN [DWAPICentral].[dbo].[Facility] F (NoLock)  ON P.[FacilityId] = F.Id AND F.Voided=0
						inner join (
									select P.PatientPID,F.code,exitdate,max(Ps.Created)MaxCreated FROM [DWAPICentral].[dbo].[PatientExtract] P WITH (NoLock)  
									INNER JOIN [DWAPICentral].[dbo].[PatientStatusExtract]PS WITH (NoLock)  ON PS.[PatientId]= P.ID AND PS.Voided=0
									INNER JOIN [DWAPICentral].[dbo].[Facility] F (NoLock)  ON P.[FacilityId] = F.Id AND F.Voided=0
									group by P.PatientPID,F.code,exitdate
								)tn
				on P.PatientPID = tn.PatientPID and f.code = tn.Code and PS.ExitDate = tn.ExitDate and PS.Created = tn.MaxCreated
						---INNER JOIN FacilityManifest_MaxDateRecieved(NoLock) a ON F.Code = a.SiteCode and a.[End] is not null and a.[Session] is not null
						WHERE p.gender!='Unknown')      
		
			delete pv from  [DWAPICentral].[dbo].[PatientStatusExtract] (NoLock) PV
			inner join [DWAPICentral].[dbo].[PatientExtract](NoLock) P ON PV.[PatientId]= P.ID AND PV.Voided = 0       
			inner join [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0       
			inner join cte on PV.PatientId = cte.PatientId  
				and cte.exitdate = PV.exitdate 
				and cte.Code =  f.Code     
				and cte.ExitReason = PV.ExitReason
		
			where  Row_Num  > 1;
			
			DECLARE		@MaxExitDate_Hist			DATETIME,
						@ExitDate					DATETIME
				
			SELECT @MaxExitDate_Hist =  MAX(MaxExitDate) FROM [ODS].[dbo].[CT_patientStatus_Log]  (NoLock);
			SELECT @ExitDate = MAX(ExitDate) FROM [DWAPICentral].[dbo].[PatientStatusExtract] WITH (NOLOCK) ;
		
					
			INSERT INTO  [ODS].[dbo].[CT_patientStatus_Log] (MaxExitDate,LoadStartDateTime)
			VALUES(@ExitDate,GETDATE());
	       ---- Refresh [ODS].[dbo].[CT_PatientStatus]

			MERGE [ODS].[dbo].[CT_PatientStatus] AS a
				USING(SELECT distinct  
							P.[PatientCccNumber] AS PatientID, 
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

						  ,PS.[Voided] Voided
						  ,PS.[Processed] Processed
						  ,PS.[Created] Created,
						[ReasonForDeath],
						[SpecificDeathReason],
						Cast([DeathDate] as Date)[DeathDate],
						EffectiveDiscontinuationDate,
						PS.TOVerified TOVerified,
						PS.TOVerifiedDate TOVerifiedDate,
						PS.ReEnrollmentDate ReEnrollmentDate
						,PS.[Date_Created],PS.[Date_Last_Modified]

						FROM [DWAPICentral].[dbo].[PatientExtract] P WITH (NoLock)  
						INNER JOIN [DWAPICentral].[dbo].[PatientStatusExtract]PS WITH (NoLock)  ON PS.[PatientId]= P.ID 
						INNER JOIN [DWAPICentral].[dbo].[Facility] F (NoLock)  ON P.[FacilityId] = F.Id AND F.Voided=0
						inner join (
									select P.PatientPID,F.code,exitdate,max(Ps.Created)MaxCreated FROM [DWAPICentral].[dbo].[PatientExtract] P WITH (NoLock)  
									INNER JOIN [DWAPICentral].[dbo].[PatientStatusExtract]PS WITH (NoLock)  ON PS.[PatientId]= P.ID 
									INNER JOIN [DWAPICentral].[dbo].[Facility] F (NoLock)  ON P.[FacilityId] = F.Id AND F.Voided=0
									group by P.PatientPID,F.code,exitdate
								)tn
				on P.PatientPID = tn.PatientPID and f.code = tn.Code and PS.ExitDate = tn.ExitDate and PS.Created = tn.MaxCreated						
						WHERE p.gender!='Unknown' AND F.code >0) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.exitdate = b.exitdate
						and a.ExitReason = b.ExitReason

						)
					WHEN NOT MATCHED THEN 
							INSERT(PatientID,SiteCode,FacilityName,ExitDescription,ExitDate,ExitReason,PatientPK,Emr,Project,TOVerified,TOVerifiedDate,ReEnrollmentDate,DeathDate,EffectiveDiscontinuationDate,ReasonForDeath,SpecificDeathReason,[Date_Created],[Date_Last_Modified],LoadDate)  
							VALUES(PatientID,SiteCode,FacilityName,ExitDescription,ExitDate,ExitReason,PatientPK,Emr,Project,TOVerified,TOVerifiedDate,ReEnrollmentDate,DeathDate,EffectiveDiscontinuationDate,ReasonForDeath,SpecificDeathReason,[Date_Created],[Date_Last_Modified],Getdate())
			
						WHEN MATCHED THEN
							UPDATE SET 
								a.[PatientID]						=	b.[PatientID],
								a.[FacilityName]					=	b.[FacilityName],
								a.[ExitDescription]					=	b.[ExitDescription],
								a.[ExitDate]						=	b.[ExitDate],
								a.[ExitReason]						=	b.[ExitReason],
								a.[Emr]								=	b.[Emr],
								a.[Project]							=	b.[Project],
								a.[TOVerified]						=	b.[TOVerified],
								a.[TOVerifiedDate]					=	b.[TOVerifiedDate],
								a.[ReEnrollmentDate]				=	b.[ReEnrollmentDate],
								a.[ReasonForDeath]					=	b.[ReasonForDeath],
								a.[SpecificDeathReason]				=	b.[SpecificDeathReason],
								a.[DeathDate]						=	b.[DeathDate],
								a.[EffectiveDiscontinuationDate]	=	b.[EffectiveDiscontinuationDate],
								a.[Date_Last_Modified]				=	b.[Date_Last_Modified],
								a.[Date_Created]					=	b.[Date_Created],
								a.[RecordUUID]						=	b.[RecordUUID],
								a.[voided]							=	b.[voided];
						
							

						UPDATE [ODS].[dbo].[CT_patientStatus_Log]
							SET LoadEndDateTime = GETDATE()
						WHERE MaxExitDate = @ExitDate;

						--truncate table [ODS].[dbo].[CT_PatientStatusCount_Log]

						INSERT INTO [ODS].[dbo].[CT_PatientStatusCount_Log]([SiteCode],[CreatedDate],[PatientStatusCount])
						SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS PatientStatusCount 
						FROM [ODS].[dbo].[CT_PatientStatus]  
						--WHERE @MaxCreatedDate  > @MaxCreatedDate
						GROUP BY SiteCode;

	END

