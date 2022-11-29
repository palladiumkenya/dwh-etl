BEGIN
	       DECLARE @MaxVisitDate_Hist			DATETIME,
				   @VisitDate					DATETIME
				
		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS].[dbo].[CT_DefaulterTracing_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[DefaulterTracingExtract](NoLock)
		
		IF (SELECT COUNT(1) FROM [ODS].[dbo].[CT_DefaulterTracing_Log](NoLock) WHERE MaxVisitDate = @MaxVisitDate_Hist) > 0
		RETURN

			ELSE
				BEGIN
					
					INSERT INTO  [ODS].[dbo].[CT_DefaulterTracing_Log](MaxVisitDate,LoadStartDateTime)
					VALUES(@MaxVisitDate_Hist,GETDATE())

					INSERT INTO [ODS].[dbo].[CT_DefaulterTracing](PatientPK,PatientID,Emr,Project,SiteCode,FacilityName,VisitID,VisitDate,EncounterId,TracingType,TracingOutcome,AttemptNumber,IsFinalTrace,TrueStatus,CauseOfDeath,Comments,BookingDate,CKV,DateImported)
					SELECT P.[PatientPID] AS PatientPK
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
					  FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
					  INNER JOIN [DWAPICentral].[dbo].[DefaulterTracingExtract](NoLock) C ON C.[PatientId]= P.ID AND C.Voided=0
					  INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0
					WHERE P.gender != 'Unknown'    and VisitDate > @MaxVisitDate_Hist					

					UPDATE [ODS].[dbo].[CT_DefaulterTracing_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @MaxVisitDate_Hist;

			END
			---Remove any duplicate from [ODS].[dbo].[CT_DefaulterTracing]
			;WITH CTE AS   
				(  
					SELECT [PatientPK],[SiteCode],ROW_NUMBER() 
					OVER (PARTITION BY [PatientPK],[SiteCode]
					ORDER BY [PatientPK],[SiteCode]) AS dump_ 
					FROM [ODS].[dbo].[CT_DefaulterTracing]
					)  
			
			DELETE FROM CTE WHERE dump_ >1;

			
	END