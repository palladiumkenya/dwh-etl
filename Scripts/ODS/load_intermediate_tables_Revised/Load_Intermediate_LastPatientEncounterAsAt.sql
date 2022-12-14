--Load_LastPatientEncounterAsAt
IF OBJECT_ID(N'[ODS].[dbo].[Intermediate_LastPatientEncounterAsAt]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[dbo].[Intermediate_LastPatientEncounterAsAt];
BEGIN
	With LastPatientEncounterAsAt AS ( 

	 SELECT 
		coalesce (LastVisit.PatientID,LastDispense.PatientID) AS PatientID,
		 coalesce(LastVisit.SiteCode,LastDispense.SiteCode) AS SiteCode,
		 coalesce(LastVisit.PatientPK,LastDispense.PatientPK) AS PatientPK ,
	
		 CASE
		 WHEN LastVisit.VisitDateAsAt > LastDispense.LastDispenseDate
			THEN LastVisit.VisitDateAsAt 
			END AS EncounterDateAsAt,
		CASE 
			WHEN LastVisit.[AppointmentDateAsAt]>LastDispense.ExpectedReturn
			THEN LastVisit.[AppointmentDateAsAt] ELSE coalesce(LastDispense.ExpectedReturn,LastVisit.AppointmentDateAsAt)  END AS AppointmentDateAsAt,
			cast(getdate() as date) as LoadDate
	
	 FROM ODS.dbo.Intermediate_LastVisitAsAt  LastVisit
	 FULL JOIN ODS.dbo.Intermediate_PharmacyDispenseAsAtDate  LastDispense
	 ON  LastVisit.PatientID=LastDispense.PatientID AND LastVisit.SiteCode=LastDispense.SiteCode AND LastVisit.PatientPK =LastDispense.PatientPK

	)

	 Select LastPatientEncounterAsAt.* INTO [ODS].[dbo].[Intermediate_LastPatientEncounterAsAt]
	 from LastPatientEncounterAsAt
END

