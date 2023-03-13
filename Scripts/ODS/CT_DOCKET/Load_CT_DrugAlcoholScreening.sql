BEGIN
		DECLARE		@MaxVisitDate_Hist			DATETIME,
					@VisitDate					DATETIME
				
		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS].[dbo].[CT_DrugAlcoholScreening_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[DrugAlcoholScreeningExtract] WITH (NOLOCK) 		
					
		INSERT INTO  [ODS].[dbo].[CT_DrugAlcoholScreening_Log](MaxVisitDate,LoadStartDateTime)
		VALUES(@VisitDate,GETDATE())

	       ---- Refresh [ODS].[dbo].[CT_DrugAlcoholScreening]
			MERGE [ODS].[dbo].[CT_DrugAlcoholScreening] AS a
				USING(SELECT distinct
							P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,F.Name AS FacilityName,
							DAS.[VisitId] AS VisitID,DAS.[VisitDate] AS VisitDate,P.[Emr] AS Emr,
							CASE
								P.[Project]
								WHEN 'I-TECH' THEN 'Kenya HMIS II'
								WHEN 'HMIS' THEN 'Kenya HMIS II'
								ELSE P.[Project]
							END AS Project,
							DAS.[DrinkingAlcohol] AS DrinkingAlcohol,DAS.[Smoking] AS Smoking,DAS.[DrugUse] AS DrugUse

							,DAS.ID 
						FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
						INNER JOIN [DWAPICentral].[dbo].[DrugAlcoholScreeningExtract](NoLock) DAS ON DAS.[PatientId] = P.ID AND DAS.Voided = 0
						INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
						WHERE P.gender != 'Unknown') AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitID = b.VisitID
						and a.VisitDate	=b.VisitDate
						and a.ID =b.ID
						)
					
					WHEN NOT MATCHED THEN 
						INSERT(ID,PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,DrinkingAlcohol,Smoking,DrugUse) 
						VALUES(ID,PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,DrinkingAlcohol,Smoking,DrugUse)
				
					WHEN MATCHED THEN
						UPDATE SET 
						a.FacilityName		=b.FacilityName,					
						a.DrinkingAlcohol	=b.DrinkingAlcohol,
						a.Smoking			=b.Smoking,
						a.DrugUse			=b.DrugUse;		
						
						with cte AS (
						Select
						PatientPK,
						Sitecode,
						visitID,
						visitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,visitDate ORDER BY
						visitDate desc) Row_Num
						FROM [ODS].[dbo].[CT_DrugAlcoholScreening](NoLock)
						)
					delete from cte 
						Where Row_Num >1 ;
					
					UPDATE [ODS].[dbo].[CT_DrugAlcoholScreening_Log]
						SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @VisitDate;

				INSERT INTO [ODS].[dbo].[CT_DrugAlcoholScreeningCount_Log]([SiteCode],[CreatedDate],[DrugAlcoholScreeningCount])
				SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS DrugAlcoholScreeningCount 
				FROM [ODS].[dbo].[CT_DrugAlcoholScreening] 
				GROUP BY [SiteCode];


	END
