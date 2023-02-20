IF OBJECT_ID(N'[NDWH].[dbo].[FACTMANIFEST]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FACTMANIFEST];
BEGIN
with Uploads 
As (
Select 
    DateRecieved as Dateuploaded,
    [Start],
    [End],
    SiteCode
from ODS.dbo.CT_FacilityManifest
),

MFL_partner_agency_combination as (

    SELECT distinct 
    MFL_Code,
    SDP,
    [SDP_Agency] as Agency
    from ODS.dbo.[All_EMRSites]

)

Select 
        FACTKey= IDENTITY(INT,1,1),
        Uploaddates.DateKey as UploadsDateKey,
        facility.FacilityKey ,
        partner.PartnerKey,
        agency.AgencyKey,
        [Start],
        [End],
        cast (getdate() as date) as LoadDate
    INTO dbo.FACTMANIFEST
from Uploads

left join NDWH.dbo.DimFacility as facility on facility.MFLCode=Uploads.Sitecode
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code=Uploads.SiteCode
left join NDWH.dbo.DimPartner as partner on partner.PartnerName=MFL_partner_agency_combination.SDP 
left join NDWH.dbo.DimAgency as agency on Agency.AgencyName=MFL_partner_agency_combination.Agency 
left join NDWH.dbo.DimDate as UploadDates on UploadDates.[Date]=Uploads.Dateuploaded
END
