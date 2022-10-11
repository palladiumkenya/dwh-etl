BEGIN
	       DECLARE @MaxDispenseDate_Hist			DATETIME,
				   @DispenseDate					DATETIME
				
		SELECT @MaxDispenseDate_Hist =  MAX(MaxDispenseDate) FROM [ODS].[dbo].[CT_PharmacyVisit_Log]  (NoLock)
		SELECT @DispenseDate = MAX(DispenseDate) FROM [DWAPICentral].[dbo].[PatientPharmacyExtract] WITH (NOLOCK) 
		
		IF (SELECT COUNT(1) FROM [ODS].[dbo].[CT_PharmacyVisit_Log](NoLock) WHERE MaxDispenseDate = @DispenseDate) > 0
		RETURN

			ELSE
				BEGIN
					
					INSERT INTO  [ODS].[dbo].[CT_PharmacyVisit_Log](MaxDispenseDate,LoadStartDateTime)
					VALUES(@DispenseDate,GETDATE())

					INSERT INTO [ODS].[dbo].[CT_PatientPharmacy](PatientID,PatientPK,FacilityName,SiteCode,VisitID,Drug,DispenseDate,Duration,
					ExpectedReturn,TreatmentType,PeriodTaken,ProphylaxisType,Emr,Project,DateImported,CKV,RegimenLine,RegimenChangedSwitched,RegimenChangeSwitchReason,StopRegimenReason,StopRegimenDate)

					SELECT 
					  P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Name AS FacilityName,F.Code AS SiteCode,PP.[VisitID],PP.[Drug],PP.[DispenseDate],PP.[Duration]
					  ,PP.[ExpectedReturn],PP.[TreatmentType],PP.[PeriodTaken],PP.[ProphylaxisType],P.[Emr]
					  ,CASE P.[Project] 
							WHEN 'I-TECH' THEN 'Kenya HMIS II' 
							WHEN 'HMIS' THEN 'Kenya HMIS II'
					   ELSE P.[Project] 
					   END AS [Project]
					  ,CAST(GETDATE() AS DATE) AS DateImported
					  ,LTRIM(RTRIM(STR(F.Code)))+'-'+LTRIM(RTRIM(P.[PatientCccNumber])) +'-'+LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV 
					  --,PP.[Provider]
					  ,PP.[RegimenLine]
					 -- ,PP.[Created]
					   ,PP.RegimenChangedSwitched,PP.RegimenChangeSwitchReason,PP.StopRegimenReason,PP.StopRegimenDate

				FROM [DWAPICentral].[dbo].[PatientExtract] P 
				INNER JOIN [DWAPICentral].[dbo].[PatientArtExtract] PA ON PA.[PatientId]= P.ID
				INNER JOIN [DWAPICentral].[dbo].[PatientPharmacyExtract] PP ON PP.[PatientId]= P.ID AND PP.Voided=0
				INNER JOIN [DWAPICentral].[dbo].[Facility] F ON P.[FacilityId] = F.Id AND F.Voided=0
				WHERE p.gender!='Unknown'  AND DispenseDate > @MaxDispenseDate_Hist;

				UPDATE [ODS].[dbo].[CT_PharmacyVisit_Log]
				SET LoadEndDateTime = GETDATE()
				WHERE MaxDispenseDate = @DispenseDate;

			END
			---Remove any duplicate from [NDWH_DB].[dbo].[DimPatient]
			;WITH CTE AS   
				(  
					SELECT [PatientPK],[SiteCode],DispenseDate,ROW_NUMBER() 
					OVER (PARTITION BY [PatientPK],[SiteCode],DispenseDate
					ORDER BY [PatientPK],[SiteCode],DispenseDate) AS dump_ 
					FROM [ODS].[dbo].[CT_PatientPharmacy] 
					)  
			
			DELETE FROM CTE WHERE dump_ >1;

			
	END