BEGIN
			DECLARE @MaxDispenseDate_Hist			DATETIME,
				  @DispenseDate					DATETIME,
				  @MaxCreatedDate				DATETIME

			SELECT @MaxDispenseDate_Hist =  MAX(MaxDispenseDate) FROM [ODS].[dbo].[CT_PharmacyVisit_Log]  (NoLock)
			SELECT @DispenseDate = MAX(DispenseDate) FROM [DWAPICentral].[dbo].[PatientPharmacyExtract] WITH (NOLOCK) 
			SELECT @MaxCreatedDate		= MAX(CreatedDate)	FROM [ODS].[dbo].[CT_VisitCount_Log] WITH (NOLOCK) 
							
			INSERT INTO  [ODS].[dbo].[CT_PharmacyVisit_Log](MaxDispenseDate,LoadStartDateTime)
			VALUES(@DispenseDate,GETDATE())

			MERGE [ODS].[dbo].[CT_PatientPharmacy] AS a
				USING(SELECT 
					  P.[PatientCccNumber] AS PatientID, P.[PatientPID] AS PatientPK,F.[Name] AS FacilityName, F.Code AS SiteCode,PP.[VisitID] VisitID,PP.[Drug] Drug
					  ,PP.[DispenseDate] DispenseDate,PP.[Duration] Duration,PP.[ExpectedReturn] ExpectedReturn,PP.[TreatmentType] TreatmentType
					  ,PP.[PeriodTaken] PeriodTaken,PP.[ProphylaxisType] ProphylaxisType,P.[Emr] Emr
					  ,CASE P.[Project] 
								WHEN 'I-TECH' THEN 'Kenya HMIS II' 
								WHEN 'HMIS' THEN 'Kenya HMIS II'
							ELSE P.[Project] 
					   END AS [Project] 
					  ,PP.[Voided] Voided
					  ,PP.[Processed] Processed
					  ,PP.[Provider] [Provider]
					  ,PP.[RegimenLine] RegimenLine
					  ,PP.[Created] Created
					  ,PP.RegimenChangedSwitched RegimenChangedSwitched
					  ,PP.RegimenChangeSwitchReason RegimenChangeSwitchReason
					  ,PP.StopRegimenReason StopRegimenReason
					  ,PP.StopRegimenDate StopRegimenDate
					  ,LTRIM(RTRIM(STR(F.Code)))+'-'+LTRIM(RTRIM(P.[PatientCccNumber])) +'-'+LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV, 
					  0 AS IsRegimenFlag, 
					  0 AS KnockOutDrug
					  ,P.ID as PatientUnique_ID
					  ,PP.ID as PatientPharmacyUnique_ID
					FROM [DWAPICentral].[dbo].[PatientExtract] P 
						INNER JOIN [DWAPICentral].[dbo].[PatientArtExtract] PA ON PA.[PatientId]= P.ID
						INNER JOIN [DWAPICentral].[dbo].[PatientPharmacyExtract] PP ON PP.[PatientId]= P.ID AND PP.Voided=0
						INNER JOIN [DWAPICentral].[dbo].[Facility] F ON P.[FacilityId] = F.Id AND F.Voided=0
					WHERE p.gender!='Unknown' ) AS b 
						ON(
						a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.visitID = b.visitID
						and a.DispenseDate = b.DispenseDate
						and a.PatientUnique_ID =b.PatientPharmacyUnique_ID
						)

				WHEN NOT MATCHED THEN 
					INSERT(PatientID,SiteCode,FacilityName,PatientPK,VisitID,Drug,DispenseDate,Duration,ExpectedReturn,TreatmentType,PeriodTaken,ProphylaxisType,Emr,Project,CKV,RegimenLine,RegimenChangedSwitched,RegimenChangeSwitchReason,StopRegimenReason,StopRegimenDate,PatientUnique_ID,PatientPharmacyUnique_ID) 
					VALUES(PatientID,SiteCode,FacilityName,PatientPK,VisitID,Drug,DispenseDate,Duration,ExpectedReturn,TreatmentType,PeriodTaken,ProphylaxisType,Emr,Project,CKV,RegimenLine,RegimenChangedSwitched,RegimenChangeSwitchReason,StopRegimenReason,StopRegimenDate,PatientUnique_ID,PatientPharmacyUnique_ID)
			
				WHEN MATCHED THEN
					UPDATE SET 
						a.PatientID					=b.PatientID,
						a.FacilityName				=b.FacilityName,
						a.Drug						=b.Drug,
						a.Duration					=b.Duration,
						a.ExpectedReturn			=b.ExpectedReturn,
						a.TreatmentType				=b.TreatmentType,
						a.PeriodTaken				=b.PeriodTaken,
						a.ProphylaxisType			=b.ProphylaxisType,
						a.Emr						=b.Emr,
						a.Project					=b.Project,
						a.RegimenLine				=b.RegimenLine,
						a.RegimenChangedSwitched	=b.RegimenChangedSwitched,
						a.RegimenChangeSwitchReason	=b.RegimenChangeSwitchReason,
						a.StopRegimenReason			=b.StopRegimenReason,
						a.StopRegimenDate			=b.StopRegimenDate

					WHEN NOT MATCHED BY SOURCE 
						THEN
						/* The Record is in the target table but doen't exit on the source table*/
							Delete;
			
				UPDATE [ODS].[dbo].[CT_PharmacyVisit_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxDispenseDate = @DispenseDate;

			--truncate table [ODS].[dbo].[CT_PatientPharmacyCount_Log]
			INSERT INTO [ODS].[dbo].[CT_PatientPharmacyCount_Log]([SiteCode],[CreatedDate],[PatientPharmacyCount])
			SELECT SiteCode,GETDATE(),COUNT(CKV) AS PatientPharmacyCount 
			FROM [ODS].[dbo].[CT_PatientPharmacy] 
			--WHERE @MaxCreatedDate  > @MaxCreatedDate
			GROUP BY SiteCode;
			--DROP INDEX CT_PatientPharmacy ON [ODS].[dbo].[CT_PatientPharmacy] ;
			---Remove any duplicate from [ODS].[dbo].[CT_PatientPharmacy] 
			--WITH CTE AS   
			--	(  
			--		SELECT [PatientPK],[SiteCode],visitID,DispenseDate,PatientUnique_ID,PatientPharmacyUnique_ID,ROW_NUMBER() 
			--		OVER (PARTITION BY [PatientPK],[SiteCode],visitID,DispenseDate,PatientUnique_ID,PatientPharmacyUnique_ID
			--		ORDER BY [PatientPK],[SiteCode],visitID,DispenseDate ,PatientUnique_ID,PatientPharmacyUnique_ID) AS dump_ 
			--		FROM [ODS].[dbo].[CT_PatientPharmacy] 
			--		)  
			
			--DELETE FROM CTE WHERE dump_ >1;

	END