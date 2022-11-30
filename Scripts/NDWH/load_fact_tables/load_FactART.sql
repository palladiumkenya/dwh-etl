Select 
    Patient.PatientID,
    Patient.PatientPK,
    cast (Patient.SiteCode as nvarchar) As SiteCode,
    fac.FacilityName,
    fac.SubCounty,
    fac.County,
    DATEDIFF(yy,Patient.DOB,Patient.RegistrationAtCCC) AgeAtEnrol,
    DATEDIFF(yy,Patient.DOB,ART.StartARTDate) AgeAtARTStart,
    lastreg.RegimenKey As CurrentRegimen,
    lastregline.RegimenLineKey As CurrentRegimenLine,
    LastARTDate.DateKey As LastARTDateKey,
    firstreg.RegimenKey As StartRegimen,
    firstregline.RegimenLineKey As StartRegimenLine,
    ART.StartARTAtThisfacility,
    ART.PreviousARTStartDate,
    ART.PreviousARTRegimen,

  CASE WHEN [DateConfirmedHIVPositive] IS NOT NULL AND ART.StartARTDate IS NOT NULL
				 THEN CASE WHEN DateConfirmedHIVPositive<= ART.StartARTDate THEN DATEDIFF(DAY,DateConfirmedHIVPositive,ART.StartARTDate)
					ELSE NULL END
				ELSE NULL END AS TimetoARTDiagnosis,
    CASE WHEN Patient.RegistrationAtCCC IS NOT NULL AND ART.StartARTDate IS NOT NULL
				THEN CASE WHEN Patient.RegistrationAtCCC<=ART.StartARTDate  THEN DATEDIFF(DAY,Patient.[RegistrationAtCCC],ART.StartARTDate)
				ELSE NULL END
				ELSE NULL END AS TimetoARTEnrollment,
        Pre.PregnantARTStart,
        Pre.PregnantAtEnrol,
        las.LastEncounterDate As LastVisitDate,
        las.NextAppointmentDate,
        StartARTDate.DateKey  as StartARTDateKey
from 
ODS.dbo.CT_Patient Patient
left join ODS.dbo.CT_ARTPatients ART on ART.PatientPK=Patient.Patientpk and ART.SiteCode=Patient.SiteCode
left join NDWH.dbo.Dimfacility fac on fac.MFLCode=Patient.SiteCode
left join ODS.dbo.PregnancyAsATInitiation   Pre on Pre.Patientpk= Patient.PatientPK and Pre.SiteCode=Patient.SiteCode
left join ODS.dbo.CT_LastPatientEncounter las on las.PatientPK collate Latin1_General_CI_AS=Patient.PatientPK collate Latin1_General_CI_AS and las.SiteCode collate Latin1_General_CI_AS=Patient.SiteCode collate Latin1_General_CI_AS
left join NDWH.dbo.DimDate as StartARTDate on StartARTDate.Date= ART.StartARTDate
left join NDWH.dbo.DimDate as LastARTDate on  LastARTDate.[Date]=ART.LastARTDate
left join NDWH.dbo.DimRegimen lastreg on lastreg.Regimen=ART.LastRegimen
left join NDWH.dbo.DimRegimen firstreg on firstreg.Regimen=ART.StartRegimen
left join NDWH.dbo.DimRegimenLine lastregline on lastregline.RegimenLine=ART.LastRegimenLine
left join NDWH.dbo.DimRegimenLine firstregline on firstregline.RegimenLine=ART.StartRegimenLine



