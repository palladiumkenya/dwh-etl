BEGIN
    --truncate table [ODS].[dbo].[MNCH_CwcVisits]
	MERGE [ODS].[dbo].[MNCH_CwcVisits] AS a
			USING(
					SELECT P.ID,[PatientMnchID],[PatientPk],P.[SiteCode],[FacilityName],P.EMR,[Project],cast([DateExtracted] as date)[DateExtracted]
						  ,cast([VisitDate] as date)[VisitDate],[VisitID],[Height],[Weight],[Temp],[PulseRate],[RespiratoryRate],[OxygenSaturation]
						  ,[MUAC],[WeightCategory],[Stunted],[InfantFeeding],[MedicationGiven],[TBAssessment],[MNPsSupplementation],[Immunization]
						  ,[DangerSigns],[Milestones],[VitaminA],[Disability],[ReceivedMosquitoNet],[Dewormed],[ReferredFrom],[ReferredTo],[ReferralReasons]
						  ,[FollowUP],cast([NextAppointment] as date)[NextAppointment],[Date_Created],[Date_Last_Modified]
					  FROM [MNCHCentral].[dbo].[CwcVisits]P
					  INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id ) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID COLLATE SQL_Latin1_General_CP1_CI_AS = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(ID,PatientMnchID,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,VisitDate,VisitID,Height,Weight,Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,WeightCategory,Stunted,InfantFeeding,MedicationGiven,TBAssessment,MNPsSupplementation,Immunization,DangerSigns,Milestones,VitaminA,Disability,ReceivedMosquitoNet,Dewormed,ReferredFrom,ReferredTo,ReferralReasons,FollowUP,NextAppointment,Date_Created,Date_Last_Modified) 
						VALUES(ID,PatientMnchID,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,VisitDate,VisitID,Height,Weight,Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,WeightCategory,Stunted,InfantFeeding,MedicationGiven,TBAssessment,MNPsSupplementation,Immunization,DangerSigns,Milestones,VitaminA,Disability,ReceivedMosquitoNet,Dewormed,ReferredFrom,ReferredTo,ReferralReasons,FollowUP,NextAppointment,Date_Created,Date_Last_Modified)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.[Dewormed]	 =b.[Dewormed];
END