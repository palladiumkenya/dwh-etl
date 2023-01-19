Go
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AggregateOTZOutcome]') AND type in (N'U'))
TRUNCATE TABLE [dbo].[AggregateOTZOutcome]
GO

INSERT INTO REPORTING.dbo.AggregateOTZOutcome
SELECT DISTINCT
MFLCode,
f.FacilityName,
County,
SubCounty,
p.PartnerName as CTPartner,
a.AgencyName as CTAgency,
Gender,
age.DATIMAgeGroup as AgeGroup,
CONVERT(char(7), cast(cast(OTZEnrollmentDateKey as char) as datetime), 23) as OTZEnrollmentYearMonth,
TransitionAttritionReason as Outcome,
COUNT(TransitionAttritionReason) as TotalOutcome

FROM NDWH.dbo.FactOTZ otz
INNER join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=otz.AgeGroupKey
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = otz.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = otz.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = otz.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = otz.PartnerKey
WHERE TransitionAttritionReason is not null
GROUP BY MFLCode, f.FacilityName, County, SubCounty, p.PartnerName, a.AgencyName, Gender, age.DATIMAgeGroup, CONVERT(char(7), cast(cast(OTZEnrollmentDateKey as char) as datetime), 23), TransitionAttritionReason
