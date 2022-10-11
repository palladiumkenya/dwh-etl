BEGIN
			DECLARE @MaxLastVisitDate_Hist			DATETIME,
				    @LastVisitDate					DATETIME
				
		SELECT @MaxLastVisitDate_Hist =  MAX(MaxLastVisitDate) FROM [ODS].[dbo].[CT_ARTPatient_Log]  (NoLock)
		SELECT @LastVisitDate = MAX(LastVisit) FROM [DWAPICentral].[dbo].[PatientArtExtract] WITH (NOLOCK) 
		
		IF (SELECT COUNT(1) FROM [ODS].[dbo].[CT_ARTPatient_Log](NoLock) WHERE MaxLastVisitDate = @LastVisitDate) > 0
		RETURN

			ELSE
				BEGIN
					
					INSERT INTO  [ODS].[dbo].[CT_ARTPatient_Log](MaxLastVisitDate,LoadStartDateTime)
					VALUES(@LastVisitDate,GETDATE());

					INSERT INTO [ODS].[dbo].[CT_ARTPatients](PatientPK,PatientID,FacilityName,SiteCode,
					DOB,AgeEnrollment,AgeARTStart,AgeLastVisit,RegistrationDate,PatientSource,Gender,StartARTDate,PreviousARTStartDate,PreviousARTRegimen,StartARTAtThisFacility,
					StartRegimen,StartRegimenLine,LastARTDate,LastRegimen,LastRegimenLine,Duration,ExpectedReturn,[Provider],LastVisit,ExitReason,ExitDate,Emr,Project,
					CKV,PreviousARTUse,PreviousARTPurpose,DateLastUsed)
					SELECT  P.[PatientPID] AS PatientPK,P.[PatientCccNumber] AS PatientID, F.Name AS FacilityName, F.Code AS SiteCode
						,PA.[DOB],PA.[AgeEnrollment],PA.[AgeARTStart],PA.[AgeLastVisit],PA.[RegistrationDate],PA.[PatientSource],PA.[Gender]
						,PA.[StartARTDate],PA.[PreviousARTStartDate],PA.[PreviousARTRegimen],PA.[StartARTAtThisFacility]
						  ,PA.[StartRegimen],PA.[StartRegimenLine],PA.[LastARTDate],PA.[LastRegimen],PA.[LastRegimenLine],PA.[Duration],PA.[ExpectedReturn]
						 ,PA.[Provider],PA.[LastVisit],PA.[ExitReason],PA.[ExitDate],P.[Emr]
						  ,CASE P.[Project] 
								WHEN 'I-TECH' THEN 'Kenya HMIS II' 
								WHEN 'HMIS' THEN 'Kenya HMIS II'
						   ELSE P.[Project] 
						   END AS [Project] 
						   ,LTRIM(RTRIM(STR(F.Code)))+'-'+LTRIM(RTRIM(P.[PatientCccNumber])) +'-'+LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV
						 
					,PA.[PreviousARTUse]
					,PA.[PreviousARTPurpose]
					,PA.[DateLastUsed]

					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
					INNER JOIN [DWAPICentral].[dbo].[PatientArtExtract](NoLock) PA ON PA.[PatientId]= P.ID AND PA.Voided=0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0 
					WHERE p.gender!='Unknown' AND pa.LastVisit > @MaxLastVisitDate_Hist;

					UPDATE [ODS].[dbo].[CT_ARTPatient_Log]
				SET LoadEndDateTime = GETDATE()
				WHERE MaxLastVisitDate = @LastVisitDate;
			END
			---Remove any duplicate from [NDWH_DB].[dbo].[DimPatient]
			;WITH CTE AS   
				(  
					SELECT [PatientPK],[SiteCode],ROW_NUMBER()  ----PARTITION by the columns
					OVER (PARTITION BY [PatientPK],[SiteCode] 
					ORDER BY [PatientPK],[SiteCode]) AS dump_ 
					FROM [ODS].[dbo].[CT_ARTPatients] 
					)  
			
			DELETE FROM CTE WHERE dump_ >1;

			------- Rrefresh DimFacility

			--MERGE [NDWH_DB].[dbo].[DimFacility] AS a
			--	USING(SELECT  P.[PatientCccNumber] as PatientID,P.[PatientPID] as PatientPK,F.Code as SiteCode,F.[Name] as FacilityName,Gender,DOB,RegistrationDate,RegistrationAtCCC,RegistrationAtPMTCT,RegistrationAtTBClinic,PatientSource,Region,District,Village,ContactRelation,LastVisit,MaritalStatus,EducationLevel,DateConfirmedHIVPositive,PreviousARTExposure,PreviousARTStartDate,P.Emr,P.Project,PKV,Orphan,Inschool,PatientType,PopulationType,KeyPopulationType,PatientResidentCounty,PatientResidentSubCounty,PatientResidentLocation,PatientResidentSubLocation,PatientResidentWard,PatientResidentVillage,TransferInDate,Occupation,NUPI
			--			FROM [DWAPICentral].[dbo].[PatientExtract]  P  with (NoLock)
			--			INNER JOIN [DWAPICentral].[dbo].[Facility] F with (NoLock)  ON P.[FacilityId] = F.Id AND F.Voided=0 
			--			---INNER JOIN FacilityManifest_MaxDateRecieved(NoLock) a ON F.Code = a.SiteCode
			--			WHERE P.Voided=0 and P.[Gender] is NOT NULL and p.gender!='Unknown' ) AS b 
			--			ON(a.PatientID=b.PatientID and a.PatientPK = b.PatientPK and a.SiteCode = b.SiteCode)
			--WHEN MATCHED THEN
			--UPDATE SET 
			--a.FacilityName = B.FacilityName
			--WHEN NOT MATCHED THEN 
			--INSERT(PatientID,PatientPK,SiteCode,FacilityName,Gender,DOB,RegistrationDate,RegistrationAtCCC,RegistrationAtPMTCT,RegistrationAtTBClinic,PatientSource,Region,District,Village,ContactRelation,LastVisit,MaritalStatus,EducationLevel,DateConfirmedHIVPositive,PreviousARTExposure,PreviousARTStartDate,Emr,Project,Orphan,Inschool,PatientType,PopulationType,KeyPopulationType,PatientResidentCounty,PatientResidentSubCounty,PatientResidentLocation,PatientResidentSubLocation,PatientResidentWard,PatientResidentVillage,TransferInDate,Occupation,NUPI) 
			--VALUES(PatientID,PatientPK,SiteCode,FacilityName,Gender,DOB,RegistrationDate,RegistrationAtCCC,RegistrationAtPMTCT,RegistrationAtTBClinic,PatientSource,Region,District,Village,ContactRelation,LastVisit,MaritalStatus,EducationLevel,DateConfirmedHIVPositive,PreviousARTExposure,PreviousARTStartDate,Emr,Project,Orphan,Inschool,PatientType,PopulationType,KeyPopulationType,PatientResidentCounty,PatientResidentSubCounty,PatientResidentLocation,PatientResidentSubLocation,PatientResidentWard,PatientResidentVillage,TransferInDate,Occupation,NUPI);
			
	END


