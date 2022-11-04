BEGIN
			--CREATE INDEX CT_DrugAlcoholScreening ON [ODS].[dbo].[CT_DrugAlcoholScreening] (sitecode,PatientPK);
	       ---- Refresh [ODS].[dbo].[CT_DrugAlcoholScreening]
			MERGE [ODS].[dbo].[CT_DrugAlcoholScreening] AS a
				USING(SELECT
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
							,DAS.ID as DrugAlcoholScreeningUnique_ID
							,P.ID as PatientUnique_ID
						FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
						INNER JOIN [DWAPICentral].[dbo].[DrugAlcoholScreeningExtract](NoLock) DAS ON DAS.[PatientId] = P.ID AND DAS.Voided = 0
						INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
						WHERE P.gender != 'Unknown') AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitID = b.VisitID
						and a.VisitDate	=b.VisitDate
						and a.PatientUnique_ID =b.DrugAlcoholScreeningUnique_ID)
					WHEN MATCHED THEN
						UPDATE SET 
						a.PatientID			=b.PatientID,
						a.FacilityName		=b.FacilityName,
						a.Emr				=b.Emr,
						a.Project			=b.Project,
						a.DrinkingAlcohol	=b.DrinkingAlcohol,
						a.Smoking			=b.Smoking,
						a.DrugUse			=b.DrugUse,
						a.DateImported		=b.DateImported,
						a.CKV				=b.CKV
							
					WHEN NOT MATCHED THEN 
						INSERT(PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,DrinkingAlcohol,Smoking,DrugUse,DateImported,CKV,PatientUnique_ID,DrugAlcoholScreeningUnique_ID) 
						VALUES(PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,DrinkingAlcohol,Smoking,DrugUse,DateImported,CKV,PatientUnique_ID,DrugAlcoholScreeningUnique_ID);
				
					--DROP INDEX CT_DrugAlcoholScreening ON [ODS].[dbo].[CT_DrugAlcoholScreening];
					---Remove any duplicate from [ODS].[dbo].[CT_DrugAlcoholScreening]
					WITH CTE AS   
						(  
							SELECT [PatientPK],[SiteCode],VisitID,VisitDate,PatientUnique_ID,DrugAlcoholScreeningUnique_ID,ROW_NUMBER() 
							OVER (PARTITION BY [PatientPK],[SiteCode],VisitID,VisitDate,PatientUnique_ID,DrugAlcoholScreeningUnique_ID
							ORDER BY [PatientPK],[SiteCode],VisitID,VisitDate,PatientUnique_ID,DrugAlcoholScreeningUnique_ID) AS dump_ 
							FROM [ODS].[dbo].[CT_DrugAlcoholScreening] 
							)  
			
					DELETE FROM CTE WHERE dump_ >1;

	END