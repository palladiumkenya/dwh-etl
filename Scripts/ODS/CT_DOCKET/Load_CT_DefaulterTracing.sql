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
						  ,Cast([BookingDate] As Date)[BookingDate]
					 ,P.ID 
					  FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
					  INNER JOIN [DWAPICentral].[dbo].[DefaulterTracingExtract](NoLock) C ON C.[PatientId]= P.ID AND C.Voided=0
					  INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0
					WHERE P.gender != 'Unknown' ) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitID = b.VisitID
						and a.VisitDate = b.VisitDate
						and a.ID =b.ID
						)

					WHEN NOT MATCHED THEN 
						INSERT(ID,PatientPK,PatientID,Emr,Project,SiteCode,FacilityName,VisitID,VisitDate,EncounterId,TracingType,TracingOutcome,AttemptNumber,IsFinalTrace,TrueStatus,CauseOfDeath,Comments,BookingDate) 
						VALUES(ID,PatientPK,PatientID,Emr,Project,SiteCode,FacilityName,VisitID,VisitDate,EncounterId,TracingType,TracingOutcome,AttemptNumber,IsFinalTrace,TrueStatus,CauseOfDeath,Comments,BookingDate)
				
					WHEN MATCHED THEN
						UPDATE SET 												
						a.FacilityName	=b.FacilityName,
						a.TracingType	=b.TracingType,
						a.TracingOutcome=b.TracingOutcome,
						a.AttemptNumber	=b.AttemptNumber,
						a.IsFinalTrace	=b.IsFinalTrace,
						a.TrueStatus	=b.TrueStatus,
						a.CauseOfDeath	=b.CauseOfDeath,
						a.Comments		=b.Comments;

						with cte AS (
							Select
							PatientPK,
							Sitecode,
							visitID,
							visitDate,

								ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,visitDate ORDER BY
							PatientPK,Sitecode,visitID,visitDate) Row_Num
							FROM [ODS].[dbo].[CT_DefaulterTracing](NoLock))
							
							delete from cte 
								Where Row_Num >1 ;

				
				UPDATE [ODS].[dbo].[CT_DefaulterTracing_Log]---
					SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @MaxVisitDate_Hist;

				INSERT INTO [ODS].[dbo].[CT_DefaulterTracingCount_Log]([SiteCode],[CreatedDate],[DefaulterTracingCount])
				SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS DefaulterTracingCount 
				FROM [ODS].[dbo].CT_DefaulterTracing
				--WHERE @MaxCreatedDate  > @MaxCreatedDate
				GROUP BY SiteCode;

	END
