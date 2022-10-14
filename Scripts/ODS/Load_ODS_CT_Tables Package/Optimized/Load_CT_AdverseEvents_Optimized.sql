BEGIN
	       DECLARE @MaxAdverseEventStartDate_Hist			DATETIME,
				   @AdverseEventStartDate					DATETIME
				
		SELECT @MaxAdverseEventStartDate_Hist =  MAX(MaxAdverseEventStartDate) FROM [ODS].[dbo].[CT_AdverseEvent_Log]  (NoLock)
		SELECT @AdverseEventStartDate = MAX(AdverseEventStartDate) FROM [DWAPICentral].[dbo].PatientAdverseEventExtract	WITH (NOLOCK) 
		
		IF (SELECT COUNT(1) FROM [ODS].[dbo].[CT_AdverseEvent_Log](NoLock) WHERE MaxAdverseEventStartDate = @AdverseEventStartDate) > 0
		RETURN

			ELSE
				BEGIN
					
					INSERT INTO  [ODS].[dbo].[CT_AdverseEvent_Log](MaxAdverseEventStartDate,LoadStartDateTime)
					VALUES(@AdverseEventStartDate,GETDATE())

					INSERT INTO [ODS].[dbo].[CT_AdverseEvents](PatientID,Patientpk,SiteCode,AdverseEvent,AdverseEventStartDate,AdverseEventEndDate,Severity,VisitDate,EMR,Project,AdverseEventCause,AdverseEventRegimen,AdverseEventActionTaken,AdverseEventClinicalOutcome,dateimported,AdverseEventIsPregnant,CKV)
					SELECT 
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
							LTRIM(RTRIM(STR(F.Code)))+'-'+LTRIM(RTRIM(P.[PatientCccNumber])) +'-'+LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV

					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
					INNER JOIN [DWAPICentral].[dbo].PatientAdverseEventExtract(NoLock) PA ON PA.[PatientId]= P.ID AND PA.Voided=0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0
					WHERE AdverseEventStartDate > @MaxAdverseEventStartDate_Hist
					

					UPDATE [ODS].[dbo].[CT_AdverseEvent_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxAdverseEventStartDate = @AdverseEventStartDate;

			END
			---Remove any duplicate from [ODS].[dbo].[CT_AdverseEvents] 
			;WITH CTE AS   
				(  
					SELECT [PatientPK],[SiteCode],ROW_NUMBER() 
					OVER (PARTITION BY [PatientPK],[SiteCode]
					ORDER BY [PatientPK],[SiteCode]) AS dump_ 
					FROM [ODS].[dbo].[CT_AdverseEvents] 
					)  
			
			DELETE FROM CTE WHERE dump_ >1;

			
	END