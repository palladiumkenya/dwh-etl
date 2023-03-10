BEGIN

			MERGE [ODS].[dbo].[CT_ARTPatients]  AS a
				USING(SELECT  DISTINCT
						P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,F.Name AS FacilityName, PA.[AgeEnrollment]
						,PA.[AgeARTStart],PA.[AgeLastVisit],PA.[RegistrationDate],PA.[PatientSource],PA.[Gender],PA.[StartARTDate],PA.[PreviousARTStartDate]
						,PA.[PreviousARTRegimen],PA.[StartARTAtThisFacility],PA.[StartRegimen],PA.[StartRegimenLine],PA.[LastARTDate],PA.[LastRegimen]
						,PA.[LastRegimenLine],PA.[Duration],PA.[ExpectedReturn],PA.[Provider],PA.[LastVisit],PA.[ExitReason],PA.[ExitDate],P.[Emr]
								,CASE P.[Project] 
									WHEN 'I-TECH' THEN 'Kenya HMIS II' 
									WHEN 'HMIS' THEN 'Kenya HMIS II'
								ELSE P.[Project] 
								END AS [Project]
								,PA.[DOB]

						,PA.[PreviousARTUse]
						,PA.[PreviousARTPurpose]
						,PA.[DateLastUsed]
						,GETDATE () AS DateAsOf
						FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
						INNER JOIN [DWAPICentral].[dbo].[PatientArtExtract](NoLock) PA ON PA.[PatientId]= P.ID AND PA.Voided=0
						INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0 
						INNER JOIN (SELECT a.PatientPID,c.code,Max(b.created)MaxCreated FROM [DWAPICentral].[dbo].[PatientExtract]  a  with (NoLock)
											INNER JOIN [DWAPICentral].[dbo].[PatientArtExtract] b with(NoLock) ON b.[PatientId]= a.ID AND b.Voided=0
											INNER JOIN [DWAPICentral].[dbo].[Facility] c with (NoLock)  ON a.[FacilityId] = c.Id AND c.Voided=0 
											GROUP BY  a.PatientPID,c.code)tn
									on P.PatientPID = tn.PatientPID and F.code = tn.code and PA.Created = tn.MaxCreated
						WHERE p.gender!='Unknown') AS b	
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.lastvisit = b.lastvisit
						
						)
					
					WHEN NOT MATCHED THEN 

						INSERT(
							  PatientID,PatientPK,SiteCode,FacilityName,AgeEnrollment,AgeARTStart,AgeLastVisit,RegistrationDate,PatientSource,Gender,StartARTDate,PreviousARTStartDate,PreviousARTRegimen,StartARTAtThisFacility,StartRegimen,StartRegimenLine,LastARTDate,LastRegimen,
							  LastRegimenLine,Duration,ExpectedReturn,Provider,LastVisit,ExitReason,ExitDate,Emr,Project,[DOB],PreviousARTUse,PreviousARTPurpose,DateLastUsed,DateAsOf
							  ) 
						VALUES(
								PatientID,PatientPK,SiteCode,FacilityName,AgeEnrollment,AgeARTStart,AgeLastVisit,RegistrationDate,PatientSource,Gender,StartARTDate,PreviousARTStartDate,PreviousARTRegimen,StartARTAtThisFacility,StartRegimen,StartRegimenLine,LastARTDate,LastRegimen,
								LastRegimenLine,Duration,ExpectedReturn,Provider,LastVisit,ExitReason,ExitDate,Emr,Project,[DOB],PreviousARTUse,PreviousARTPurpose,DateLastUsed,DateAsOf
						      )
				
					WHEN MATCHED THEN
						UPDATE SET 																								
								a.[AgeEnrollment]			=b.[AgeEnrollment],
								a.[AgeARTStart]				=b.[AgeARTStart],	
								a.[AgeLastVisit]			=b.[AgeLastVisit],
								a.[FacilityName]			=b.[FacilityName],
								a.[RegistrationDate]		=b.[RegistrationDate],
								a.[PatientSource]			=b.[PatientSource],
								a.[Gender]					=b.[Gender]	,
								a.[StartARTDate]			=b.[StartARTDate],
								a.[PreviousARTStartDate]	=b.[PreviousARTStartDate],
								a.[PreviousARTRegimen]		=b.[PreviousARTRegimen]	,
								a.[StartARTAtThisFacility]	=b.[StartARTAtThisFacility],
								a.[StartRegimen]			=b.[StartRegimen],
								a.[StartRegimenLine]		=b.[StartRegimenLine],
								a.[LastARTDate]				=b.[LastARTDate],	
								a.[LastRegimen]				=b.[LastRegimen],	
								a.[LastRegimenLine]			=b.[LastRegimenLine],	
								a.[Duration]				=b.[Duration],
								a.[ExpectedReturn]			=b.[ExpectedReturn],
								a.[Provider]				=b.[Provider],
								a.[ExitReason]				=b.[ExitReason]	,
								a.[ExitDate]				=b.[ExitDate],
								a.[Emr]						=b.[Emr],			
								a.[PreviousARTUse]			=b.[PreviousARTUse]	,
								a.[PreviousARTPurpose]		=b.[PreviousARTPurpose],
								a.[DateLastUsed]			=b.[DateLastUsed];

								with cte AS (
								Select
								PatientPK,
								sitecode,
								lastvisit,
								 ROW_NUMBER() OVER (PARTITION BY PatientPK,sitecode,lastvisit ORDER BY
								lastvisit desc) Row_Num
								FROM [ODS].[dbo].[CT_ARTPatients](NoLock)
								)
							delete from cte 
								Where Row_Num >1;

					--UPDATE CT_ARTPatient_Log
					--SET LoadEndDateTime = GETDATE()
					--WHERE MaxVisitDate = @MaxVisitDate_Hist;

					INSERT INTO  [ODS].[dbo].[CT_ARTPatientsCount_Log]([SiteCode],[CreatedDate],ARTPatientsCount)
					SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS PatientStatusCount 
					FROM [ODS].[dbo].[CT_ARTPatients]
					group by SiteCode

			
	END
