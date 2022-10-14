BEGIN
	       DECLARE @MaxVisitDate_Hist			DATETIME,
				   @VisitDate					DATETIME
				
		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS].[dbo].[CT_DrugAlcoholScreening_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[DrugAlcoholScreeningExtract] WITH (NOLOCK) 
		
		IF (SELECT COUNT(1) FROM [ODS].[dbo].[CT_DrugAlcoholScreening_Log](NoLock) WHERE MaxVisitDate = @VisitDate) > 0
		RETURN

			ELSE
				BEGIN
					
					INSERT INTO  [ODS].[dbo].[CT_DrugAlcoholScreening_Log](MaxVisitDate,LoadStartDateTime)
					VALUES(@VisitDate,GETDATE())

					INSERT INTO [ODS].[dbo].[CT_DrugAlcoholScreening](PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,
					Project,DrinkingAlcohol,Smoking,DrugUse,DateImported,CKV)
					SELECT
							P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,F.Name AS FacilityName,
							DAS.[VisitId] AS VisitID,DAS.[VisitDate] AS VisitDate,P.[Emr] AS Emr,
							CASE
								P.[Project]
								WHEN 'I-TECH' THEN 'Kenya HMIS II'
								WHEN 'HMIS' THEN 'Kenya HMIS II'
								ELSE P.[Project]
							END AS Project,
							DAS.[DrinkingAlcohol] AS DrinkingAlcohol,DAS.[Smoking] AS Smoking,DAS.[DrugUse] AS DrugUse,
							GETDATE() AS DateImported,
							LTRIM(RTRIM(STR(F.Code))) + '-' + LTRIM(RTRIM(P.[PatientCccNumber])) + '-' + LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV

						FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
						INNER JOIN [DWAPICentral].[dbo].[DrugAlcoholScreeningExtract](NoLock) DAS ON DAS.[PatientId] = P.ID AND DAS.Voided = 0
						INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
						WHERE P.gender != 'Unknown' and VisitDate > @MaxVisitDate_Hist					

					UPDATE [ODS].[dbo].[CT_DrugAlcoholScreening_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @VisitDate;

			END
			---Remove any duplicate from [ODS].[dbo].[CT_DrugAlcoholScreening]
			;WITH CTE AS   
				(  
					SELECT [PatientPK],[SiteCode],VisitDate,ROW_NUMBER() 
					OVER (PARTITION BY [PatientPK],[SiteCode],VisitDate
					ORDER BY [PatientPK],[SiteCode],VisitDate) AS dump_ 
					FROM [ODS].[dbo].[CT_DrugAlcoholScreening]
					)  
			
			DELETE FROM CTE WHERE dump_ >1;

			
	END