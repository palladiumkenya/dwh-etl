IF OBJECT_ID(N'[REPORTING].[dbo].LinelistModuleUptake', N'U') IS NOT NULL 
    DROP TABLE [REPORTING].[dbo].LinelistModuleUptake;


WITH ModulesUptake AS (
    SELECT
        MFLCode,
        FacilityName,
        SubCounty,
        County,
        isEMRSite,
        PartnerName,
        AgencyName,
        modules.isHTS,
        isHTSML,
        isIITML,
        isOTZ,
        isOVC,
        isPMTCT,
        isPrep,
        CAST(GETDATE() AS DATE) AS LoadDate 
    FROM NDWH.dbo.FactModulesuptake AS modules
    LEFT JOIN NDWH.dbo.DimFacility fac ON fac.FacilityKey = modules.FacilityKey
    LEFT JOIN NDWH.dbo.DimPartner pat ON pat.PartnerKey = modules.Partnerkey
    LEFT JOIN NDWH.dbo.DimAgency agency ON agency.AgencyKey = modules.Agencykey
)


SELECT *
INTO REPORTING.dbo.LinelistModuleUptake 
FROM ModulesUptake;

