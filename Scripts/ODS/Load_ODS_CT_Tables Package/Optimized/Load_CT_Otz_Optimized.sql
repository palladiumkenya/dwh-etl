BEGIN
	       DECLARE @MaxVisitDate_Hist			DATETIME,
				   @VisitDate					DATETIME
				
		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS].[dbo].[CT_Otz_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[OtzExtract](NoLock)
		
		IF (SELECT COUNT(1) FROM [ODS].[dbo].[CT_Otz_Log](NoLock) WHERE MaxVisitDate = @MaxVisitDate_Hist) > 0
		RETURN

			ELSE
				BEGIN
					
					INSERT INTO  [ODS].[dbo].[CT_Otz_Log](MaxVisitDate,LoadStartDateTime)
					VALUES(@MaxVisitDate_Hist,GETDATE())

					INSERT INTO [ODS].[dbo].[CT_Otz](PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,
					OTZEnrollmentDate,TransferInStatus,ModulesPreviouslyCovered,ModulesCompletedToday,SupportGroupInvolvement,Remarks,TransitionAttritionReason,OutcomeDate,DateImported,CKV)
					SELECT
						P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,F.Name AS FacilityName,OE.[VisitId] AS VisitID,
						OE.[VisitDate] AS VisitDate,P.[Emr] AS Emr,
						CASE
							P.[Project]
							WHEN 'I-TECH' THEN 'Kenya HMIS II'
							WHEN 'HMIS' THEN 'Kenya HMIS II'
							ELSE P.[Project]
						END AS Project,
						OE.[OTZEnrollmentDate],OE.[TransferInStatus],OE.[ModulesPreviouslyCovered],OE.[ModulesCompletedToday],OE.[SupportGroupInvolvement],OE.[Remarks],
						OE.[TransitionAttritionReason],
						OE.[OutcomeDate],
						GETDATE() AS DateImported,
						LTRIM(RTRIM(STR(F.Code))) + '-' + LTRIM(RTRIM(P.[PatientCccNumber])) + '-' + LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[OtzExtract](NoLock) OE ON OE.[PatientId] = P.ID AND OE.Voided = 0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
					WHERE P.gender != 'Unknown'   and VisitDate > @MaxVisitDate_Hist					

					UPDATE [ODS].[dbo].[CT_Otz_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @MaxVisitDate_Hist;

			END
			---Remove any duplicate from [ODS].[dbo].[CT_Otz]
			;WITH CTE AS   
				(  
					SELECT [PatientPK],[SiteCode],ROW_NUMBER() 
					OVER (PARTITION BY [PatientPK],[SiteCode]
					ORDER BY [PatientPK],[SiteCode]) AS dump_ 
					FROM [ODS].[dbo].[CT_Otz]
					)  
			
			DELETE FROM CTE WHERE dump_ >1;

			
	END