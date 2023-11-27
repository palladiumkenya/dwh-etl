BEGIN
			
			 DECLARE @MaxRegistrationDate_Hist			DATETIME,
					 @RegistrationDate					DATETIME
				
			SELECT @MaxRegistrationDate_Hist	= MAX(MaxRegistrationDate) FROM [ODS].[dbo].[CT_Patient_Log]  (NoLock)
			SELECT @RegistrationDate			= MAX(RegistrationDate) FROM [DWAPICentral].[dbo].[PatientExtract] (NoLock)
									
			INSERT INTO  [ODS].[dbo].[CT_Patient_Log](MaxRegistrationDate,LoadStartDateTime)
			VALUES(@RegistrationDate,GETDATE())
			--truncate table [ODS].[dbo].[CT_Patient] 
			MERGE [ODS].[dbo].[CT_Patient] AS a
				USING(SELECT  DISTINCT P.ID,P.[PatientCccNumber] as PatientID,P.[PatientPID] as PatientPK,F.Code as SiteCode,F.[Name] as FacilityName,Gender,DOB,RegistrationDate,RegistrationAtCCC
										,RegistrationAtPMTCT,RegistrationAtTBClinic,PatientSource,Region,District,Village
									   ,ContactRelation,LastVisit,MaritalStatus,EducationLevel,DateConfirmedHIVPositive,PreviousARTExposure,PreviousARTStartDate,P.Emr,P.Project,Orphan,Inschool,null PatientType,null PopulationType,KeyPopulationType,PatientResidentCounty,
									   PatientResidentSubCounty,PatientResidentLocation,PatientResidentSubLocation,PatientResidentWard,PatientResidentVillage,TransferInDate,Occupation,NUPI
									   ,Pkv,P.[Date_Created],P.[Date_Last_Modified]
						FROM [DWAPICentral].[dbo].[PatientExtract]  P  with (NoLock)
						INNER JOIN [DWAPICentral].[dbo].[Facility] F with (NoLock)  
						ON P.[FacilityId]  = F.Id  AND F.Voided=0 	
						INNER JOIN (SELECT P.PatientPID,F.code,Max(P.created)MaxCreated FROM [DWAPICentral].[dbo].[PatientExtract]  P  with (NoLock)
									INNER JOIN [DWAPICentral].[dbo].[Facility] F with (NoLock)  
									ON P.[FacilityId]  = F.Id  AND F.Voided=0 
									GROUP BY  P.PatientPID,F.code)tn
							on P.PatientPID = tn.PatientPID and F.code = tn.code and P.Created = tn.MaxCreated
						WHERE P.Voided=0 and P.[Gender] is NOT NULL and p.gender!='Unknown' AND F.code >0 ) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID =b.ID

						)

						WHEN NOT MATCHED THEN 
						INSERT(ID,PatientID,PatientPK,SiteCode,FacilityName,Gender,DOB,RegistrationDate,RegistrationAtCCC,RegistrationAtPMTCT,RegistrationAtTBClinic,PatientSource,Region,District,Village,ContactRelation,LastVisit,MaritalStatus,EducationLevel,DateConfirmedHIVPositive,PreviousARTExposure,PreviousARTStartDate,Emr,Project,Orphan,Inschool,PatientType,PopulationType,KeyPopulationType,PatientResidentCounty,PatientResidentSubCounty,PatientResidentLocation,PatientResidentSubLocation,PatientResidentWard,PatientResidentVillage,TransferInDate,Occupation,NUPI,Pkv,[Date_Created],[Date_Last_Modified],LoadDate)  
						VALUES(ID,PatientID,PatientPK,SiteCode,FacilityName,Gender,DOB,RegistrationDate,RegistrationAtCCC,RegistrationAtPMTCT,RegistrationAtTBClinic,PatientSource,Region,District,Village,ContactRelation,LastVisit,MaritalStatus,EducationLevel,DateConfirmedHIVPositive,PreviousARTExposure,PreviousARTStartDate,Emr,Project,Orphan,Inschool,PatientType,PopulationType,KeyPopulationType,PatientResidentCounty,PatientResidentSubCounty,PatientResidentLocation,PatientResidentSubLocation,PatientResidentWard,PatientResidentVillage,TransferInDate,Occupation,NUPI,Pkv,[Date_Created],[Date_Last_Modified],Getdate())
				
						WHEN MATCHED THEN
							UPDATE SET 				
							a.PatientID					=b.PatientID,
							a.PatientSource				=b.PatientSource,							
							a.ContactRelation			=b.ContactRelation,
							a.LastVisit					=b.LastVisit,
							a.MaritalStatus				=b.MaritalStatus,
							a.DateConfirmedHIVPositive	=b.DateConfirmedHIVPositive	,
							a.PreviousARTExposure		=b.PreviousARTExposure,
							a.PreviousARTStartDate		=b.PreviousARTStartDate,
							a.Orphan					=b.Orphan,
							a.Inschool					=b.Inschool	,
							a.PatientType				=b.PatientType,
							a.PopulationType			=b.PopulationType,
							a.KeyPopulationType			=b.KeyPopulationType,
							a.PatientResidentCounty		=b.PatientResidentCounty,
							a.PatientResidentSubCounty	=b.PatientResidentSubCounty,
							a.PatientResidentLocation	=b.PatientResidentLocation,
							a.PatientResidentSubLocation=b.PatientResidentSubLocation,
							a.PatientResidentWard		=b.PatientResidentWard	,
							a.PatientResidentVillage	=b.PatientResidentVillage,
							a.TransferInDate			=b.TransferInDate,
							a.Occupation				=b.Occupation,
							a.Pkv						=b.Pkv,
							a.[Date_Created]			=b.[Date_Created],
							a.[Date_Last_Modified]		=b.[Date_Last_Modified];
							
					
						with cte AS (
						Select
						PatientPK,
						Sitecode,
						

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode ORDER BY
						PatientPK,Sitecode) Row_Num
						FROM [ODS].[dbo].[CT_Patient](NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;


					UPDATE [ODS].[dbo].[CT_Patient_Log]
						SET LoadEndDateTime = GETDATE()
					WHERE MaxRegistrationDate = @RegistrationDate;

					INSERT INTO [ODS].[dbo].[CT_PatientCount_Log]([SiteCode],[CreatedDate],[PatientCount])
					SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS PatientCount 
					FROM [ODS].[dbo].[CT_Patient] 
					--WHERE @MaxCreatedDate  > @MaxCreatedDate
					GROUP BY SiteCode;
	END
 
