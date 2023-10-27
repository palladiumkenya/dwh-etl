IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateCovid]', N'U') IS NOT NULL 
	drop TABLE [REPORTING].[dbo].[AggregateCovid]
GO

SELECT
    MFLCode,
    f.FacilityName,
    County,
    SubCounty,
    p.PartnerName,
    a.AgencyName,
    Gender,
    age.DATIMAgeGroup as AgeGroup,
    case 
        when cov.VaccinationStatus is null or cov.VaccinationStatus = '' then 'Not Accessed'
        else cov.VaccinationStatus
    end as VaccinationStatus,  
    cov.PatientStatus,
    cov.AdmissionStatus,
    cov.AdmissionUnit,
    cov.EverCOVID19Positive,
    cov.MissedAppointmentDueToCOVID19,
    count(art.PatientKey) as TXCurr12YearsAbove,
    sum(case when VaccinationStatus in ('Fully Vaccinated','Not Vaccinated','Partially Vaccinated') then 1 else 0 end) as Screened,
    cast(getdate() as date) as LoadDate
INTO REPORTING.dbo.AggregateCovid 
FROM NDWH.dbo.FactArt as art
LEFT JOIN NDWH.dbo.FactCovid as cov on cov.PatientKey = art.PatientKey
LEFT join NDWH.dbo.DimFacility f on f.FacilityKey = art.FacilityKey
LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = art.AgencyKey
LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = art.PatientKey
LEFT join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey = art.AgeGroupKey
LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = cov.PartnerKey
WHERE age.Age >= 12 AND pat.IsTXCurr = 1 
GROUP BY 
    MFLCode,
    f.FacilityName,
    County,
    SubCounty,
    p.PartnerName,
    a.AgencyName,
    Gender,
    age.DATIMAgeGroup,
    cov.VaccinationStatus,
    cov.PatientStatus,
    cov.AdmissionStatus,
    cov.AdmissionUnit,
    cov.EverCOVID19Positive,
    cov.MissedAppointmentDueToCOVID19