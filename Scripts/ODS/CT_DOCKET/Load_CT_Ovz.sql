BEGIN
			DECLARE @MaxVisitDate_Hist			DATETIME,
				   @VisitDate					DATETIME
				
		SELECT @MaxVisitDate_Hist =  MAX(MaxVisitDate) FROM [ODS].[dbo].[CT_Ovc_Log]  (NoLock)
		SELECT @VisitDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[OvcExtract](NoLock)

					
					INSERT INTO  [ODS].[dbo].[CT_Ovc_Log](MaxVisitDate,LoadStartDateTime)
					VALUES(@MaxVisitDate_Hist,GETDATE())

	       ---- Refresh [ODS].[dbo].[CT_Ovc]
			MERGE [ODS].[dbo].[CT_Ovc] AS a
				USING(SELECT
						P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,F.Name AS FacilityName,
						OE.[VisitId] AS VisitID,OE.[VisitDate] AS VisitDate,P.[Emr],
						CASE
							P.[Project]
							WHEN 'I-TECH' THEN 'Kenya HMIS II'
							WHEN 'HMIS' THEN 'Kenya HMIS II'
							ELSE P.[Project]
						END AS Project,
						OE.[OVCEnrollmentDate],OE.[RelationshipToClient],OE.[EnrolledinCPIMS],OE.[CPIMSUniqueIdentifier],
						OE.[PartnerOfferingOVCServices],OE.[OVCExitReason],OE.[ExitDate],
						GETDATE() AS DateImported
						,P.ID as PatientUnique_ID
						,OE.PatientID as UniquePatientOVCID
						,OE.ID as OvcUnique_ID

					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[OvcExtract](NoLock) OE ON OE.[PatientId] = P.ID AND OE.Voided = 0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
					WHERE P.gender != 'Unknown' ) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitID	=b.VisitID
						and a.VisitDate	=b.VisitDate
						and a.PatientUnique_ID = b.UniquePatientOVCID
						)

					WHEN NOT MATCHED THEN 
						INSERT(PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,OVCEnrollmentDate,RelationshipToClient,EnrolledinCPIMS,CPIMSUniqueIdentifier,PartnerOfferingOVCServices,OVCExitReason,ExitDate,DateImported,PatientUnique_ID,OvcUnique_ID) 
						VALUES(PatientID,PatientPK,SiteCode,FacilityName,VisitID,VisitDate,Emr,Project,OVCEnrollmentDate,RelationshipToClient,EnrolledinCPIMS,CPIMSUniqueIdentifier,PartnerOfferingOVCServices,OVCExitReason,ExitDate,DateImported,PatientUnique_ID,OvcUnique_ID)
				
					WHEN MATCHED THEN
						UPDATE SET 
						a.FacilityName				=b.FacilityName,						
						a.RelationshipToClient		=b.RelationshipToClient,
						a.EnrolledinCPIMS			=b.EnrolledinCPIMS,
						a.CPIMSUniqueIdentifier		=b.CPIMSUniqueIdentifier,
						a.PartnerOfferingOVCServices=b.PartnerOfferingOVCServices,
						a.OVCExitReason				=b.OVCExitReason;

				UPDATE [ODS].[dbo].[CT_Ovc_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxVisitDate = @MaxVisitDate_Hist;

				INSERT INTO [ODS].[dbo].[CT_OvcCount_Log]([SiteCode],[CreatedDate],[OvcCount])
				SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS OVCCount 
				FROM [ODS].[dbo].[CT_Ovc] 
				--WHERE @MaxCreatedDate  > @MaxCreatedDate
				GROUP BY SiteCode;

	END
