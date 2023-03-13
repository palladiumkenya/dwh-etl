
BEGIN
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
							,P.Lastvisit
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
						WHERE p.gender!='Unknown') AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.exitdate = b.exitdate
						and a.ExitReason = b.ExitReason
						and a.Lastvisit = b.Lastvisit

						)
					WHEN NOT MATCHED THEN 
							INSERT(PatientID,SiteCode,FacilityName,Lastvisit,ExitDescription,ExitDate,ExitReason,PatientPK,Emr,Project,TOVerified,TOVerifiedDate,ReEnrollmentDate,DeathDate,EffectiveDiscontinuationDate,ReasonForDeath,SpecificDeathReason) 
							VALUES(PatientID,SiteCode,FacilityName,Lastvisit,ExitDescription,ExitDate,ExitReason,PatientPK,Emr,Project,TOVerified,TOVerifiedDate,ReEnrollmentDate,DeathDate,EffectiveDiscontinuationDate,ReasonForDeath,SpecificDeathReason)
			
						WHEN MATCHED THEN
							UPDATE SET 
								a.FacilityName					=b.FacilityName,
								a.ExitDescription				=b.ExitDescription,
								a.TOVerified					=b.TOVerified	,							
								a.ReasonForDeath				=b.ReasonForDeath,
								a.SpecificDeathReason			=b.SpecificDeathReason,
								a.DeathDate						=b.DeathDate;
						
							with cte AS (
									Select
									PatientPK,
									SiteCode,
									ExitDate,
									ExitReason,
									Lastvisit,

									 ROW_NUMBER() OVER (PARTITION BY PatientPK,ExitDate,SiteCode,ExitReason,Lastvisit ORDER BY
									ExitDate desc) Row_Num
									FROM [ODS].[dbo].[CT_PatientStatus]PS WITH (NoLock)
									)
								delete  from cte 
									Where Row_Num >1

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

