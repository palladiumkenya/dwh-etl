
BEGIN

			MERGE [ODS].[dbo].[Ushauri_Patient] AS a
				USING(SELECT Distinct
						PatientPK,MPIPKV,null PatientPKHash,PartnerName,SiteCode,SiteType,PatientID,null PatientIDHash,FacilityID,Emr,Project,FacilityName,
						Gender,DOB,RegistrationDate,RegistrationAtCCC,RegistrationAtPMTCT,RegistrationAtTBClinic,PatientSource,Region,District,
						Village,ContactRelation,LastVisit,MaritalStatus,EducationLevel,DateConfirmedHIVPositive,PreviousARTExposure,
						PreviousARTStartDate,StatusAtCCC,StatusAtPMTCT,StatusAtTBClinic,Inschool,KeyPopulationType,Orphan,PatientResidentCounty As County,
						PatientResidentLocation,PatientResidentSubCounty,PatientResidentSubLocation,PatientResidentVillage,
						PatientResidentWard,PatientType,PopulationType,TransferInDate,Occupation,DateCreated,DateModified,StatelitteName,
						Date_Created,Date_Modified,PKV,NUPI
					FROM [mhealthCentral].[dbo].[CT_Patient](NoLock) P
					) AS b	
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode						
						)
					
					WHEN NOT MATCHED THEN 
						INSERT(PatientPK,MPIPKV,PatientPKHash,PartnerName,SiteCode,SiteType,PatientID,PatientIDHash,FacilityID,Emr,Project,FacilityName,Gender,DOB,RegistrationDate,RegistrationAtCCC,RegistrationAtPMTCT,RegistrationAtTBClinic,PatientSource,Region,District,Village,ContactRelation,LastVisit,MaritalStatus,EducationLevel,DateConfirmedHIVPositive,PreviousARTExposure,PreviousARTStartDate,StatusAtCCC,StatusAtPMTCT,StatusAtTBClinic,Inschool,KeyPopulationType,Orphan,County,PatientResidentLocation,PatientResidentSubCounty,PatientResidentSubLocation,PatientResidentVillage,PatientResidentWard,PatientType,PopulationType,TransferInDate,Occupation,DateCreated,DateModified,StatelitteName,Date_Created,Date_Modified,PKV,NUPI,LoadDate) 
						VALUES(PatientPK,MPIPKV,PatientPKHash,PartnerName,SiteCode,SiteType,PatientID,PatientIDHash,FacilityID,Emr,Project,FacilityName,Gender,DOB,RegistrationDate,RegistrationAtCCC,RegistrationAtPMTCT,RegistrationAtTBClinic,PatientSource,Region,District,Village,ContactRelation,LastVisit,MaritalStatus,EducationLevel,DateConfirmedHIVPositive,PreviousARTExposure,PreviousARTStartDate,StatusAtCCC,StatusAtPMTCT,StatusAtTBClinic,Inschool,KeyPopulationType,Orphan,County,PatientResidentLocation,PatientResidentSubCounty,PatientResidentSubLocation,PatientResidentVillage,PatientResidentWard,PatientType,PopulationType,TransferInDate,Occupation,DateCreated,DateModified,StatelitteName,Date_Created,Date_Modified,PKV,NUPI,Getdate())
				
					WHEN MATCHED THEN
						UPDATE SET 						
						a.[MPIPKV]						=	b.[MPIPKV],
						a.[PatientPKHash]					=	b.[PatientPKHash],
						a.[PartnerName]					=	b.[PartnerName],
						a.[SiteType]						=	b.[SiteType],
						a.[PatientID]						=	b.[PatientID],
						a.[PatientIDHash]					=	b.[PatientIDHash],
						a.[FacilityID]					=	b.[FacilityID],
						a.[Emr]							=	b.[Emr],
						a.[Project]						=	b.[Project],
						a.[FacilityName]					=	b.[FacilityName],
						a.[Gender]						=	b.[Gender],
						a.[DOB]							=	b.[DOB],
						a.[RegistrationDate]				=	b.[RegistrationDate],
						a.[RegistrationAtCCC]				=	b.[RegistrationAtCCC],
						a.[RegistrationAtPMTCT]			=	b.[RegistrationAtPMTCT],
						a.[RegistrationAtTBClinic]		=	b.[RegistrationAtTBClinic],
						a.[PatientSource]					=	b.[PatientSource],
						a.[Region]						=	b.[Region],
						a.[District]						=	b.[District],
						a.[Village]						=	b.[Village],
						a.[ContactRelation]				=	b.[ContactRelation],
						a.[LastVisit]						=	b.[LastVisit],
						a.[MaritalStatus]					=	b.[MaritalStatus],
						a.[EducationLevel]				=	b.[EducationLevel],
						a.[DateConfirmedHIVPositive]		=	b.[DateConfirmedHIVPositive],
						a.[PreviousARTExposure]			=	b.[PreviousARTExposure],
						a.[PreviousARTStartDate]			=	b.[PreviousARTStartDate],
						a.[StatusAtCCC]					=	b.[StatusAtCCC],
						a.[StatusAtPMTCT]					=	b.[StatusAtPMTCT],
						a.[StatusAtTBClinic]				=	b.[StatusAtTBClinic],
						a.[Inschool]						=	b.[Inschool],
						a.[KeyPopulationType]				=	b.[KeyPopulationType],
						a.[Orphan]						=	b.[Orphan],
						a.[County]						=	b.[County],
						a.[PatientResidentLocation]		=	b.[PatientResidentLocation],
						a.[PatientResidentSubCounty]		=	b.[PatientResidentSubCounty],
						a.[PatientResidentSubLocation]	=	b.[PatientResidentSubLocation],
						a.[PatientResidentVillage]		=	b.[PatientResidentVillage],
						a.[PatientResidentWard]			=	b.[PatientResidentWard],
						a.[PatientType]					=	b.[PatientType],
						a.[PopulationType]				=	b.[PopulationType],
						a.[TransferInDate]				=	b.[TransferInDate],
						a.[Occupation]					=	b.[Occupation],
						a.[DateCreated]					=	b.[DateCreated],
						a.[DateModified]					=	b.[DateModified],
						a.[StatelitteName]				=	b.[StatelitteName],
						a.[Date_Created]					=	b.[Date_Created],
						a.[Date_Modified]					=	b.[Date_Modified],
						a.[PKV]							=	b.[PKV],
						a.[NUPI]							=	b.[NUPI];

				UPDATE a
				SET  PatientPKHash =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[PatientPk]  as nvarchar(36))), 2),
					PatientIDHash  =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.PatientID  as nvarchar(36))), 2) ,
					NUPIHash  =  convert(nvarchar(64), hashbytes('SHA2_256', cast(a.[NUPI]  as nvarchar(36))), 2) 
				FROM [ODS].[dbo].[Ushauri_Patient] a
		
	END
