BEGIN
	       DECLARE @MaxRegistrationDate_Hist			DATETIME,
				   @RegistrationDate					DATETIME
				
		SELECT @MaxRegistrationDate_Hist =  MAX(MaxRegistrationDate) FROM [ODS].[dbo].[CT_Patient_Log]  (NoLock)
		SELECT @RegistrationDate = MAX(VisitDate) FROM [DWAPICentral].[dbo].[IptExtract](NoLock)
		
		IF (SELECT COUNT(1) FROM [ODS].[dbo].[CT_Patient_Log](NoLock) WHERE MaxRegistrationDate = @RegistrationDate) > 0
		RETURN

			ELSE
				BEGIN
					
					INSERT INTO  [ODS].[dbo].[CT_Patient_Log](MaxRegistrationDate,LoadStartDateTime)
					VALUES(@RegistrationDate,GETDATE())

					INSERT INTO [ODS].[dbo].[CT_Patients](Id,PatientID,PatientPK,SiteCode,FacilityName,Gender,DOB,RegistrationDate,RegistrationAtCCC,RegistrationAtPMTCT,
					RegistrationAtTBClinic,PatientSource,Region,District,Village,ContactRelation,LastVisit,MaritalStatus,
					EducationLevel,DateConfirmedHIVPositive,PreviousARTExposure,PreviousARTStartDate,Emr,Project,DateImported,CKV,
					Processed,StatusAtCCC,StatusAtPMTCT,StatusAtTBClinic,Created,Orphan,Inschool,PatientType,PopulationType,KeyPopulationType,PatientResidentCounty,PatientResidentSubCounty,
					PatientResidentLocation,PatientResidentSubLocation,PatientResidentWard,PatientResidentVillage,TransferInDate,Occupation,NUPI)
					SELECT 
						  P.[Id],P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.[Code] AS SiteCode,F.[Name] AS FacilityName,P.[Gender],P.[DOB],P.[RegistrationDate],P.[RegistrationAtCCC],P.[RegistrationATPMTCT]
						  ,P.[RegistrationAtTBClinic],P.[PatientSource],P.[Region],P.[District],ISNULL(P.[Village],'') AS [Village],P.[ContactRelation],P.[LastVisit],P.[MaritalStatus]
						  ,P.[EducationLevel],P.[DateConfirmedHIVPositive],P.[PreviousARTExposure],P.[PreviousARTStartDate],P.[Emr]
						  ,CASE P.[Project] 
								WHEN 'I-TECH' THEN 'Kenya HMIS II' 
								WHEN 'HMIS' THEN 'Kenya HMIS II'
						   ELSE P.[Project] 
						   END AS [Project] 
						   ,GETDATE() AS DateImported
						   ,LTRIM(RTRIM(STR(F.Code)))+'-'+LTRIM(RTRIM(P.[PatientCccNumber])) +'-'+LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV
						  ,P.[Processed],P.[StatusAtCCC],P.[StatusAtPMTCT],P.[StatusAtTBClinic],P.[Created],
						P.Orphan,P.Inschool,P.PatientType,P.PopulationType,P.KeyPopulationType,P.PatientResidentCounty,P.PatientResidentSubCounty,
						P.PatientResidentLocation,P.PatientResidentSubLocation,P.PatientResidentWard,P.PatientResidentVillage,P.TransferInDate, 
						P.Occupation,P.NUPI
					  FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0 
					WHERE P.Voided=0 and P.[Gender] is NOT NULL and p.gender!='Unknown' and RegistrationDate > @MaxRegistrationDate_Hist	
					ORDER BY F.Code,P.[PatientCccNumber], P.[PatientPID] 				

					UPDATE [ODS].[dbo].[CT_Patient_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxRegistrationDate = @RegistrationDate;

			END
			---Remove any duplicate from [ODS].[dbo].[CT_Patients]
			;WITH CTE AS   
				(  
					SELECT [PatientPK],[SiteCode],ROW_NUMBER() 
					OVER (PARTITION BY [PatientPK],[SiteCode]
					ORDER BY [PatientPK],[SiteCode]) AS dump_ 
					FROM [ODS].[dbo].[CT_Patients]
					)  
			
			DELETE FROM CTE WHERE dump_ >1;

			
	END