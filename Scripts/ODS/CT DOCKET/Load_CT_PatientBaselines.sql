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
			  ,LTRIM(RTRIM(STR(F.Code)))+'-'+LTRIM(RTRIM(P.[PatientCccNumber])) +'-'+LTRIM(RTRIM(STR(P.[PatientPID]))) AS CKV,
			  convert(nvarchar(64), hashbytes('SHA2_256', cast(P.[PatientPID]  as nvarchar(36))), 2) PatientPKHash,   
				convert(nvarchar(64), hashbytes('SHA2_256', cast(P.[PatientCccNumber]  as nvarchar(36))), 2) PatientIDHash,
				convert(nvarchar(64), hashbytes('SHA2_256', cast(LTRIM(RTRIM(STR(F.Code))) + '-' + LTRIM(RTRIM(P.[PatientCccNumber])) + '-' + LTRIM(RTRIM(STR(P.[PatientPID])))  as nvarchar(36))), 2) CKVHash

		FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
		INNER JOIN [DWAPICentral].[dbo].[PatientArtExtract](NoLock) PA ON PA.[PatientId]= P.ID
		INNER JOIN [DWAPICentral].[dbo].[PatientBaselinesExtract](NoLock) PB ON PB.[PatientId]= P.ID AND PB.Voided=0
		INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0
		WHERE p.gender!='Unknown') b
		ON a.patientID COLLATE SQL_Latin1_General_CP1_CI_AS= b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and 
		a.sitecode = b.sitecode and
		a.PatientBaselinesUniqueID = b.ID


		WHEN NOT MATCHED THEN 
		INSERT(PatientID,PatientPK,SiteCode,bCD4,bCD4Date,bWHO,bWHODate,eCD4,eCD4Date,eWHO,eWHODate,lastWHO,lastWHODate,lastCD4,lastCD4Date,m12CD4,m12CD4Date,m6CD4,m6CD4Date,Emr,Project,[bWAB],[bWABDate],[eWAB],[eWABDate],[lastWAB],[lastWABDate],[Created],PatientPKHash,PatientIDHash,CKVHash)
		VALUES(PatientID,PatientPK,SiteCode,[eCD4],[eCD4Date],[eWHO],bWHODate,[bCD4],[bCD4Date],[bWHO],[bWHODate],[lastWHO],[lastWHODate],[lastCD4],[lastCD4Date],[m12CD4],[m12CD4Date],[m6CD4],[m6CD4Date],[Emr],[Project],[bWAB],[bWABDate],[eWAB],[eWABDate],[lastWAB],[lastWABDate],[Created],PatientPKHash,PatientIDHash,CKVHash)

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
						a.PatientPK		= b.PatientPK,
						a.Emr			= b.Emr,
						a.Project		= b.Project,				
						a.bWAB			= b.bWAB,
						a.bWABDate		= b.bWABDate,
						a.eWAB			= b.eWAB,
						a.eWABDate		= b.eWABDate,
						a.lastWAB		= b.lastWAB	,
						a.lastWABDate	= b.lastWABDate;
	--WHEN NOT MATCHED BY SOURCE 
	--	THEN
	--	/* The Record is in the target table but doen't exit on the source table*/
	--		Delete;
END
