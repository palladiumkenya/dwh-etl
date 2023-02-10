BEGIN
		DECLARE	@MaxVisitDate_Hist			DATETIME,
					@VisitDate					DATETIME
				
		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS].[dbo].[CT_DefaulterTracing_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[DefaulterTracingExtract](NoLock)		
					
		INSERT INTO  [ODS].[dbo].[CT_DefaulterTracing_Log](MaxVisitDate,LoadStartDateTime)
		VALUES(@MaxVisitDate_Hist,GETDATE())
			--CREATE INDEX CT_DefaulterTracing ON [ODS].[dbo].[CT_DefaulterTracing] (sitecode,PatientPK);
	       ---- Refresh [ODS].[dbo].[CT_DefaulterTracing]
			MERGE [ODS].[dbo].[CT_DefaulterTracing] AS a
				USING(SELECT P.[PatientPID] AS PatientPK
						  ,P.[PatientCccNumber] AS PatientID
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
						  ,LTRIM(RTRIM(STR(F.[Code])))+'-'+LTRIM(RTRIM(P.[PatientCccNumber]))+'-'+LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV
					 ,getdate() as [DateImported] 
					 ,P.ID as PatientUnique_ID
					 ,C.PatientID as UniquePatientDTracingID
					 ,C.ID as DefaulterTracingUnique_ID,
					 convert(nvarchar(64), hashbytes('SHA2_256', cast(P.[PatientPID]  as nvarchar(36))), 2) PatientPKHash,   
					convert(nvarchar(64), hashbytes('SHA2_256', cast(P.[PatientCccNumber]  as nvarchar(36))), 2) PatientIDHash,
					convert(nvarchar(64), hashbytes('SHA2_256', cast(LTRIM(RTRIM(STR(F.Code))) + '-' + LTRIM(RTRIM(P.[PatientCccNumber])) + '-' + LTRIM(RTRIM(STR(P.[PatientPID])))  as nvarchar(36))), 2) CKVHash

					  FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
					  INNER JOIN [DWAPICentral].[dbo].[DefaulterTracingExtract](NoLock) C ON C.[PatientId]= P.ID AND C.Voided=0
					  INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0
					WHERE P.gender != 'Unknown' ) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitID = b.VisitID
						and a.VisitDate = b.VisitDate
						and a.PatientUnique_ID =b.UniquePatientDTracingID
						--and a.DefaulterTracingUnique_ID = b.DefaulterTracingUnique_ID
						)

					WHEN NOT MATCHED THEN 
						INSERT(PatientPK,PatientID,Emr,Project,SiteCode,FacilityName,VisitID,VisitDate,EncounterId,TracingType,TracingOutcome,AttemptNumber,IsFinalTrace,TrueStatus,CauseOfDeath,Comments,BookingDate,CKV,DateImported,PatientUnique_ID,DefaulterTracingUnique_ID,PatientPKHash,PatientIDHash,CKVHash) 
						VALUES(PatientPK,PatientID,Emr,Project,SiteCode,FacilityName,VisitID,VisitDate,EncounterId,TracingType,TracingOutcome,AttemptNumber,IsFinalTrace,TrueStatus,CauseOfDeath,Comments,BookingDate,CKV,DateImported,PatientUnique_ID,DefaulterTracingUnique_ID,PatientPKHash,PatientIDHash,CKVHash)
				
					WHEN MATCHED THEN
						UPDATE SET 												
						a.FacilityName	=b.FacilityName,
						a.EncounterId	=b.EncounterId,
						a.TracingType	=b.TracingType,
						a.TracingOutcome=b.TracingOutcome,
						a.AttemptNumber	=b.AttemptNumber,
						a.IsFinalTrace	=b.IsFinalTrace,
						a.TrueStatus	=b.TrueStatus,
						a.CauseOfDeath	=b.CauseOfDeath,
						a.Comments		=b.Comments;

					--WHEN NOT MATCHED BY SOURCE 
					--	THEN
					--	/* The Record is in the target table but doen't exit on the source table*/
					--		Delete;
				--				WITH CTE AS   
				--	(  
				--		SELECT [PatientPK],[SiteCode],VisitID,ROW_NUMBER() 
				--		OVER (PARTITION BY [PatientPK],[SiteCode]
				--		ORDER BY [PatientPK],[SiteCode],VisitID) AS dump_ 
				--		FROM [ODS].[dbo].[CT_DefaulterTracing] 
				--		)  
			
				--DELETE FROM CTE WHERE dump_ >1;
				
				UPDATE [ODS].[dbo].[CT_DefaulterTracing_Log]---
					SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @MaxVisitDate_Hist;

				INSERT INTO [ODS].[dbo].[CT_DefaulterTracingCount_Log]([SiteCode],[CreatedDate],[DefaulterTracingCount])
				SELECT SiteCode,GETDATE(),COUNT(SiteCode) AS DefaulterTracingCount 
				FROM [ODS].[dbo].CT_DefaulterTracing
				--WHERE @MaxCreatedDate  > @MaxCreatedDate
				GROUP BY SiteCode;


				--DROP INDEX CT_DefaulterTracing ON [ODS].[dbo].[CT_DefaulterTracing];
				---Remove any duplicate from [ODS].[dbo].[CT_DefaulterTracing]

	END
