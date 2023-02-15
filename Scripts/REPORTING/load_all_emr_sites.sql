IF OBJECT_ID(N'REPORTING.dbo.all_EMRSites', N'U') IS NOT NULL 
	DROP TABLE REPORTING.dbo.all_EMRSites;
SELECT 
	fac.MFLCode,
	fac.FacilityName,
	fac.County,
	fac.SubCounty,
	a.SDP_Agency as AgencyName,
	a.SDP as PartnerName,
	fac.Latitude,
	fac.Longitude,
	fac.EMR,
	fac.isCT,
	fac.isPkv,
	fac.isHts
INTO REPORTING.dbo.all_EMRSites
FROM NDWH.dbo.DimFacility fac
JOIN ODS.dbo.All_EMRSites a on a.MFL_Code = fac.MFLCode