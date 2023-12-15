BEGIN
		DECLARE	@MaxVisitDate_Hist			DATETIME,
					@VisitDate					DATETIME
				
		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS].[dbo].[CT_DefaulterTracing_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[DefaulterTracingExtract](NoLock)		
					
		INSERT INTO  [ODS].[dbo].[CT_DefaulterTracing_Log](MaxVisitDate,LoadStartDateTime)
		VALUES(@MaxVisitDate_Hist,GETDATE())
	       ---- Refresh [ODS].[dbo].[CT_DefaulterTracing]
			MERGE [ODS].[dbo].[CT_DefaulterTracing] AS a
				USING(SELECT distinct P.[PatientPID] AS PatientPK
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
						  ,Cast([BookingDate] As Date)[BookingDate],
						  C.RecordUUID,C.voided
					 ,P.ID,C.[Date_Created],C.[Date_Last_Modified]
					  FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
					  INNER JOIN [DWAPICentral].[dbo].[DefaulterTracingExtract](NoLock) C ON C.[PatientId]= P.ID 
					  INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0
					WHERE P.gender != 'Unknown' AND F.code >0) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitID = b.VisitID
						and a.VisitDate = b.VisitDate
						and a.ID =b.ID
						)

					WHEN NOT MATCHED THEN 
						INSERT(ID,PatientPK,PatientID,Emr,Project,SiteCode,FacilityName,VisitID,VisitDate,EncounterId,TracingType,TracingOutcome,AttemptNumber,IsFinalTrace,TrueStatus,CauseOfDeath,Comments,BookingDate,[Date_Created],[Date_Last_Modified],RecordUUID,voided,LoadDate)  
						VALUES(ID,PatientPK,PatientID,Emr,Project,SiteCode,FacilityName,VisitID,VisitDate,EncounterId,TracingType,TracingOutcome,AttemptNumber,IsFinalTrace,TrueStatus,CauseOfDeath,Comments,BookingDate,[Date_Created],[Date_Last_Modified],RecordUUID,voided,Getdate())
				
					WHEN MATCHED THEN
						UPDATE SET 	
						a.[PatientID]			=	b.[PatientID],
						a.[FacilityName]		=	b.[FacilityName],
						a.[VisitID]				=	b.[VisitID],
						a.[VisitDate]			=	b.[VisitDate],
						a.[EncounterId]			=	b.[EncounterId],
						a.[TracingType]			=	b.[TracingType],
						a.[TracingOutcome]		=	b.[TracingOutcome],
						a.[AttemptNumber]		=	b.[AttemptNumber],
						a.[IsFinalTrace]		=	b.[IsFinalTrace],
						a.[TrueStatus]			=	b.[TrueStatus],
						a.[CauseOfDeath]		=	b.[CauseOfDeath],
						a.[Comments]			=	b.[Comments],
						a.[BookingDate]			=	b.[BookingDate],
						a.[Date_Last_Modified]	=	b.[Date_Last_Modified],
						a.[Date_Created]		=	b.[Date_Created],
						a.[RecordUUID]			=	b.[RecordUUID],
						a.[voided]				=	b.[voided];


				UPDATE [ODS].[dbo].[CT_DefaulterTracing_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @MaxVisitDate_Hist;

				INSERT INTO [ODS].[dbo].[CT_DefaulterTracingCount_Log]([SiteCode],[CreatedDate],[DefaulterTracingCount])
				SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS DefaulterTracingCount 
				FROM [ODS].[dbo].CT_DefaulterTracing
				--WHERE @MaxCreatedDate  > @MaxCreatedDate
				GROUP BY SiteCode;

	END
