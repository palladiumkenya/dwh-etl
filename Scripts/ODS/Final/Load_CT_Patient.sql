BEGIN
			--CREATE INDEX CT_Patient ON [ODS].[dbo].[CT_Patient] (sitecode,PatientPK);
	       ---- Refresh [ODS].[dbo].[CT_Patient]
			MERGE [ODS].[dbo].[CT_Patient] AS a
				USING(SELECT  P.ID,P.[PatientCccNumber] as PatientID,P.[PatientPID] as PatientPK,F.Code as SiteCode,F.[Name] as FacilityName,Gender,DOB,RegistrationDate,RegistrationAtCCC,RegistrationAtPMTCT,RegistrationAtTBClinic,PatientSource,Region,District,Village,ContactRelation,LastVisit,MaritalStatus,EducationLevel,DateConfirmedHIVPositive,PreviousARTExposure,PreviousARTStartDate,P.Emr,P.Project,PKV,Orphan,Inschool,PatientType,PopulationType,KeyPopulationType,PatientResidentCounty,PatientResidentSubCounty,PatientResidentLocation,PatientResidentSubLocation,PatientResidentWard,PatientResidentVillage,TransferInDate,Occupation,NUPI
						,LTRIM(RTRIM(STR(F.Code))) + '-' + LTRIM(RTRIM(P.[PatientCccNumber])) + '-' + LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV

						FROM [DWAPICentral].[dbo].[PatientExtract]  P  with (NoLock)
						INNER JOIN [DWAPICentral].[dbo].[Facility] F with (NoLock)  
						ON P.[FacilityId]  = F.Id  AND F.Voided=0 						
						WHERE P.Voided=0 and P.[Gender] is NOT NULL and p.gender!='Unknown' and P.Processed =1 ) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.RegistrationDate =b.RegistrationDate)
					WHEN MATCHED THEN
						UPDATE SET 
						a.PatientID					=b.PatientID,
						a.FacilityName				=b.FacilityName	,
						a.Gender					=b.Gender,
						a.DOB						=b.DOB,						
						a.RegistrationAtCCC			=b.RegistrationAtCCC,
						a.RegistrationAtPMTCT		=b.RegistrationAtPMTCT,
						a.RegistrationAtTBClinic	=b.RegistrationAtTBClinic,
						a.PatientSource				=b.PatientSource,
						a.Region					=b.Region,
						a.District					=b.District,
						a.Village					=b.Village,
						a.ContactRelation			=b.ContactRelation,
						a.LastVisit					=b.LastVisit,
						a.MaritalStatus				=b.MaritalStatus,
						a.EducationLevel			=b.EducationLevel,
						a.DateConfirmedHIVPositive	=b.DateConfirmedHIVPositive	,
						a.PreviousARTExposure		=b.PreviousARTExposure,
						a.PreviousARTStartDate		=b.PreviousARTStartDate,
						a.Emr						=b.Emr,
						a.Project					=b.Project,
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
						a.NUPI						=b.NUPI,
						a.CKV						=b.CKV
							
					WHEN NOT MATCHED THEN 
						INSERT(ID,PatientID,PatientPK,SiteCode,FacilityName,Gender,DOB,RegistrationDate,RegistrationAtCCC,RegistrationAtPMTCT,RegistrationAtTBClinic,PatientSource,Region,District,Village,ContactRelation,LastVisit,MaritalStatus,EducationLevel,DateConfirmedHIVPositive,PreviousARTExposure,PreviousARTStartDate,Emr,Project,Orphan,Inschool,PatientType,PopulationType,KeyPopulationType,PatientResidentCounty,PatientResidentSubCounty,PatientResidentLocation,PatientResidentSubLocation,PatientResidentWard,PatientResidentVillage,TransferInDate,Occupation,NUPI,CKV) 
						VALUES(ID,PatientID,PatientPK,SiteCode,FacilityName,Gender,DOB,RegistrationDate,RegistrationAtCCC,RegistrationAtPMTCT,RegistrationAtTBClinic,PatientSource,Region,District,Village,ContactRelation,LastVisit,MaritalStatus,EducationLevel,DateConfirmedHIVPositive,PreviousARTExposure,PreviousARTStartDate,Emr,Project,Orphan,Inschool,PatientType,PopulationType,KeyPopulationType,PatientResidentCounty,PatientResidentSubCounty,PatientResidentLocation,PatientResidentSubLocation,PatientResidentWard,PatientResidentVillage,TransferInDate,Occupation,NUPI,CKV);
				
				--DROP INDEX CT_Patient ON [ODS].[dbo].[CT_Patient];
				---Remove any duplicate from [ODS].[dbo].[CT_Patient]
				WITH CTE AS   
					(  
						SELECT [PatientPK],[SiteCode],RegistrationDate,ROW_NUMBER() 
						OVER (PARTITION BY [PatientPK],[SiteCode],RegistrationDate
						ORDER BY [PatientPK],[SiteCode],RegistrationDate) AS dump_ 
						FROM [ODS].[dbo].[CT_Patient] 
						)  
			
				DELETE FROM CTE WHERE dump_ >1;

	END