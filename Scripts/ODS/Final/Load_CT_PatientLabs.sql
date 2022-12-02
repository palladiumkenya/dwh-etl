BEGIN
		 DECLARE @MaxOrderedbyDate_Hist			DATETIME,
				   @OrderedbyDate					DATETIME
				
		SELECT @MaxOrderedbyDate_Hist =  MAX(MaxOrderedbyDate) FROM [dbo].[CT_PatientLabs_Log]  (NoLock)
		SELECT  @OrderedbyDate = MAX(OrderedbyDate) FROM [DWAPICentral].[dbo].[PatientLaboratoryExtract] WITH (NOLOCK) 		
					
		INSERT INTO  [dbo].[CT_PatientLabs_Log](MaxOrderedbyDate,LoadStartDateTime)
		VALUES( @OrderedbyDate,GETDATE())
	
	       ---- Refresh [ODS].[dbo].[CT_PatientLabs]
			MERGE [ODS].[dbo].[CT_PatientLabs] AS a
				USING(SELECT distinct
						  P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,F.Name AS FacilityName, 
						  PL.[VisitId],PL.[OrderedByDate],PL.[ReportedByDate],PL.[TestName],
						  PL.[EnrollmentTest],PL.[TestResult],P.[Emr]
						  ,CASE P.[Project] 
								WHEN 'I-TECH' THEN 'Kenya HMIS II' 
								WHEN 'HMIS' THEN 'Kenya HMIS II'
						   ELSE P.[Project] 
						   END AS [Project] ,
						   Getdate() as DateImported,
						   null as Reason,
						   null as Created,
						   LTRIM(RTRIM(STR(F.Code)))+'-'+LTRIM(RTRIM(P.[PatientCccNumber]))+'-'+LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV
						  
					-------------------- Added by Dennis as missing columns
						,PL.DateSampleTaken,
						PL.SampleType,
						p.ID as PatientUnique_ID,
						PL.PatientID as UniquePatientLabID,
						PL.ID as PatientLabsUnique_ID

					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
					INNER JOIN [DWAPICentral].[dbo].[PatientLaboratoryExtract](NoLock) PL ON PL.[PatientId]= P.ID AND PL.Voided=0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0
					WHERE p.gender!='Unknown') AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitID		=b.VisitID
						and a.OrderedbyDate	=b.OrderedbyDate
						and  a.TestResult COLLATE SQL_Latin1_General_CP1_CI_AS =  b.TestResult COLLATE SQL_Latin1_General_CP1_CI_AS						
						and  a.TestName COLLATE SQL_Latin1_General_CP1_CI_AS =  b.TestName COLLATE SQL_Latin1_General_CP1_CI_AS
						and a.PatientUnique_ID		=b.UniquePatientLabID
						and a.PatientLabsUnique_ID = b.PatientLabsUnique_ID
						)

												
					WHEN NOT MATCHED THEN 
						INSERT(PatientID,PatientPk,SiteCode,FacilityName,VisitID,OrderedbyDate,ReportedbyDate,TestName,EnrollmentTest,TestResult,Emr,Project,DateImported,CKV,Reason,DateSampleTaken,SampleType,Created) 
						VALUES(PatientID,PatientPk,SiteCode,FacilityName,VisitID,OrderedbyDate,ReportedbyDate,TestName,EnrollmentTest,TestResult,Emr,Project,DateImported,CKV,Reason,DateSampleTaken,SampleType,Created)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.PatientID			=b.PatientID	,
							a.FacilityName		=b.FacilityName	,
							a.ReportedbyDate	=b.ReportedbyDate,
							--a.TestName			=b.TestName		,
							a.EnrollmentTest	=b.EnrollmentTest,
							 
							a.Emr				=b.Emr			,
							a.Project			=b.Project		,
							a.DateImported		=b.DateImported	,
							a.Reason			=b.Reason		,
							a.DateSampleTaken	=b.DateSampleTaken	,
							a.SampleType		=b.SampleType		,
							a.Created			=b.Created			,
							a.CKV				=b.CKV	
							
					WHEN NOT MATCHED BY SOURCE 
						THEN
						/* The Record is in the target table but doen't exit on the source table*/
							Delete;

					UPDATE [dbo].[CT_PatientLabs_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxOrderedbyDate =  @OrderedbyDate;

				INSERT INTO [ODS].[dbo].[CT_PatientLabsCount_Log]([SiteCode],[CreatedDate],[PatientLabsCount])
				SELECT SiteCode,GETDATE(),COUNT(SiteCode) AS PatientLabsCount 
				FROM [ODS].[dbo].[CT_PatientLabs] 
				--WHERE @MaxCreatedDate  > @MaxCreatedDate
				GROUP BY SiteCode;

				--DROP INDEX CT_PatientLabs ON [ODS].[dbo].[CT_PatientLabs];
				---Remove any duplicate from [ODS].[dbo].[CT_PatientLabs]
				--WITH CTE AS   
				--	(  
				--		SELECT [PatientPK],[SiteCode],VisitID,OrderedbyDate,ROW_NUMBER() 
				--		OVER (PARTITION BY [PatientPK],[SiteCode],VisitID,OrderedbyDate
				--		ORDER BY [PatientPK],[SiteCode],VisitID,OrderedbyDate) AS dump_ 
				--		FROM [ODS].[dbo].[CT_PatientLabs] 
				--		)  
			
				--DELETE FROM CTE WHERE dump_ >1;

	END