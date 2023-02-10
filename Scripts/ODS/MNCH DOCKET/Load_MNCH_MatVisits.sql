
BEGIN
    --truncate table [ODS].[dbo].[MNCH_MatVisits]
	MERGE [ODS].[dbo].[MNCH_MatVisits] AS a
			USING(SELECT  P.[Id],P.[RefId],P.[Created],[PatientPk],P.[SiteCode],P.[Emr],[Project],[Processed],[QueueId],[Status],[StatusDate],[DateExtracted]
      ,[FacilityId],[PatientMnchID],[FacilityName],[VisitID],[VisitDate],[AdmissionNumber],[ANCVisits],[DateOfDelivery]
      ,[DurationOfDelivery],[GestationAtBirth],[ModeOfDelivery],[PlacentaComplete],[UterotonicGiven],[VaginalExamination]
      ,[BloodLoss],[BloodLossVisual],[ConditonAfterDelivery],[MaternalDeath],[DeliveryComplications],[NoBabiesDelivered]
      ,[BabyBirthNumber],[SexBaby],[BirthWeight],[BirthOutcome],[BirthWithDeformity],[TetracyclineGiven],[InitiatedBF],[ApgarScore1]
      ,[ApgarScore5],[ApgarScore10],[KangarooCare],[ChlorhexidineApplied],[VitaminKGiven],[StatusBabyDischarge],[MotherDischargeDate]
      ,[SyphilisTestResults],[HIVStatusLastANC],[HIVTestingDone],[HIVTest1],[HIV1Results],[HIVTest2],[HIV2Results],[HIVTestFinalResult]
      ,[OnARTANC],[BabyGivenProphylaxis],[MotherGivenCTX],[PartnerHIVTestingMAT],[PartnerHIVStatusMAT],[CounselledOn],[ReferredFrom]
	  ,[ReferredTo],[ClinicalNotes],[Date_Created],
	convert(nvarchar(64), hashbytes('SHA2_256', cast(p.[PatientPk]  as nvarchar(36))), 2) PatientPKHash,
	convert(nvarchar(64), hashbytes('SHA2_256', cast([PatientMnchID]  as nvarchar(36))), 2)PatientMnchIDHash
       FROM [MNCHCentral].[dbo].[MatVisits] P
	    INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id ) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID COLLATE SQL_Latin1_General_CP1_CI_AS = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,FacilityId,PatientMnchID,FacilityName,VisitID,VisitDate,AdmissionNumber,ANCVisits,DateOfDelivery,DurationOfDelivery,GestationAtBirth,ModeOfDelivery,PlacentaComplete,UterotonicGiven,VaginalExamination,BloodLoss,BloodLossVisual,ConditonAfterDelivery,MaternalDeath,DeliveryComplications,NoBabiesDelivered,BabyBirthNumber,SexBaby,BirthWeight,BirthOutcome,BirthWithDeformity,TetracyclineGiven,InitiatedBF,ApgarScore1,ApgarScore5,ApgarScore10,KangarooCare,ChlorhexidineApplied,VitaminKGiven,StatusBabyDischarge,MotherDischargeDate,SyphilisTestResults,HIVStatusLastANC,HIVTestingDone,HIVTest1,HIV1Results,HIVTest2,HIV2Results,HIVTestFinalResult,OnARTANC,BabyGivenProphylaxis,MotherGivenCTX,PartnerHIVTestingMAT,PartnerHIVStatusMAT,CounselledOn,ReferredFrom,ReferredTo,ClinicalNotes,Date_Created,PatientPKHash,PatientMnchIDHash) 
						VALUES(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,FacilityId,PatientMnchID,FacilityName,VisitID,VisitDate,AdmissionNumber,ANCVisits,DateOfDelivery,DurationOfDelivery,GestationAtBirth,ModeOfDelivery,PlacentaComplete,UterotonicGiven,VaginalExamination,BloodLoss,BloodLossVisual,ConditonAfterDelivery,MaternalDeath,DeliveryComplications,NoBabiesDelivered,BabyBirthNumber,SexBaby,BirthWeight,BirthOutcome,BirthWithDeformity,TetracyclineGiven,InitiatedBF,ApgarScore1,ApgarScore5,ApgarScore10,KangarooCare,ChlorhexidineApplied,VitaminKGiven,StatusBabyDischarge,MotherDischargeDate,SyphilisTestResults,HIVStatusLastANC,HIVTestingDone,HIVTest1,HIV1Results,HIVTest2,HIV2Results,HIVTestFinalResult,OnARTANC,BabyGivenProphylaxis,MotherGivenCTX,PartnerHIVTestingMAT,PartnerHIVStatusMAT,CounselledOn,ReferredFrom,ReferredTo,ClinicalNotes,Date_Created,PatientPKHash,PatientMnchIDHash)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.[Status]	 =b.[Status];
END


