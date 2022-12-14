BEGIN

		DECLARE	@MaxAdverseEventStartDate	DATETIME,
				@AdverseEventStartDate		DATETIME,
				@MaxCreatedDate				DATETIME
				
		SELECT @MaxAdverseEventStartDate		= MAX(MaxAdverseEventStartDate) FROM [ODS].[dbo].[CT_AdverseEvent_Log]  (NoLock);
		SELECT @AdverseEventStartDate	= MAX(AdverseEventStartDate)	FROM [DWAPICentral].[dbo].[PatientAdverseEventExtract] WITH (NOLOCK) ;
		SELECT @MaxCreatedDate		= MAX(CreatedDate)	FROM [ODS].[dbo].[CT_AdverseEventCount_Log] WITH (NOLOCK) ;
				
		--insert into  [ODS].[dbo].[CT_AdverseEventCount_Log](CreatedDate)
		--values(dateadd(year,-1,getdate()))
						
		INSERT INTO  [ODS].[dbo].[CT_AdverseEvent_Log](MaxAdverseEventStartDate,LoadStartDateTime)
		VALUES(@AdverseEventStartDate,GETDATE());

			--CREATE INDEX CT_AdverseEvents  ON [ODS].[dbo].[CT_AdverseEvents] (sitecode,PatientPK);
	       ---- Refresh [ODS].[dbo].[CT_AdverseEvents]
			MERGE [ODS].[dbo].[CT_AdverseEvents] AS a
				USING(SELECT 
							P.[PatientCccNumber] AS PatientID, 
							P.[PatientPID] AS PatientPK,
							F.Name AS FacilityName, 
							F.Code AS SiteCode,
							[AdverseEvent], [AdverseEventStartDate], [AdverseEventEndDate], 
							CASE [Severity]
								WHEN '1' THEN 'Mild'
								WHEN '2' THEN 'Moderate'
								WHEN '3' THEN 'Severe' 
								ELSE [Severity] 
							END AS [Severity] , 
							[VisitDate], 
							PA.[EMR], PA.[Project], [AdverseEventCause], [AdverseEventRegimen],
							[AdverseEventActionTaken],[AdverseEventClinicalOutcome], [AdverseEventIsPregnant], 
							LTRIM(RTRIM(STR(F.Code)))+'-'+LTRIM(RTRIM(P.[PatientCccNumber])) +'-'+LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV,
							GETDATE() AS dateimported
							,P.ID as PatientUnique_ID
							,PA.PatientId as UniquePatienAdverseEventsID
							,PA.ID as AdverseEventsUnique_ID
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
					INNER JOIN [DWAPICentral].[dbo].PatientAdverseEventExtract(NoLock) PA ON PA.[PatientId]= P.ID AND PA.Voided=0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0 ) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitDate	=b.VisitDate
						and a.PatientUnique_ID = b.UniquePatienAdverseEventsID
						and a.AdverseEventsUnique_ID = b.AdverseEventsUnique_ID)

					WHEN NOT MATCHED THEN 
						INSERT(PatientID,Patientpk,SiteCode,AdverseEvent,AdverseEventStartDate,AdverseEventEndDate,Severity,VisitDate,EMR,Project,AdverseEventCause,AdverseEventRegimen,AdverseEventActionTaken,AdverseEventClinicalOutcome,dateimported,AdverseEventIsPregnant,CKV,PatientUnique_ID,AdverseEventsUnique_ID) 
						VALUES(PatientID,Patientpk,SiteCode,AdverseEvent,AdverseEventStartDate,AdverseEventEndDate,Severity,VisitDate,EMR,Project,AdverseEventCause,AdverseEventRegimen,AdverseEventActionTaken,AdverseEventClinicalOutcome,dateimported,AdverseEventIsPregnant,CKV,PatientUnique_ID,AdverseEventsUnique_ID)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.PatientID						=b.PatientID,
							a.AdverseEvent					=b.AdverseEvent,
							a.AdverseEventStartDate			=b.AdverseEventStartDate,
							a.AdverseEventEndDate			=b.AdverseEventEndDate,
							a.Severity						=b.Severity,
							a.EMR							=b.EMR,
							a.Project						=b.Project,
							a.AdverseEventCause				=b.AdverseEventCause,
							a.AdverseEventRegimen			=b.AdverseEventRegimen,
							a.AdverseEventActionTaken		=b.AdverseEventActionTaken,
							a.AdverseEventClinicalOutcome	=b.AdverseEventClinicalOutcome,
							a.AdverseEventIsPregnant		=b.AdverseEventIsPregnant,
							a.CKV							=b.CKV		
					
					WHEN NOT MATCHED BY SOURCE 
						THEN
						/* The Record is in the target table but doen't exit on the source table*/
							Delete;

				UPDATE [ODS].[dbo].[CT_AdverseEvent_Log]
				  SET LoadEndDateTime = GETDATE()
				  WHERE MaxAdverseEventStartDate = @AdverseEventStartDate;

				--truncate table [ODS].[dbo].[CT_AdverseEventCount_Log]
				INSERT INTO [ODS].[dbo].[CT_AdverseEventCount_Log]([SiteCode],[CreatedDate],[AdverseEventCount])
				SELECT SiteCode,GETDATE(),COUNT(CKV) AS AdverseEventCount 
				FROM [ODS].[dbo].[CT_AdverseEvents] 
				--WHERE @MaxCreatedDate  > @MaxCreatedDate
				GROUP BY SiteCode;


							

					--DROP INDEX CT_AdverseEvents ON [ODS].[dbo].[CT_AdverseEvents];
					---Remove any duplicate from [ODS].[dbo].[CT_Patient]
					WITH CTE AS   
						(  
							SELECT [PatientPK],[SiteCode],VisitDate,PatientUnique_ID,AdverseEventsUnique_ID,ROW_NUMBER() 
							OVER (PARTITION BY [PatientPK],[SiteCode] ,VisitDate,PatientUnique_ID,AdverseEventsUnique_ID
							ORDER BY [PatientPK],[SiteCode],VisitDate,PatientUnique_ID,AdverseEventsUnique_ID) AS dump_ 
							FROM [ODS].[dbo].[CT_AdverseEvents] 
							)  
			
					DELETE FROM CTE WHERE dump_ >1;

	END