
IF OBJECT_ID(N'[REPORTING].[dbo].[Linelist_FACTART]', N'U') IS NOT NULL 
	DROP TABLE [REPORTING].[dbo].[Linelist_FACTART];
BEGIN

Select distinct 
    pat.PatientIDHash,
    pat.PatientPKHash,
    pat.Gender,
    pat.DOB,
    pat.MaritalStatus,
    pat.Nupi,
    pat.PatientSource,
    pat.ClientType,
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
    vl.LastVL,
    cast(vl.LastVlDateKey as date) LastVLDate,
    CASE
		WHEN ISNUMERIC( vl.Last12MonthVLResults ) = 1 THEN
			CASE
				WHEN CAST ( Replace( vl.Last12MonthVLResults, ',', '' ) AS FLOAT ) < 400.00 THEN 'VL' 
				WHEN CAST ( Replace( vl.Last12MonthVLResults, ',', '' ) AS FLOAT ) BETWEEN 400.00 AND 1000.00 THEN 'LVL' 
				WHEN CAST ( Replace( vl.Last12MonthVLResults, ',', '' ) AS FLOAT ) > 1000.00 THEN 'HVL' ELSE NULL 
			END ELSE
				CASE
					WHEN vl.Last12MonthVLResults IN ( 'Undetectable', 'NOT DETECTED', '0 copies/ml', 'LDL', 'Less than Low Detectable Level' ) THEN 'VL' ELSE NULL 
				END 
    END AS	[Last12MVLResult],
    vl.HighViremia,
    vl.LowViremia,
    pat.ISTxCurr,
	dif.DifferentiatedCare
    
INTO [REPORTING].[dbo].[Linelist_FACTART]
from  NDWH.dbo.FACTART As ART 
left join NDWH.dbo.DimPatient pat on pat.PatientKey=ART.PatientKey
left join NDWH.dbo.DimPartner partner on partner.PartnerKey=ART.PartnerKey
left join NDWH.dbo.DimAgency agency on agency.AgencyKey=ART.AgencyKey
left join NDWH.dbo.DimFacility fac on fac.FacilityKey=ART.FacilityKey
left join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=ART.AgeGroupKey
left join NDWH.dbo.DimDate startdate on startdate.[Date]=ART.StartARTDateKey
left join NDWH.dbo.DimARTOutcome as outcome on outcome.ARTOutcomeKey=ART.ARTOutcomeKey
LEFT JOIN NDWH.dbo.FactViralLoads as vl on vl.PatientKey = ART.PatientKey
LEFT JOIN NDWH.dbo.FactLatestObs as obs on obs.PatientKey = ART.PatientKey
LEFT JOIN NDWH.dbo.DimDifferentiatedCare as dif on dif.DifferentiatedCareKey = obs.DifferentiatedCareKey;

END
