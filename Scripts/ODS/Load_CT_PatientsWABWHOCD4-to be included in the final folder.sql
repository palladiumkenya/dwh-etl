BEGIN
			--CREATE INDEX CT_PatientsWABWHOCD4 ON [ODS].[dbo].[CT_PatientsWABWHOCD4] (sitecode,PatientPK);
	       ---- Refresh [ODS].[dbo].[CT_PatientsWABWHOCD4]
			MERGE [ODS].[dbo].[CT_PatientsWABWHOCD4] AS a
				USING(SELECT  P.[PatientCccNumber] AS PatientID, 
								  P.[PatientPID] AS PatientPK,
								  F.Name AS FacilityName, 
								  F.Code AS SiteCode,
								  PB.[eCD4]
								  ,PB.[eCD4Date]
								  ,PB.[eWHO]
								  ,PB.[eWHODate]
								  ,PB.[bCD4]
								  ,PB.[bCD4Date]
								  ,PB.[bWHO]
								  ,PB.[bWHODate]
								  ,PB.[lastWHO]
								  ,PB.[lastWHODate]
								  ,PB.[lastCD4]
								  ,PB.[lastCD4Date]
								  ,PB.[m12CD4]
								  ,PB.[m12CD4Date]
								  ,PB.[m6CD4]
								  ,PB.[m6CD4Date]
								  ,P.[Emr]
								  ,CASE P.[Project] 
										WHEN 'I-TECH' THEN 'Kenya HMIS II' 
										WHEN 'HMIS' THEN 'Kenya HMIS II'
								   ELSE P.[Project] 
								   END AS [Project] 
								  ,PB.[Voided]
								  ,PB.[Processed]
								  ,PB.[bWAB]
								  ,PB.[bWABDate]
								  ,PB.[eWAB]
								  ,PB.[eWABDate]
								  ,PB.[lastWAB]
								  ,PB.[lastWABDate]
								  ,PB.[Created]
								  ,LTRIM(RTRIM(STR(F.Code)))+'-'+LTRIM(RTRIM(P.[PatientCccNumber])) +'-'+LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV
							  ,P.ID
							  ,PB.ID
							FROM [Dwapicentral].[dbo].[PatientExtract](NoLock) P 
							INNER JOIN [Dwapicentral].[dbo].[PatientArtExtract](NoLock) PA ON PA.[PatientId]= P.ID
							INNER JOIN [Dwapicentral].[dbo].[PatientBaselinesExtract](NoLock) PB ON PB.[PatientId]= P.ID AND PB.Voided=0
							INNER JOIN [Dwapicentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0
							WHERE p.gender!='Unknown') AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode)
					WHEN MATCHED THEN
						UPDATE SET 
						a.PatientID									=b.PatientID,
						a.SiteCode									=b.SiteCode,
						a.bCD4										=b.bCD4,
						a.bCD4Date									=b.bCD4Date,
						a.bWHO										=b.bWHO,
						a.bWHODate									=b.bWHODate,
						a.eCD4										=b.eCD4,
						a.eCD4Date									=b.eCD4Date,
						a.eWHO										=b.eWHO,
						a.eWHODate									=b.eWHODate,
						a.lastWHO									=b.lastWHO,
						a.lastWHODate								=b.lastWHODate,
						a.lastCD4									=b.lastCD4,
						a.lastCD4Date								=b.lastCD4Date,
						a.m12CD4									=b.m12CD4,
						a.m12CD4Date								=b.m12CD4Date,
						a.m6CD4										=b.m6CD4,
						a.m6CD4Date									=b.m6CD4Date,
						a.PatientPK									=b.PatientPK,
						a.Emr										=b.Emr,
						a.Project									=b.Project
						--a.CD4atEnrollment							=b.CD4atEnrollment,
						--a.CD4atEnrollment_Date						=b.CD4atEnrollment_Date,
						--a.CD4BeforeARTStart							=b.CD4BeforeARTStart,
						--a.CD4BeforeARTStart_Date					=b.CD4BeforeARTStart_Date,
						--a.LastCD4AfterARTStart						=b.LastCD4AfterARTStart,
						--a.LastCD4AfterARTStart_Date					=b.LastCD4AfterARTStart_Date,
						--a.CD4atEnrollmentPercent					=b.CD4atEnrollmentPercent,
						--a.CD4atEnrollmentPercent_Date				=b.CD4atEnrollmentPercent_Date,
						--a.CD4BeforeARTStartPercent					=b.CD4BeforeARTStartPercent,
						--a.CD4BeforeARTStartPercent_Date				=b.CD4BeforeARTStartPercent_Date,
						--a.LastCD4AfterARTStartPercent				=b.LastCD4AfterARTStartPercent,
						--a.LastCD4AfterARTStartPercent_Date			=b.LastCD4AfterARTStartPercent_Date,
						--a.[6MonthCD4]								=b.[6MonthCD4],
						--a.[6MonthCD4_Date]							=b.[6MonthCD4_Date],
						--a.[12MonthCD4]								=b.[12MonthCD4],
						--a.[12MonthCD4_Date]							=b.[12MonthCD4_Date],
						--a.[6MonthCD4Percent]						=b.[6MonthCD4Percent],
						--a.[6MonthCD4Percent_Date]					=b.[6MonthCD4Percent_Date],
						--a.[12MonthCD4Percent]						=b.[12MonthCD4Percent],
						--a.[12MonthCD4Percent_Date]					=b.[12MonthCD4Percent_Date],
						--a.[FirstCD4AfterARTStart]					=b.[FirstCD4AfterARTStart],
						--a.[FirstCD4AfterARTStart_Date]				=b.[FirstCD4AfterARTStart_Date],
						--a.[FirtsCD4AfterARTStartPercent]			=b.[FirtsCD4AfterARTStartPercent],
						--a.[FirtsCD4AfterARTStartPercent_date]		=b.[FirtsCD4AfterARTStartPercent_date],
						--a.[DateImported]							=b.[DateImported],
						--a.[6MonthVL]								=b.[6MonthVL],
						--a.[6MonthVlDate]							=b.[6MonthVlDate],
						--a.[12MonthVL]								=b.[12MonthVL],
						--a.[12MonthVLDate]							=b.[12MonthVLDate],
						--a.[LstickBaselineCD4]						=b.[LstickBaselineCD4],
						--a.[LstickBaselineCD4_Date]					=b.[LstickBaselineCD4_Date],
						--a.[CKV]										=b.[CKV],
						--a.[18MonthVL]								=b.[18MonthVL],
						--a.[18MonthVlDate]							=b.[18MonthVlDate],
						--a.[24MonthVL]								=b.[24MonthVL],
						--a.[24MonthVLDate]							=b.[24MonthVLDate]

							
					WHEN NOT MATCHED THEN 
						INSERT(PatientID,SiteCode,bCD4,bCD4Date,bWHO,bWHODate,eCD4,eCD4Date,eWHO,eWHODate,lastWHO,lastWHODate,lastCD4,lastCD4Date,m12CD4,m12CD4Date,m6CD4,m6CD4Date,PatientPK,Emr,Project /*,CD4atEnrollment,CD4atEnrollment_Date,CD4BeforeARTStart,CD4BeforeARTStart_Date,LastCD4AfterARTStart,LastCD4AfterARTStart_Date,CD4atEnrollmentPercent,CD4atEnrollmentPercent_Date,CD4BeforeARTStartPercent,CD4BeforeARTStartPercent_Date,LastCD4AfterARTStartPercent,LastCD4AfterARTStartPercent_Date,[6MonthCD4],[6MonthCD4_Date],[12MonthCD4],[12MonthCD4_Date],[6MonthCD4Percent],[6MonthCD4Percent_Date],[12MonthCD4Percent],[12MonthCD4Percent_Date],FirstCD4AfterARTStart,FirstCD4AfterARTStart_Date,FirtsCD4AfterARTStartPercent,FirtsCD4AfterARTStartPercent_date,DateImported,[6MonthVL],[6MonthVlDate],[12MonthVL],[12MonthVLDate],LstickBaselineCD4,LstickBaselineCD4_Date,CKV,[18MonthVL],[18MonthVlDate],[24MonthVL],[24MonthVLDate]*/) 
						VALUES(PatientID,SiteCode,bCD4,bCD4Date,bWHO,bWHODate,eCD4,eCD4Date,eWHO,eWHODate,lastWHO,lastWHODate,lastCD4,lastCD4Date,m12CD4,m12CD4Date,m6CD4,m6CD4Date,PatientPK,Emr,Project /*,CD4atEnrollment,CD4atEnrollment_Date,CD4BeforeARTStart,CD4BeforeARTStart_Date,LastCD4AfterARTStart,LastCD4AfterARTStart_Date,CD4atEnrollmentPercent,CD4atEnrollmentPercent_Date,CD4BeforeARTStartPercent,CD4BeforeARTStartPercent_Date,LastCD4AfterARTStartPercent,LastCD4AfterARTStartPercent_Date,[6MonthCD4],[6MonthCD4_Date],[12MonthCD4],[12MonthCD4_Date],[6MonthCD4Percent],[6MonthCD4Percent_Date],[12MonthCD4Percent],[12MonthCD4Percent_Date],FirstCD4AfterARTStart,FirstCD4AfterARTStart_Date,FirtsCD4AfterARTStartPercent,FirtsCD4AfterARTStartPercent_date,DateImported,[6MonthVL],[6MonthVlDate],[12MonthVL],[12MonthVLDate],LstickBaselineCD4,LstickBaselineCD4_Date,CKV,[18MonthVL],[18MonthVlDate],[24MonthVL],[24MonthVLDate]*/);
				
				--DROP INDEX CT_PatientsWABWHOCD4 ON [ODS].[dbo].[CT_PatientsWABWHOCD4];
				---Remove any duplicate from [ODS].[dbo].[CT_PatientsWABWHOCD4]
				WITH CTE AS   
					(  
						SELECT [PatientPK],[SiteCode],ROW_NUMBER() 
						OVER (PARTITION BY [PatientPK],[SiteCode] 
						ORDER BY [PatientPK],[SiteCode]) AS dump_ 
						FROM [ODS].[dbo].[CT_PatientsWABWHOCD4] 
						)  
			
				DELETE FROM CTE WHERE dump_ >1;

	END