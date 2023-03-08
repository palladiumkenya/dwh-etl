
BEGIN
    --truncate table [ODS].[dbo].[MNCH_CwcVisits]
	MERGE [ODS].[dbo].[MNCH_CwcVisits] AS a
			USING(
					SELECT Distinct p.[PatientMnchID],p.[PatientPk],P.[SiteCode],p.[FacilityName],P.EMR,p.[Project],cast(p.[DateExtracted] as date)[DateExtracted]
						  ,cast([VisitDate] as date)[VisitDate],[VisitID],[Height],[Weight],[Temp],[PulseRate],[RespiratoryRate],[OxygenSaturation]
						  ,[MUAC],[WeightCategory],[Stunted],[InfantFeeding],[MedicationGiven],[TBAssessment],[MNPsSupplementation],[Immunization]
						  ,[DangerSigns],[Milestones],[VitaminA],[Disability],[ReceivedMosquitoNet],[Dewormed],[ReferredFrom],[ReferredTo],[ReferralReasons]
						  ,[FollowUP],cast([NextAppointment] as date)[NextAppointment],p.[Date_Last_Modified]
					  FROM [MNCHCentral].[dbo].[CwcVisits] P (Nolock)
					  inner join (select tn.PatientPK,tn.SiteCode,max(tn.DateExtracted)MaxDateExtracted FROM [MNCHCentral].[dbo].[CwcVisits] (NoLock)tn
						group by tn.PatientPK,tn.SiteCode)tm
					on P.PatientPk = tm.PatientPk and p.SiteCode = tm.SiteCode and p.DateExtracted = tm.MaxDateExtracted
					  INNER JOIN  [MNCHCentral].[dbo].[MnchPatients] MnchP(Nolock)
						on P.patientPK = MnchP.patientPK and P.Sitecode = MnchP.Sitecode
					  INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id ) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						--and a.ID  = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(PatientMnchID,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,VisitDate,VisitID,Height,Weight,Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,WeightCategory,Stunted,InfantFeeding,MedicationGiven,TBAssessment,MNPsSupplementation,Immunization,DangerSigns,Milestones,VitaminA,Disability,ReceivedMosquitoNet,Dewormed,ReferredFrom,ReferredTo,ReferralReasons,FollowUP,NextAppointment,Date_Last_Modified ) 
						VALUES(PatientMnchID,PatientPk,SiteCode,FacilityName,EMR,Project,DateExtracted,VisitDate,VisitID,Height,Weight,Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,WeightCategory,Stunted,InfantFeeding,MedicationGiven,TBAssessment,MNPsSupplementation,Immunization,DangerSigns,Milestones,VitaminA,Disability,ReceivedMosquitoNet,Dewormed,ReferredFrom,ReferredTo,ReferralReasons,FollowUP,NextAppointment,Date_Last_Modified )
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.[Dewormed]	 =b.[Dewormed];
END

