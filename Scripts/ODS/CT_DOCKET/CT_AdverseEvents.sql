BEGIN

				;with cte AS ( Select            
					P.PatientPID,            
					PA.PatientId,            
					F.code,
					PA.VisitDate,
					PA.created,  ROW_NUMBER() OVER (PARTITION BY P.PatientPID,F.code ,PA.VisitDate
					ORDER BY PA.created desc) Row_Num
				FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
					INNER JOIN [DWAPICentral].[dbo].PatientAdverseEventExtract(NoLock) PA ON PA.[PatientId]= P.ID AND PA.Voided=0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0 )      
		
			delete pb from     [DWAPICentral].[dbo].PatientAdverseEventExtract(NoLock) pb
			inner join [DWAPICentral].[dbo].[PatientExtract](NoLock) P ON PB.[PatientId]= P.ID AND PB.Voided = 0       
			inner join [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0       
			inner join cte on pb.PatientId = cte.PatientId  
				and cte.Created = pb.created 
				and cte.Code =  f.Code     
				and cte.VisitDate = pb.VisitDate
			where  Row_Num  > 1;


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
				USING(SELECT Distinct
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
							[AdverseEventActionTaken],[AdverseEventClinicalOutcome], [AdverseEventIsPregnant]
							,PA.ID
							,PA.[Date_Created]
						  ,PA.[Date_Last_Modified]

					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
					INNER JOIN [DWAPICentral].[dbo].PatientAdverseEventExtract(NoLock) PA ON PA.[PatientId]= P.ID AND PA.Voided=0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0 AND F.code >0 ) AS b 
						ON(
						 a.SiteCode = b.SiteCode
						and  a.PatientPK  = b.PatientPK 
						and a.VisitDate	=b.VisitDate
						and a.ID = b.ID
						)

					WHEN NOT MATCHED THEN 
						INSERT(PatientID,Patientpk,SiteCode,AdverseEvent,AdverseEventStartDate,AdverseEventEndDate,Severity,VisitDate,EMR,Project,AdverseEventCause,AdverseEventRegimen,AdverseEventActionTaken,AdverseEventClinicalOutcome,AdverseEventIsPregnant,[Date_Created],[Date_Last_Modified],LoadDate)  
						VALUES(PatientID,Patientpk,SiteCode,AdverseEvent,AdverseEventStartDate,AdverseEventEndDate,Severity,VisitDate,EMR,Project,AdverseEventCause,AdverseEventRegimen,AdverseEventActionTaken,AdverseEventClinicalOutcome,AdverseEventIsPregnant,[Date_Created],[Date_Last_Modified],Getdate())
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.EMR							=b.EMR,
							a.Project						=b.Project,
							a.PatientID						=b.PatientID,
							a.AdverseEventIsPregnant		=b.AdverseEventIsPregnant,
							a.[Date_Created]				=b.[Date_Created],
							a.[Date_Last_Modified]			=b.[Date_Last_Modified];	

					-----Remove duplicates from CT_AdverseEvents
					
			--------------------------------------------------------End
				UPDATE [ODS].[dbo].[CT_AdverseEvent_Log]
				  SET LoadEndDateTime = GETDATE()
				  WHERE MaxAdverseEventStartDate = @AdverseEventStartDate;

				--truncate table [ODS].[dbo].[CT_AdverseEventCount_Log]
				INSERT INTO [ODS].[dbo].[CT_AdverseEventCount_Log]([SiteCode],[CreatedDate],[AdverseEventCount])
				SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS AdverseEventCount 
				FROM [ODS].[dbo].[CT_AdverseEvents] 
				--WHERE @MaxCreatedDate  > @MaxCreatedDate
				GROUP BY SiteCode;

	END
