---Load_LatestVisit
With LatestVisit AS (
SELECT  row_number() OVER (PARTITION BY PatientID ,SiteCode,PatientPK ORDER BY VisitDate DESC) AS NUM,
    PatientID ,
    SiteCode,
    PatientPK,
    VisitDate as LastVisitDate,
CASE WHEN NextAppointmentDate IS NULL THEN DATEADD(dd,30,VisitDate) ELSE NextAppointmentDate End AS NextAppointment,
cast(getdate() as date) as LoadDate

FROM ODS.dbo.CT_PatientVisits
 )
 Select LatestVisit.* INTO dbo.Intermediate_LastVisitDate
 from ODS.dbo.LatestVisit
 where NUM=1







