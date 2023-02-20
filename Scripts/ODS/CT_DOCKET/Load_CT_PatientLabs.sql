BEGIN
		 DECLARE @MaxOrderedbyDate_Hist			DATETIME,
				   @OrderedbyDate					DATETIME
				
		SELECT @MaxOrderedbyDate_Hist =  MAX(MaxOrderedbyDate) FROM [ODS].[dbo].[CT_PatientLabs_Log]  (NoLock)
		SELECT  @OrderedbyDate = MAX(OrderedbyDate) FROM [DWAPICentral].[dbo].[PatientLaboratoryExtract] WITH (NOLOCK) 		
					
		INSERT INTO  [ODS].[dbo].[CT_PatientLabs_Log](MaxOrderedbyDate,LoadStartDateTime)
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
						   null as Created
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
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitID		=b.VisitID
						and a.OrderedbyDate	=b.OrderedbyDate
						and  a.TestResult =  b.TestResult					
						and  a.TestName =  b.TestName 
						and a.PatientUnique_ID		=b.UniquePatientLabID
						)

												
					WHEN NOT MATCHED THEN 
						INSERT(PatientID,PatientPk,SiteCode,FacilityName,VisitID,OrderedbyDate,ReportedbyDate,TestName,EnrollmentTest,TestResult,Emr,Project,DateImported,Reason,DateSampleTaken,SampleType,Created) 
						VALUES(PatientID,PatientPk,SiteCode,FacilityName,VisitID,OrderedbyDate,ReportedbyDate,TestName,EnrollmentTest,TestResult,Emr,Project,DateImported,Reason,DateSampleTaken,SampleType,Created)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.FacilityName		=b.FacilityName	,
							a.EnrollmentTest	=b.EnrollmentTest,
							a.Reason			=b.Reason		,
							a.DateSampleTaken	=b.DateSampleTaken	,
							a.SampleType		=b.SampleType;
							
					UPDATE [ODS].[dbo].[CT_PatientLabs_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxOrderedbyDate =  @OrderedbyDate;

				INSERT INTO [ODS].[dbo].[CT_PatientLabsCount_Log]([SiteCode],[CreatedDate],[PatientLabsCount])
				SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS PatientLabsCount 
				FROM [ODS].[dbo].[CT_PatientLabs] 
				--WHERE @MaxCreatedDate  > @MaxCreatedDate
				GROUP BY SiteCode;

	END
