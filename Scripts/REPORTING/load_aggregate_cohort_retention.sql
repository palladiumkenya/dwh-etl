IF  EXISTS (SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'[REPORTING].[dbo].[AggregateCohortRetention]') AND type in (N'U'))
	TRUNCATE TABLE [REPORTING].[dbo].[AggregateCohortRetention]
GO

INSERT INTO REPORTING.dbo.AggregateCohortRetention
SELECT DISTINCT
MFLCode,
f.FacilityName,
County,
SubCounty,
p.PartnerName as CTPartner,
a.AgencyName as CTAgency,
Gender,
age.DATIMAgeGroup as AgeGroup,
CONVERT(char(7), cast(StartARTDateKey as datetime), 23) as StartARTYearMonth,
--  --- CANT SEEM TO FIND THESE FOR NOW || PREVIOUSLY FOUND IN [All_Staging_2016_2].[dbo].[vw_LastPatientEncounter]
-- Sum(M3Retained)M3Retained, Sum(M3NetCohort)M3NetCohort, 
-- Sum(M6Retained)M6Retained, Sum(M6NetCohort)M6NetCohort,
-- Sum(M12Retained)M12Retained, Sum(M12NetCohort)M12NetCohort,
-- Sum(M18Retained)M18Retained, Sum(M18NetCohort)M18NetCohort,
COUNT(CONCAT(it.PatientKey,'-',it.FacilityKey)) as patients_startedART

FROM NDWH.dbo.FactART it
INNER join NDWH.dbo.DimAgeGroup age on age.Age=it.AgeAtARTStart
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = it.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = it.PartnerKey
GROUP BY MFLCode, f.FacilityName, County, SubCounty, p.PartnerName, a.AgencyName, Gender, age.DATIMAgeGroup, CONVERT(char(7), cast(StartARTDateKey as datetime), 23)
