BEGIN

					;with cte AS ( Select            
					P.PatientPID,            
					PP.PatientId,            
					F.code,
					PP.VisitID,
					PP.DispenseDate,
					PP.created,  ROW_NUMBER() OVER (PARTITION BY P.PatientPID,F.code ,PP.VisitID,PP.DispenseDate
					ORDER BY PP.created desc) Row_Num
			FROM [DWAPICentral].[dbo].[PatientExtract] P 
						INNER JOIN [DWAPICentral].[dbo].[PatientPharmacyExtract] PP ON PP.[PatientId]= P.ID AND PP.Voided=0
						INNER JOIN [DWAPICentral].[dbo].[Facility] F ON P.[FacilityId] = F.Id AND F.Voided=0
					WHERE p.gender!='Unknown'  )      
		
			delete pb from  [DWAPICentral].[dbo].[PatientPharmacyExtract](NoLock) pb
			inner join [DWAPICentral].[dbo].[PatientExtract](NoLock) P ON PB.[PatientId]= P.ID AND PB.Voided = 0       
			inner join [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0       
			inner join cte on pb.PatientId = cte.PatientId  
				and cte.Created = pb.created 
				and cte.Code =  f.Code     
				and cte.VisitID = pb.VisitID
				and cte.DispenseDate = pb.DispenseDate
			where  Row_Num  > 1;

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
					  ,PP.StopRegimenDate StopRegimenDate,					  
					  PP.ID

						FROM [DWAPICentral].[dbo].[PatientExtract] P 
						INNER JOIN [DWAPICentral].[dbo].[PatientPharmacyExtract] PP ON PP.[PatientId]= P.ID AND PP.Voided=0
						INNER JOIN [DWAPICentral].[dbo].[Facility] F ON P.[FacilityId] = F.Id AND F.Voided=0
					WHERE p.gender!='Unknown' ) AS b 
						ON(
						 a.SiteCode = b.SiteCode
						and  a.PatientPK  = b.PatientPK 
						and a.visitID = b.visitID
						and a.DispenseDate = b.DispenseDate
						and a.ID =b.ID						

						)

				WHEN NOT MATCHED THEN 
					INSERT(ID,PatientID,SiteCode,FacilityName,PatientPK,VisitID,Drug,DispenseDate,Duration,ExpectedReturn,TreatmentType,PeriodTaken,ProphylaxisType,Emr,Project,RegimenLine,RegimenChangedSwitched,RegimenChangeSwitchReason,StopRegimenReason,StopRegimenDate) 
					VALUES(ID,PatientID,SiteCode,FacilityName,PatientPK,VisitID,Drug,DispenseDate,Duration,ExpectedReturn,TreatmentType,PeriodTaken,ProphylaxisType,Emr,Project,RegimenLine,RegimenChangedSwitched,RegimenChangeSwitchReason,StopRegimenReason,StopRegimenDate)
			
				WHEN MATCHED THEN
					UPDATE SET 
						a.FacilityName				=b.FacilityName,
						a.PeriodTaken				=b.PeriodTaken,
						a.ProphylaxisType			=b.ProphylaxisType,
						a.RegimenLine				=b.RegimenLine,
						a.RegimenChangedSwitched	=b.RegimenChangedSwitched,
						a.RegimenChangeSwitchReason	=b.RegimenChangeSwitchReason,
						a.StopRegimenReason			=b.StopRegimenReason;

						--with cte AS (
						--Select
						--Sitecode,
						--PatientPK,
						--visitID,
						--DispenseDate,

						-- ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,DispenseDate ORDER BY
						--PatientPK,Sitecode,visitID,DispenseDate) Row_Num
						--FROM [ODS].[dbo].[CT_PatientPharmacy](NoLock)
						--)
						--delete from cte 
						--Where Row_Num >1 ;
			
				UPDATE [ODS].[dbo].[CT_PharmacyVisit_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxDispenseDate = @DispenseDate;

			--truncate table [ODS].[dbo].[CT_PatientPharmacyCount_Log]
			INSERT INTO [ODS].[dbo].[CT_PatientPharmacyCount_Log]([SiteCode],[CreatedDate],[PatientPharmacyCount])
			SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS PatientPharmacyCount 
			FROM [ODS].[dbo].[CT_PatientPharmacy] 
			--WHERE @MaxCreatedDate  > @MaxCreatedDate
			GROUP BY SiteCode;
 
	END
