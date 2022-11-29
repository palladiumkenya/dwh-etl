BEGIN
	       DECLARE @MaxVisitDate_Hist			DATETIME,
				   @VisitDate					DATETIME
				
		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS].[dbo].[CT_Ipt_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[IptExtract](NoLock)
		
		IF (SELECT COUNT(1) FROM [ODS].[dbo].[CT_Ipt_Log](NoLock) WHERE MaxVisitDate = @VisitDate) > 0
		RETURN

			ELSE
				BEGIN
					
					INSERT INTO  [ODS].[dbo].[CT_Ipt_Log](MaxVisitDate,LoadStartDateTime)
					VALUES(@VisitDate,GETDATE())

					INSERT INTO [ODS].[dbo].[CT_Ipt](PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,OnTBDrugs,OnIPT,EverOnIPT,Cough,Fever,NoticeableWeightLoss,NightSweats,Lethargy,ICFActionTaken,TestResult,TBClinicalDiagnosis,ContactsInvited,EvaluatedForIPT,StartAntiTBs,TBRxStartDate,TBScreening,IPTClientWorkUp,StartIPT,IndicationForIPT,DateImported,CKV)
					SELECT
						P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,F.Name AS FacilityName,
						IE.[VisitId] AS VisitID,IE.[VisitDate] AS VisitDate,P.[Emr] AS Emr,
						CASE
							P.[Project]
							WHEN 'I-TECH' THEN 'Kenya HMIS II'
							WHEN 'HMIS' THEN 'Kenya HMIS II'
							ELSE P.[Project]
						END AS Project,
						IE.[OnTBDrugs] AS OnTBDrugs,IE.[OnIPT] AS OnIPT,IE.[EverOnIPT] AS EverOnIPT,IE.[Cough] AS Cough,
						IE.[Fever] AS Fever,IE.[NoticeableWeightLoss] AS NoticeableWeightLoss,IE.[NightSweats] AS NightSweats,
						IE.[Lethargy] AS Lethargy,IE.[ICFActionTaken] AS ICFActionTaken,IE.[TestResult] AS TestResult,
						IE.[TBClinicalDiagnosis] AS TBClinicalDiagnosis,IE.[ContactsInvited] AS ContactsInvited,
						IE.[EvaluatedForIPT] AS EvaluatedForIPT,IE.[StartAntiTBs] AS StartAntiTBs,IE.[TBRxStartDate] AS TBRxStartDate,
						IE.[TBScreening] AS TBScreening,IE.[IPTClientWorkUp] AS IPTClientWorkUp,IE.[StartIPT] AS StartIPT,
						IE.[IndicationForIPT] AS IndicationForIPT,GETDATE() AS DateImported,
						LTRIM(RTRIM(STR(F.Code))) + '-' + LTRIM(RTRIM(P.[PatientCccNumber])) + '-' + LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[IptExtract](NoLock) IE ON IE.[PatientId] = P.ID AND IE.Voided = 0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
					WHERE P.gender != 'Unknown' and VisitDate > @MaxVisitDate_Hist					

					UPDATE [ODS].[dbo].[CT_Ipt_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @VisitDate;

			END
			---Remove any duplicate from [ODS].[dbo].[CT_Ipt]
			;WITH CTE AS   
				(  
					SELECT [PatientPK],[SiteCode],VisitDate,ROW_NUMBER() 
					OVER (PARTITION BY [PatientPK],[SiteCode],VisitDate
					ORDER BY [PatientPK],[SiteCode],VisitDate) AS dump_ 
					FROM [ODS].[dbo].[CT_Ipt]
					)  
			
			DELETE FROM CTE WHERE dump_ >1;

			
	END