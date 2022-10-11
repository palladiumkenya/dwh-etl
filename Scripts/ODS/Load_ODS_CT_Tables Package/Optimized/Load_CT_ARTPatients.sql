BEGIN
		DECLARE @MaxVisitDate_Hist		DATETIME,
				@VisitDate				DATETIME
				
		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS].[dbo].[CT_Visit_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[PatientVisitExtract] WITH (NOLOCK) 
		
		IF (SELECT COUNT(1) FROM [ODS].[dbo].[CT_Visit_Log](NoLock) WHERE MaxVisitDate = @VisitDate) > 0
		RETURN

			ELSE
				BEGIN

				  INSERT INTO [ODS].[dbo].[CT_PatientVisits](PatientID,PatientPK,FacilityName,SiteCode,VisitID,
						VisitDate,[SERVICE],VisitType,WHOStage,WABStage,Pregnant,LMP,EDD,Height,[Weight],
						BP,OI,OIDate,Adherence,AdherenceCategory,FamilyPlanningMethod,PwP,GestationAge,NextAppointmentDate,
						Emr,Project,CKV,DifferentiatedCare,StabilityAssessment,KeyPopulationType,PopulationType,VisitBy,Temp,PulseRate,
						RespiratoryRate,OxygenSaturation,Muac,NutritionalStatus,EverHadMenses,Breastfeeding,Menopausal,NoFPReason,
						ProphylaxisUsed,CTXAdherence,CurrentRegimen,HCWConcern,TCAReason,ClinicalNotes,GeneralExamination,SystemExamination,Skin,Eyes,ENT,Chest,CVS,Abdomen,CNS,Genitourinary)
				   SELECT 
						  P.[PatientCccNumber] AS PatientID, P.[PatientPID] AS PatientPK, F.Name AS FacilityName,  F.Code AS SiteCode,PV.[VisitId]
						  ,PV.[VisitDate],PV.[Service],PV.[VisitType],PV.[WHOStage],PV.[WABStage],PV.[Pregnant],PV.[LMP],PV.[EDD],PV.[Height],PV.[Weight]
						  ,PV.[BP],PV.[OI],PV.[OIDate],PV.[Adherence],PV.[AdherenceCategory],PV.[FamilyPlanningMethod],PV.[PwP],PV.[GestationAge],PV.[NextAppointmentDate]
						  ,P.[Emr]
						  ,CASE P.[Project] 
								WHEN 'I-TECH' THEN 'Kenya HMIS II' 
								WHEN 'HMIS' THEN 'Kenya HMIS II'
						   ELSE P.[Project] 
						   END AS [Project] 
						   ,LTRIM(RTRIM(STR(F.Code)))+'-'+LTRIM(RTRIM(P.[PatientCccNumber]))+'-'+LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV 
						  ,pv.[DifferentiatedCare],pv.[StabilityAssessment],pv.[PopulationType],pv.[KeyPopulationType],PV.VisitBy ,PV.Temp ,PV.PulseRate 
						  ,PV.RespiratoryRate,PV.OxygenSaturation,PV.Muac,PV.NutritionalStatus,PV.EverHadMenses,PV.Breastfeeding,PV.Menopausal,PV.NoFPReason
						  ,PV.ProphylaxisUsed,PV.CTXAdherence,PV.CurrentRegimen,PV.HCWConcern,PV.TCAReason,PV.ClinicalNotes,[GeneralExamination]
						  ,[SystemExamination],[Skin],[Eyes],[ENT],[Chest],[CVS],[Abdomen],[CNS],[Genitourinary]
						  -----Missing columns Added later by Dennis
						  
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
					LEFT JOIN [DWAPICentral].[dbo].[PatientArtExtract](NoLock) PA ON PA.[PatientId]= P.ID
					INNER JOIN [DWAPICentral].[dbo].[PatientVisitExtract](NoLock) PV ON PV.[PatientId]= P.ID AND PV.Voided=0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0
					---INNER JOIN [DWAPICentral].[dbo].[FacilityManifest_MaxDateRecieved](NoLock) a ON F.Code = a.SiteCode
					----LEFT JOIN All_Staging_2016_2.dbo.stg_Patients TPat ON TPat.PKV=LTRIM(RTRIM(STR(F.Code)))+'-'+LTRIM(RTRIM(P.[PatientCccNumber]))+'-'+LTRIM(RTRIM(STR(P.[PatientPID])))
					--ORDER BY F.Id, PV.[PatientId],PV.[VisitDate],PV.[VisitId]
					WHERE p.gender!='Unknown' AND VisitDate >@MaxVisitDate_Hist  --and a.[End] is not null and a.[Session] is not null  AND VisitDate > @MaxVisitDate_Hist
				END
			---Remove any duplicate from [NDWH_DB].[dbo].[DimPatient]
			;WITH CTE AS   
				(  
					SELECT [PatientID],[PatientPK],[SiteCode],VisitID,ROW_NUMBER() 
					OVER (PARTITION BY [PatientID],[PatientPK],[SiteCode],VisitID 
					ORDER BY [PatientID],[PatientPK],[SiteCode],VisitID) AS dump_ 
					FROM [ODS].[dbo].[CT_PatientVisits] 
					)  
			
			DELETE FROM CTE WHERE dump_ >1;			
	END