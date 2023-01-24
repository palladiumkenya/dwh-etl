with Uploads 
As (
Select 
    DateRecieved as Dateuploaded,
    [Start],
    [End],
    SiteCode
from DWAPICentral.dbo.FacilityManifest
),

MFL_partner_agency_combination as (

    SELECT distinct 
    MFL_Code,
    SDP,
    [SDP Agency] collate Latin1_General_CI_AS as Agency
    from HIS_Implementation.dbo.[All_EMRSites]

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
left join NDWH.dbo.DimPartner as partner on partner.PartnerName=MFL_partner_agency_combination.SDP collate Latin1_General_CI_AS
left join NDWH.dbo.DimAgency as agency on Agency.AgencyName=MFL_partner_agency_combination.Agency collate Latin1_General_CI_AS
left join NDWH.dbo.DimDate as UploadDates on UploadDates.[Date]=Uploads.Dateuploaded
