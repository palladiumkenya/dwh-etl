
BEGIN

				;with cte AS ( Select            
					P.PatientPID,            
					OE.PatientId,            
					F.code,
					OE.VisitID,
					OE.VisitDate,
					OE.created,  ROW_NUMBER() OVER (PARTITION BY P.PatientPID,F.code ,OE.VisitID,OE.VisitDate
					ORDER BY OE.created desc) Row_Num
			FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[OtzExtract](NoLock) OE ON OE.[PatientId] = P.ID AND OE.Voided = 0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
					WHERE P.gender != 'Unknown' )      
		
			delete pb from      [DWAPICentral].[dbo].[OtzExtract](NoLock) pb
			inner join [DWAPICentral].[dbo].[PatientExtract](NoLock) P ON PB.[PatientId]= P.ID AND PB.Voided = 0       
			inner join [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0       
			inner join cte on pb.PatientId = cte.PatientId  
				and cte.Created = pb.created 
				and cte.Code =  f.Code     
				and cte.VisitID = pb.VisitID
				and cte.VisitDate = pb.VisitDate
			where  Row_Num  > 1;


			DECLARE @MaxVisitDate_Hist			DATETIME,
				   @VisitDate					DATETIME
				
		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS].[dbo].[CT_Otz_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[OtzExtract](NoLock)
					
			INSERT INTO  [ODS].[dbo].[CT_Otz_Log](MaxVisitDate,LoadStartDateTime)
			VALUES(@MaxVisitDate_Hist,GETDATE())

			MERGE [ODS].[dbo].[CT_Otz] AS a
				USING(SELECT Distinct
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
						OE.[OutcomeDate]
						,P.ID

					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[OtzExtract](NoLock) OE ON OE.[PatientId] = P.ID AND OE.Voided = 0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
					WHERE P.gender != 'Unknown' ) AS b	
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitID	=b.VisitID
						and a.VisitDate	=b.VisitDate
						and a.ID =b.ID
						)
					
					WHEN NOT MATCHED THEN 
						INSERT(ID,PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,OTZEnrollmentDate,TransferInStatus,ModulesPreviouslyCovered,ModulesCompletedToday,SupportGroupInvolvement,Remarks,TransitionAttritionReason,OutcomeDate) 
						VALUES(ID,PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,OTZEnrollmentDate,TransferInStatus,ModulesPreviouslyCovered,ModulesCompletedToday,SupportGroupInvolvement,Remarks,TransitionAttritionReason,OutcomeDate)
				
					WHEN MATCHED THEN
						UPDATE SET 						
												
						a.TransferInStatus			=b.TransferInStatus,
						a.ModulesPreviouslyCovered	=b.ModulesPreviouslyCovered,
						a.ModulesCompletedToday		=b.ModulesCompletedToday,
						a.SupportGroupInvolvement	=b.SupportGroupInvolvement,
						a.Remarks					=b.Remarks,
						a.TransitionAttritionReason	=b.TransitionAttritionReason;

						with cte AS (
						Select
						PatientPK,
						Sitecode,
						visitID,
						visitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,visitDate ORDER BY
						PatientPK,Sitecode,visitID,visitDate) Row_Num
						FROM [ODS].[dbo].[CT_Otz](NoLock)
						)
					delete from cte 
						Where Row_Num >1 ;

					UPDATE [ODS].[dbo].[CT_Otz_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @MaxVisitDate_Hist;

					INSERT INTO [ODS].[dbo].[CT_OtzCount_Log]([SiteCode],[CreatedDate],[OtzCount])
					SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS OtzCount 
					FROM [ODS].[dbo].[CT_Otz]
					--WHERE @MaxCreatedDate  > @MaxCreatedDate
					GROUP BY SiteCode;

			
	END
