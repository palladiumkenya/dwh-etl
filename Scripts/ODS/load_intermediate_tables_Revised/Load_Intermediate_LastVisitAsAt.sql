--Load_LastVisitAsAt
IF OBJECT_ID(N'[ODS].[dbo].[Intermediate_LastVisitAsAt]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[dbo].[Intermediate_LastVisitAsAt];
BEGIN
	With LastVisitAsAt AS (
	SELECT  row_number() OVER (PARTITION BY PatientID ,SiteCode,PatientPK ORDER BY VisitDate DESC) AS NUM,
		PatientID ,
		SiteCode,
		PatientPK,
		VisitDate AS VisitDateAsAt,
	CASE WHEN NextAppointmentDate IS NULL THEN DATEADD(dd,30,VisitDate) ELSE NextAppointmentDate End AS AppointmentDateAsAt ,
	cast(getdate() as date) as LoadDate
	FROM ODS.dbo.CT_PatientVisits
	 )
	 SELECT LastVisitAsAt.* INTO [ODS].[dbo].[Intermediate_LastVisitAsAt]
	 FROM LastVisitAsAt
	 WHERE NUM=1 and VisitDateAsAt<=EOMONTH(DATEADD(mm,-1,GETDATE()))
END
