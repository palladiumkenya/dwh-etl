
IF OBJECT_ID(N'[REPORTING].[dbo].[Linelist_FACTART]', N'U') IS NOT NULL 
	DROP TABLE [REPORTING].[dbo].[Linelist_FACTART];
BEGIN

Select distinct 
    pat.PatientID,
    pat.PatientPK,
    pat.Gender,
    pat.DOB,
    pat.MaritalStatus,
    pat.Nupi,
    pat.PatientSource,
    pat.PatientType,
    pat.SiteCode,
    fac.FacilityName,
    fac.County,
    fac.SubCounty,
    partner.PartnerName,
    agency.AgencyName,
    age.age,
    age.DATIMAgeGroup as AgeGroup,
    startdate.[Date] as StartARTDate,
    CurrentRegimen,
    CurrentRegimenline,
    StartRegimen,
    StartRegimenLine,
    AgeAtEnrol,
    AgeAtARTStart,
    TimetoARTDiagnosis,
    TimetoARTEnrollment,
    PregnantARTStart,
    PregnantAtEnrol,
    LastVisitDate,
    NextAppointmentDate,
    StartARTAtThisfacility,
    PreviousARTStartDate,
    PreviousARTRegimen,
    outcome.ARTOutcome,
    vl.EligibleVL as Eligible4VL,
    vl.Last12MonthVL,
    vl.Last12MVLSup,
		Case WHEN ISNUMERIC(vl.Last12MonthVLResults) = 1 
			THEN CASE WHEN CAST(Replace(vl.Last12MonthVLResults,',','')AS FLOAT) > 1000.00 THEN 1 ELSE 0 END
		END as HighViremia,
		Case WHEN ISNUMERIC(vl.Last12MonthVLResults) = 1 
			THEN CASE WHEN CAST(Replace(vl.Last12MonthVLResults,',','')AS FLOAT) between 400.00 and 1000.00 THEN 1 ELSE 0 END
		END as LowViremia,
    pat.ISTxCurr
    
INTO [REPORTING].[dbo].[Linelist_FACTART]
from  NDWH.dbo.FACTART As ART 
left join NDWH.dbo.DimPatient pat on pat.PatientKey=ART.PatientKey
left join NDWH.dbo.DimPartner partner on partner.PartnerKey=ART.PartnerKey
left join NDWH.dbo.DimAgency agency on agency.AgencyKey=ART.AgencyKey
left join NDWH.dbo.DimFacility fac on fac.FacilityKey=ART.FacilityKey
left join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=ART.AgeGroupKey
left join NDWH.dbo.DimDate startdate on startdate.[Date]=ART.StartARTDateKey
left join NDWH.dbo.DimARTOutcome as outcome on outcome.ARTOutcomeKey=ART.ARTOutcomeKey
LEFT JOIN NDWH.dbo.FactViralLoads as vl on vl.PatientKey = ART.PatientKey;

END
