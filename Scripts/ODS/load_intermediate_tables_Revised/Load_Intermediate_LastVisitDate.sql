---Load_LatestVisit
IF OBJECT_ID(N'[ODS].[dbo].[Intermediate_LastVisitDate]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[dbo].[Intermediate_LastVisitDate];
With LatestVisit AS (
SELECT  row_number() OVER (PARTITION BY PatientID ,SiteCode,PatientPK ORDER BY VisitDate DESC) AS NUM,
    PatientID ,
    SiteCode,
    PatientPK,
    VisitDate as LastVisitDate,
CASE WHEN NextAppointmentDate IS NULL THEN DATEADD(dd,30,VisitDate) ELSE NextAppointmentDate End AS NextAppointment,
cast(getdate() as date) as LoadDate

FROM ODS.dbo.CT_PatientVisits(NoLock)
 )
 Select LatestVisit.* INTO [ODS].[dbo].[Intermediate_LastVisitDate]
 from LatestVisit
 where NUM=1







