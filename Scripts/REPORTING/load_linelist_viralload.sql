IF  EXISTS (SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'[REPORTING].[dbo].[LineListViralLoad]') AND type in (N'U'))
TRUNCATE TABLE [REPORTING].[dbo].[LineListViralLoad]
GO

INSERT INTO REPORTING.dbo.LineListViralLoad (MFLCode, FacilityName, County, SubCounty, PartnerName, AgencyName, Gender, AgeGroup, PatientPK, PatientID, LatestVL1, LatestVLDate1Key, LatestVL2, LatestVLDate2Key, LatestVL3, LatestVLDate3Key) 
SELECT DISTINCT
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	Gender,
	age.DATIMAgeGroup as AgeGroup,
	pat.PatientPK,
	pat.PatientID,
	LatestVL1,
	vl.LatestVLDate1Key,
	LatestVL2,
	vl.LatestVLDate2Key
	LatestVL3,
	vl.LatestVLDate3Key

FROM NDWH.dbo.FactViralLoads vl
INNER join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=vl.AgeGroupKey
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = vl.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = vl.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = vl.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = vl.PartnerKey

GO
