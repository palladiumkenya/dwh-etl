
BEGIN
    --truncate table [ODS].[dbo].[MNCH_Heis]
	MERGE [ODS].[dbo].[MNCH_Heis] AS a
			USING(
					SELECT P.[Id],P.[RefId],P.[Created],[PatientPk],P.[SiteCode],P.[Emr],[Project],[Processed],[QueueId],[Status],[StatusDate],[DateExtracted]
						  ,[FacilityId],[FacilityName],[PatientMnchID],[DNAPCR1Date],[DNAPCR2Date],[DNAPCR3Date],[ConfirmatoryPCRDate],[BasellineVLDate]
						  ,[FinalyAntibodyDate],[DNAPCR1],[DNAPCR2],[DNAPCR3],[ConfirmatoryPCR],[BasellineVL],[FinalyAntibody]
						  ,[HEIExitDate],[HEIHIVStatus],[HEIExitCritearia],[Date_Created],[Date_Last_Modified],
					  convert(nvarchar(64), hashbytes('SHA2_256', cast(p.[PatientPk]  as nvarchar(36))), 2) PatientPKHash,
					  convert(nvarchar(64), hashbytes('SHA2_256', cast([PatientMnchID]  as nvarchar(36))), 2)PatientMnchIDHash
					  FROM [MNCHCentral].[dbo].[Heis] P
					    INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID COLLATE SQL_Latin1_General_CP1_CI_AS = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,FacilityName,PatientMnchID,DNAPCR1Date,DNAPCR2Date,DNAPCR3Date,ConfirmatoryPCRDate,BasellineVLDate,FinalyAntibodyDate,DNAPCR1,DNAPCR2,DNAPCR3,ConfirmatoryPCR,BasellineVL,FinalyAntibody,HEIExitDate,HEIHIVStatus,HEIExitCritearia,Date_Created,Date_Last_Modified,PatientPKHash,PatientMnchIDHash) 
						VALUES(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,FacilityName,PatientMnchID,DNAPCR1Date,DNAPCR2Date,DNAPCR3Date,ConfirmatoryPCRDate,BasellineVLDate,FinalyAntibodyDate,DNAPCR1,DNAPCR2,DNAPCR3,ConfirmatoryPCR,BasellineVL,FinalyAntibody,HEIExitDate,HEIHIVStatus,HEIExitCritearia,Date_Created,Date_Last_Modified,PatientPKHash,PatientMnchIDHash)

				
					WHEN MATCHED THEN
						UPDATE SET 
							a.[Status]	 =b.[Status];
END
