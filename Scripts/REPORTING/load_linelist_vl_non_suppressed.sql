IF OBJECT_ID(N'[REPORTING].[dbo].[LineListVLNonSuppressed]', N'U') IS NOT NULL 			
	TRUNCATE TABLE [REPORTING].[dbo].[LineListVLNonSuppressed]
GO

INSERT INTO [REPORTING].[dbo].[LineListVLNonSuppressed] (MFLCode,FacilityName,SubCounty,County,PartnerName,AgencyName,Gender, AgeGroup,AgeLastVisit, StartARTDate,Last12MonthVLResults,LastVisitDate,NextAppointmentDate, ARTOutcome
)
SELECT DISTINCT
MFLCode,
f.FacilityName,
SubCounty,
County,
p.PartnerName,
a.AgencyName,
Gender,
g.DATIMAgeGroup as AgeGroup,
art.AgeLastVisit,
StartARTDateKey as StartARTDate,
Last12MonthVLResults,
art.LastVisitDate,
art.NextAppointmentDate,
aro.ARTOutcome
FROM NDWH.dbo.FactViralLoads it
INNER join NDWH.dbo.DimAgeGroup g on g.AgeGroupKey=it.AgeGroupKey
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = it.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = it.PartnerKey
INNER JOIN NDWH.dbo.FactART art on art.PatientKey = it.PatientKey
INNER JOIN NDWH.dbo.DimARTOutcome aro on aro.ARTOutcomeKey = art.ARTOutcomeKey
WHERE Last12MVLResult = '>1000'