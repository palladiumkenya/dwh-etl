BEGIN
		DECLARE		@MaxVisitDate_Hist			DATETIME,
					@VisitDate					DATETIME
				
		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS].[dbo].[CT_DepressionScreening_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[DepressionScreeningExtract](NoLock)		
					
		INSERT INTO  [ODS].[dbo].[CT_DepressionScreening_Log](MaxVisitDate,LoadStartDateTime)
		VALUES(@MaxVisitDate_Hist,GETDATE())

	       ---- Refresh [ODS].[dbo].[CT_DepressionScreening]
			MERGE [ODS].[dbo].[CT_DepressionScreening]AS a
				USING(SELECT
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
						GETDATE() AS DateImported
						,P.ID as PatientUnique_ID
						,DS.PatientId as PatientDepressionScreeningID
						,DS.ID as DepressionScreeningUnique_ID
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[DepressionScreeningExtract](NoLock) DS ON DS.[PatientId] = P.ID AND DS.Voided = 0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
					WHERE P.gender != 'Unknown') AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitID = b.VisitID
						and a.VisitDate = b.VisitDate
						and a.PatientUnique_ID =b.PatientDepressionScreeningID
						)

					WHEN NOT MATCHED THEN 
						INSERT(PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,PHQ9_1,PHQ9_2,PHQ9_3,PHQ9_4,PHQ9_5,PHQ9_6,PHQ9_7,PHQ9_8,PHQ9_9,PHQ_9_rating,DepressionAssesmentScore,DateImported,PatientUnique_ID,DepressionScreeningUnique_ID) 
						VALUES(PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,PHQ9_1,PHQ9_2,PHQ9_3,PHQ9_4,PHQ9_5,PHQ9_6,PHQ9_7,PHQ9_8,PHQ9_9,PHQ_9_rating,DepressionAssesmentScore,DateImported,PatientUnique_ID,DepressionScreeningUnique_ID)
				
					WHEN MATCHED THEN
						UPDATE SET 
						a.FacilityName				=b.FacilityName,
						a.PHQ9_1					=b.PHQ9_1,
						a.PHQ9_2					=b.PHQ9_2,
						a.PHQ9_3					=b.PHQ9_3,
						a.PHQ9_4					=b.PHQ9_4,
						a.PHQ9_5					=b.PHQ9_5,
						a.PHQ9_6					=b.PHQ9_6,
						a.PHQ9_7					=b.PHQ9_7,
						a.PHQ9_8					=b.PHQ9_8,
						a.PHQ9_9					=b.PHQ9_9,
						a.PHQ_9_rating				=b.PHQ_9_rating,
						a.DepressionAssesmentScore	=b.DepressionAssesmentScore;

	
					UPDATE [ODS].[dbo].[CT_DepressionScreening_Log]
						SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @MaxVisitDate_Hist;

				INSERT INTO [ODS].[dbo].[CT_DepressionScreeningCount_Log]([SiteCode],[CreatedDate],[DepressionScreeningCount])
				SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS DepressionScreeningCount 
				FROM [ODS].[dbo].[CT_DepressionScreening] 
				--WHERE @MaxCreatedDate  > @MaxCreatedDate
				GROUP BY SiteCode;

	END