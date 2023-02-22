BEGIN
		MERGE INTO [ODS].[DBO].CT_PatientBaselines AS a
		USING(SELECT  P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,PB.ID
			  ,PB.[eCD4],PB.[eCD4Date],PB.[eWHO],PB.[eWHODate],PB.[bCD4],PB.[bCD4Date]
			  ,PB.[bWHO],PB.[bWHODate],PB.[lastWHO],PB.[lastWHODate],PB.[lastCD4],PB.[lastCD4Date],PB.[m12CD4]
			  ,PB.[m12CD4Date],PB.[m6CD4],PB.[m6CD4Date],P.[Emr]
			  ,CASE P.[Project] 
					WHEN 'I-TECH' THEN 'Kenya HMIS II' 
					WHEN 'HMIS' THEN 'Kenya HMIS II'
			   ELSE P.[Project] 
			   END AS [Project] 
			  ,PB.[Voided],PB.[Processed],PB.[bWAB],PB.[bWABDate],PB.[eWAB],PB.[eWABDate],PB.[lastWAB]
			  ,PB.[lastWABDate],PB.[Created]


		FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
		INNER JOIN [DWAPICentral].[dbo].[PatientArtExtract](NoLock) PA ON PA.[PatientId]= P.ID
		INNER JOIN [DWAPICentral].[dbo].[PatientBaselinesExtract](NoLock) PB ON PB.[PatientId]= P.ID AND PB.Voided=0
		INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0
		WHERE p.gender!='Unknown') b

		ON a.patientID = b.PatientID  
		and a.sitecode = b.sitecode 
		and a.ID =b. ID


		WHEN NOT MATCHED THEN 
		INSERT(ID,PatientID,PatientPK,SiteCode,bCD4,bCD4Date,bWHO,bWHODate,eCD4,eCD4Date,eWHO,eWHODate,lastWHO,lastWHODate,lastCD4,lastCD4Date,m12CD4,m12CD4Date,m6CD4,m6CD4Date,Emr,Project,[bWAB],[bWABDate],[eWAB],[eWABDate],[lastWAB],[lastWABDate])
		VALUES(ID,PatientID,PatientPK,SiteCode,[eCD4],[eCD4Date],[eWHO],bWHODate,[bCD4],[bCD4Date],[bWHO],[bWHODate],[lastWHO],[lastWHODate],[lastCD4],[lastCD4Date],[m12CD4],[m12CD4Date],[m6CD4],[m6CD4Date],[Emr],[Project],[bWAB],[bWABDate],[eWAB],[eWABDate],[lastWAB],[lastWABDate])

		WHEN MATCHED THEN
			UPDATE SET 
						a.bCD4			= b.bCD4,					
						a.bCD4Date		= b.bCD4Date,
						a.bWHO			= b.bWHO,
						a.bWHODate		= b.bWHODate,
						a.eCD4			= b.eCD4,
						a.eCD4Date		= b.eCD4Date,
						a.eWHO			= b.eWHO,
						a.eWHODate		= b.eWHODate,
						a.lastWHO		= b.lastWHO	,
						a.lastWHODate	= b.lastWHODate,
						a.lastCD4		= b.lastCD4	,
						a.lastCD4Date	= b.lastCD4Date,
						a.m12CD4		= b.m12CD4	,
						a.m12CD4Date	= b.m12CD4Date,
						a.m6CD4			= b.m6CD4,
						a.m6CD4Date		= b.m6CD4Date,				
						a.bWAB			= b.bWAB,
						a.bWABDate		= b.bWABDate,
						a.eWAB			= b.eWAB,
						a.eWABDate		= b.eWABDate,
						a.lastWAB		= b.lastWAB	,
						a.lastWABDate	= b.lastWABDate;


					with cte AS (
				Select
				PatientId,
				sitecode,

				 ROW_NUMBER() OVER (PARTITION BY PatientId,sitecode ORDER BY
				PatientId,sitecode) Row_Num
				FROM [ODS].[DBO].CT_PatientBaselines(NoLock)
				)
			delete  from cte 
				Where Row_Num >1;
END
