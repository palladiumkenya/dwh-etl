
BEGIN
    --truncate table [ODS].[dbo].[MNCH_Heis]
	MERGE [ODS].[dbo].[MNCH_Heis] AS a
			USING(
					SELECT P.[Id],P.[RefId],P.[Created],[PatientPk],P.[SiteCode],P.[Emr],[Project],[Processed],[QueueId],[Status],[StatusDate],[DateExtracted]
						  ,[FacilityId],[FacilityName],[PatientMnchID],[DNAPCR1Date],[DNAPCR2Date],[DNAPCR3Date],[ConfirmatoryPCRDate],[BasellineVLDate]
						  ,[FinalyAntibodyDate],[DNAPCR1],[DNAPCR2],[DNAPCR3],[ConfirmatoryPCR],[BasellineVL],[FinalyAntibody]
						  ,[HEIExitDate],[HEIHIVStatus],[HEIExitCritearia],[Date_Created],[Date_Last_Modified]
					  FROM [MNCHCentral].[dbo].[Heis] P
					    INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID  = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,FacilityName,PatientMnchID,DNAPCR1Date,DNAPCR2Date,DNAPCR3Date,ConfirmatoryPCRDate,BasellineVLDate,FinalyAntibodyDate,DNAPCR1,DNAPCR2,DNAPCR3,ConfirmatoryPCR,BasellineVL,FinalyAntibody,HEIExitDate,HEIHIVStatus,HEIExitCritearia,Date_Created,Date_Last_Modified) 
						VALUES(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,FacilityName,PatientMnchID,DNAPCR1Date,DNAPCR2Date,DNAPCR3Date,ConfirmatoryPCRDate,BasellineVLDate,FinalyAntibodyDate,DNAPCR1,DNAPCR2,DNAPCR3,ConfirmatoryPCR,BasellineVL,FinalyAntibody,HEIExitDate,HEIHIVStatus,HEIExitCritearia,Date_Created,Date_Last_Modified)

				
					WHEN MATCHED THEN
						UPDATE SET 
							a.[Status]	 =b.[Status];
END
