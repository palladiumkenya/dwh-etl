BEGIN
		 DECLARE	@MaxVisitDate_Hist			DATETIME,
					@VisitDate					DATETIME
				
		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS].[dbo].[CT_GbvScreening_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[GbvScreeningExtract](NoLock)
		
					
		INSERT INTO  [ODS].[dbo].[CT_GbvScreening_Log](MaxVisitDate,LoadStartDateTime)
		VALUES(@MaxVisitDate_Hist,GETDATE())

			--CREATE INDEX CT_GbvScreening ON [ODS].[dbo].[CT_GbvScreening] (sitecode,PatientPK);
	       ---- Refresh [ODS].[dbo].[CT_GbvScreening]
			MERGE [ODS].[dbo].[CT_GbvScreening] AS a
				USING(SELECT
							P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,F.Name AS FacilityName,
							GSE.[VisitId] AS VisitID,GSE.[VisitDate] AS VisitDate,P.[Emr],
							CASE
								P.[Project]
								WHEN 'I-TECH' THEN 'Kenya HMIS II'
								WHEN 'HMIS' THEN 'Kenya HMIS II'
								ELSE P.[Project]
							END AS Project,
							GSE.[IPV] AS IPV,GSE.[PhysicalIPV],GSE.[EmotionalIPV],GSE.[SexualIPV],GSE.[IPVRelationship],
							GETDATE() AS DateImported,
							LTRIM(RTRIM(STR(F.Code))) + '-' + LTRIM(RTRIM(P.[PatientCccNumber])) + '-' + LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV
							,P.ID as PatientUnique_ID
							,GSE.PatientID as UniquePatientGbvScreeningID
							,GSE.ID GbvScreeningUnique_ID
						FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
						INNER JOIN [DWAPICentral].[dbo].[GbvScreeningExtract](NoLock) GSE ON GSE.[PatientId] = P.ID AND GSE.Voided = 0
						INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
						WHERE P.gender != 'Unknown') AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitID			=b.VisitID
						and a.VisitDate			=b.VisitDate
						and a.PatientUnique_ID =b.UniquePatientGbvScreeningID
						and a.GbvScreeningUnique_ID = b.GbvScreeningUnique_ID
						and a.GbvScreeningUnique_ID = b.GbvScreeningUnique_ID)

					WHEN NOT MATCHED THEN 
						INSERT(PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,IPV,PhysicalIPV,EmotionalIPV,SexualIPV,IPVRelationship,DateImported,CKV,PatientUnique_ID,GbvScreeningUnique_ID) 
						VALUES(PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,IPV,PhysicalIPV,EmotionalIPV,SexualIPV,IPVRelationship,DateImported,CKV,PatientUnique_ID,GbvScreeningUnique_ID)
				
					WHEN MATCHED THEN
						UPDATE SET 
						a.PatientID			=b.PatientID,
						a.FacilityName		=b.FacilityName,
						a.Emr				=b.Emr,
						a.Project			=b.Project,
						a.IPV				=b.IPV,
						a.PhysicalIPV		=b.PhysicalIPV,
						a.EmotionalIPV		=b.EmotionalIPV,
						a.SexualIPV			=b.SexualIPV,
						a.IPVRelationship	=b.IPVRelationship,
						a.DateImported		=b.DateImported,
						a.CKV				=b.CKV
					
					WHEN NOT MATCHED BY SOURCE 
						THEN
						/* The Record is in the target table but doen't exit on the source table*/
							Delete;		
					
					UPDATE [ODS].[dbo].[CT_GbvScreening_Log]
						SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @MaxVisitDate_Hist;

					INSERT INTO [ODS].[dbo].[CT_GbvScreeningCount_Log]([SiteCode],[CreatedDate],[GbvScreeningCount])
					SELECT SiteCode,GETDATE(),COUNT(SiteCode) AS GbvScreeningCount 
					FROM [ODS].[dbo].[CT_GbvScreening] 
					--WHERE @MaxCreatedDate  > @MaxCreatedDate
					GROUP BY SiteCode;

				--DROP INDEX CT_GbvScreening ON [ODS].[dbo].[CT_GbvScreening];
				---Remove any duplicate from [ODS].[dbo].[CT_GbvScreening]
				--WITH CTE AS   
				--	(  
				--		SELECT [PatientPK],[SiteCode],VisitID,VisitDate,PatientUnique_ID,GbvScreeningUnique_ID,ROW_NUMBER() 
				--		OVER (PARTITION BY [PatientPK],[SiteCode],VisitID,VisitDate,PatientUnique_ID,GbvScreeningUnique_ID
				--		ORDER BY [PatientPK],[SiteCode],VisitID,VisitDate,PatientUnique_ID,GbvScreeningUnique_ID) AS dump_ 
				--		FROM [ODS].[dbo].[CT_GbvScreening] 
				--		)  
			
				--DELETE FROM CTE WHERE dump_ >1;

	END