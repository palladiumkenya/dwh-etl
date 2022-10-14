BEGIN
	       DECLARE @MaxVisitDate_Hist			DATETIME,
				   @VisitDate					DATETIME
				
		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS].[dbo].[CT_DepressionScreening_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[DepressionScreeningExtract](NoLock)
		
		IF (SELECT COUNT(1) FROM [ODS].[dbo].[CT_DepressionScreening_Log](NoLock) WHERE MaxVisitDate = @MaxVisitDate_Hist) > 0
		RETURN

			ELSE
				BEGIN
					
					INSERT INTO  [ODS].[dbo].[CT_DepressionScreening_Log](MaxVisitDate,LoadStartDateTime)
					VALUES(@MaxVisitDate_Hist,GETDATE())

					INSERT INTO [ODS].[dbo].[CT_DepressionScreening](PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,PHQ9_1,PHQ9_2,PHQ9_3,PHQ9_4,PHQ9_5,PHQ9_6,PHQ9_7,PHQ9_8,PHQ9_9,PHQ_9_rating,DepressionAssesmentScore,DateImported,CKV)
					SELECT
						P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,F.Name AS FacilityName,
						DS.[VisitId] AS VisitID,DS.[VisitDate] AS VisitDate,P.[Emr],
						CASE
							P.[Project]
							WHEN 'I-TECH' THEN 'Kenya HMIS II'
							WHEN 'HMIS' THEN 'Kenya HMIS II'
							ELSE P.[Project]
						END AS Project,
						DS.[PHQ9_1],DS.[PHQ9_2],DS.[PHQ9_3],DS.[PHQ9_4],DS.[PHQ9_5],DS.[PHQ9_6],DS.[PHQ9_7],
						DS.[PHQ9_8],DS.[PHQ9_9],DS.[PHQ_9_rating],DS.[DepressionAssesmentScore],
						GETDATE() AS DateImported,
						-- DS.[Voided],
						-- DS.[Processed],
						-- DS.[Created],
						LTRIM(RTRIM(STR(F.Code))) + '-' + LTRIM(RTRIM(P.[PatientCccNumber])) + '-' + LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[DepressionScreeningExtract](NoLock) DS ON DS.[PatientId] = P.ID AND DS.Voided = 0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
					WHERE P.gender != 'Unknown'  and VisitDate > @MaxVisitDate_Hist					

					UPDATE [ODS].[dbo].[CT_DepressionScreening_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @MaxVisitDate_Hist;

			END
			---Remove any duplicate from [ODS].[dbo].[CT_DepressionScreening]
			;WITH CTE AS   
				(  
					SELECT [PatientPK],[SiteCode],ROW_NUMBER() 
					OVER (PARTITION BY [PatientPK],[SiteCode]
					ORDER BY [PatientPK],[SiteCode]) AS dump_ 
					FROM [ODS].[dbo].[CT_DepressionScreening]
					)  
			
			DELETE FROM CTE WHERE dump_ >1;

			
	END