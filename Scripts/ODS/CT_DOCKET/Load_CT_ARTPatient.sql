BEGIN
  TRUNCATE TABLE [ODS].[dbo].[CT_ARTPatients] ---So as we can only have the most current snapshot. Need to think of a way to incrementally load this( More discusion btw Wambui,Koske,Dennis and Mumo)
 
			INSERT into [ODS].[dbo].[CT_ARTPatients] (PatientID,PatientPK,SiteCode,FacilityName,AgeEnrollment,
								AgeARTStart,AgeLastVisit,RegistrationDate,PatientSource,Gender,StartARTDate,PreviousARTStartDate,
								PreviousARTRegimen,StartARTAtThisFacility,StartRegimen,StartRegimenLine,LastARTDate,LastRegimen,
								LastRegimenLine,Duration,ExpectedReturn,Provider,LastVisit,ExitReason,ExitDate,Emr,
								Project,[DOB],PreviousARTUse,PreviousARTPurpose,DateLastUsed,DateAsOf) 
			SELECT  DISTINCT
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
				WHERE p.gender!='Unknown';

				
			--TRUNCATE TABLE [ODS].[dbo].[CT_ARTPatientsCount_Log]
			INSERT INTO  [ODS].[dbo].[CT_ARTPatientsCount_Log]([SiteCode],[CreatedDate],ARTPatientsCount)
				SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS PatientStatusCount 
				FROM [ODS].[dbo].[CT_ARTPatients]
				group by SiteCode
				

	END