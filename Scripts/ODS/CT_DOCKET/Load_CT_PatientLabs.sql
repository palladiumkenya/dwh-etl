BEGIN
		;with cte AS ( Select            
					f.code,
					pl.PatientId,
						P.[PatientPID],
						visitID,pl.created,
						OrderedbyDate,TestResult,TestName,  ROW_NUMBER() OVER (PARTITION BY P.PatientPID,F.code ,visitID,OrderedbyDate,TestResult,TestName
					ORDER BY pl.created desc) Row_Num
			FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
			INNER JOIN [DWAPICentral].[dbo].[PatientLaboratoryExtract](NoLock) PL ON PL.[PatientId]= P.ID AND PL.Voided=0
			INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0
			WHERE p.gender!='Unknown' ) 
			
			--select * from  cte  where Row_Num >1
		
			delete pb from  [DWAPICentral].[dbo].[PatientLaboratoryExtract](NoLock) pb
			inner join [DWAPICentral].[dbo].[PatientExtract](NoLock) P ON PB.[PatientId]= P.ID AND PB.Voided = 0       
			inner join [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0       
			inner join cte on cte.PatientId = pb.PatientId   
				and cte.Code =  f.Code    
				and cte.VisitId =pb.VisitId
				and cte.OrderedByDate = pb.OrderedByDate
				and cte.TestResult = pb.TestResult
				and cte.TestName = pb.TestName
				and cte.created = pb.created
			where  Row_Num  > 1;

			

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
						   END AS [Project] 
						,PL.DateSampleTaken,
						PL.SampleType,
						p.ID ,
						reason,PL.[Date_Created],PL.[Date_Last_Modified]
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
						--and a.ID		=b.ID
						)

												
					WHEN NOT MATCHED THEN 
						INSERT(ID,PatientID,PatientPk,SiteCode,FacilityName,VisitID,OrderedbyDate,ReportedbyDate,TestName,EnrollmentTest,TestResult,Emr,Project,DateSampleTaken,SampleType,reason,[Date_Created],[Date_Last_Modified]) 
						VALUES(ID,PatientID,PatientPk,SiteCode,FacilityName,VisitID,OrderedbyDate,ReportedbyDate,TestName,EnrollmentTest,TestResult,Emr,Project,DateSampleTaken,SampleType,reason,[Date_Created],[Date_Last_Modified])
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.PatientID			=b.PatientID,
							a.FacilityName		=b.FacilityName	,
							a.EnrollmentTest	=b.EnrollmentTest,		
							a.DateSampleTaken	=b.DateSampleTaken	,
							a.SampleType		=b.SampleType,
							a.reason			=b.reason,
							a.[Date_Created]			=b.[Date_Created],
							a.[Date_Last_Modified]		=b.[Date_Last_Modified];

					

					UPDATE [ODS].[dbo].[CT_PatientLabs_Log]
					SET LoadEndDateTime = GETDATE()
					WHERE MaxOrderedbyDate =  @OrderedbyDate;

				INSERT INTO [ODS].[dbo].[CT_PatientLabsCount_Log]([SiteCode],[CreatedDate],[PatientLabsCount])
				SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS PatientLabsCount 
				FROM [ODS].[dbo].[CT_PatientLabs] 
				--WHERE @MaxCreatedDate  > @MaxCreatedDate
				GROUP BY SiteCode;

	END
