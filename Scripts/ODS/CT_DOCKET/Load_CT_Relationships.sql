
BEGIN

	       ---- Refresh [ODS].[dbo].[CT_Covid]
			MERGE [ODS].[dbo].[CT_Relationships] AS a
				USING(SELECT distinct P.[PatientPID] AS PatientPK
							,P.[PatientCccNumber] AS PatientID
							,P.[Emr]
							,P.[Project]
							,F.Code AS SiteCode
							,F.Name AS FacilityName 
							,R.[Voided]
							,R.[Processed]
							,R.[Id]
							,[RelationshipToPatient]
							,[StartDate]
							,[EndDate]
							,R.[RecordUUID]
							,R.[Date_Created]
							,R.[Date_Last_Modified]
							,R.[Created]
						FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
						INNER JOIN [DWAPICentral].[dbo].[RelationshipsExtract](NoLock) R  ON R.[PatientId]= P.ID 
						INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id  AND F.Voided=0
					WHERE P.gender != 'Unknown' AND F.code >0) AS b 
						ON(
						 a.SiteCode = b.SiteCode
						and  a.PatientPK  = b.PatientPK 
						and a.voided   = b.voided
						and a.[RecordUUID] = b.[RecordUUID]
						and a.ID = b.ID
						)

					WHEN NOT MATCHED THEN 
						INSERT(SiteCode,PatientPK,PatientID,Emr,Project,Voided,Id,FacilityName,RelationshipToPatient,StartDate,EndDate,RecordUUID,Date_Created,Date_Last_Modified,Created,LoadDate)  
						VALUES(SiteCode,PatientPK,PatientID,Emr,Project,Voided,Id,FacilityName,RelationshipToPatient,StartDate,EndDate,RecordUUID,Date_Created,Date_Last_Modified,Created,Getdate())
				
					WHEN MATCHED THEN
						UPDATE SET 						
						a.[PatientID]=b.[PatientID],
						a.[Emr]=b.[Emr],
						a.[Project]=b.[Project],
						a.[Voided]=b.[Voided],
						a.[Id]=b.[Id],
						a.[FacilityName]=b.[FacilityName],
						a.[RelationshipToPatient]=b.[RelationshipToPatient],
						a.[StartDate]=b.[StartDate],
						a.[EndDate]=b.[EndDate],
						a.[RecordUUID]=b.[RecordUUID],
						a.[Date_Created]=b.[Date_Created],
						a.[Date_Last_Modified]=b.[Date_Last_Modified],
						a.[Created]=b.[Created];
											


	END
