BEGIN
			--CREATE INDEX CT_Otz ON [ODS].[dbo].[CT_Otz] (sitecode,PatientPK);
	       ---- Refresh [ODS].[dbo].[CT_Otz]
			MERGE [ODS].[dbo].[CT_Otz] AS a
				USING(SELECT
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
						,P.ID as PatientUnique_ID
						,OE.ID as OtzUnique_ID
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[OtzExtract](NoLock) OE ON OE.[PatientId] = P.ID AND OE.Voided = 0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
					WHERE P.gender != 'Unknown' ) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitID	=b.VisitID
						and a.VisitDate	=b.VisitDate
						and a.PatientUnique_ID =b.OtzUnique_ID )
					WHEN MATCHED THEN
						UPDATE SET 						
						
						a.Emr						=b.Emr,
						a.Project					=b.Project,
						a.OTZEnrollmentDate			=b.OTZEnrollmentDate,
						a.TransferInStatus			=b.TransferInStatus,
						a.ModulesPreviouslyCovered	=b.ModulesPreviouslyCovered,
						a.ModulesCompletedToday		=b.ModulesCompletedToday,
						a.SupportGroupInvolvement	=b.SupportGroupInvolvement,
						a.Remarks					=b.Remarks,
						a.TransitionAttritionReason	=b.TransitionAttritionReason,
						a.OutcomeDate				=b.OutcomeDate,
						a.DateImported				=b.DateImported,
						a.CKV						=b.CKV
							
					WHEN NOT MATCHED THEN 
						INSERT(PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,OTZEnrollmentDate,TransferInStatus,ModulesPreviouslyCovered,ModulesCompletedToday,SupportGroupInvolvement,Remarks,TransitionAttritionReason,OutcomeDate,DateImported,CKV,PatientUnique_ID,OtzUnique_ID) 
						VALUES(PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,OTZEnrollmentDate,TransferInStatus,ModulesPreviouslyCovered,ModulesCompletedToday,SupportGroupInvolvement,Remarks,TransitionAttritionReason,OutcomeDate,DateImported,CKV,PatientUnique_ID,OtzUnique_ID);
				
					--DROP INDEX CT_Otz ON [ODS].[dbo].[CT_Otz];
					---Remove any duplicate from [ODS].[dbo].[CT_Otz]
					WITH CTE AS   
						(  
							SELECT [PatientPK],[SiteCode],VisitID,VisitDate,PatientUnique_ID,OtzUnique_ID,ROW_NUMBER() 
							OVER (PARTITION BY [PatientPK],[SiteCode], VisitID,VisitDate,PatientUnique_ID,OtzUnique_ID
							ORDER BY [PatientPK],[SiteCode],VisitID,VisitDate,PatientUnique_ID,OtzUnique_ID) AS dump_ 
							FROM [ODS].[dbo].[CT_Otz] 
							)  
			
					DELETE FROM CTE WHERE dump_ >1;

	END