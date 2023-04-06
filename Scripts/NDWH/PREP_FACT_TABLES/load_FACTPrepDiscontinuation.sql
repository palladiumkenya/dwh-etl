IF OBJECT_ID(N'[NDWH].[dbo].[FactPrepDiscontinuation]', N'U') IS NOT NULL 
DROP TABLE [NDWH].[dbo].[FactPrepDiscontinuation];

BEGIN

    with MFL_partner_agency_combination as (
        select 
            distinct MFL_Code,
            SDP,
        SDP_Agency  as Agency
        from ODS.dbo.All_EMRSites 
    ),
    prep_patients as
    (
        select
            distinct convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK as nvarchar(36))), 2) as PatientPK,
            SiteCode
        from ODS.dbo.PrEP_Patient
        where ODS.dbo.PrEP_Patient.PrepNumber is not null
    ),

PrepDiscontinuation as (
        select 
              convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK as nvarchar(36))), 2) as PatientPK,
                SiteCode,
                ExitDate,
                ExitReason                  
        from ODS.DBO.PrEP_CareTermination
        

    )


    select 
        FactKey = IDENTITY(INT, 1, 1),
        patient.PatientKey,
        facility.FacilityKey,
        agency.AgencyKey,
        partner.PartnerKey,
        Discontinuation.DateKey as ExitDateKey,
        PrepDiscontinuation.ExitDate,
        PrepDiscontinuation.ExitReason,
        cast(getdate() as date) as LoadDate
    into NDWH.dbo.FactPrepDiscontinuation
    from prep_patients
    left join PrepDiscontinuation on convert(nvarchar(64), hashbytes('SHA2_256', cast(PrepDiscontinuation.PatientPK as nvarchar(36))), 2) =  prep_patients.PatientPK
        and PrepDiscontinuation.SiteCode = prep_patients.SiteCode
    left join NDWH.dbo.DimPatient as patient on patient.PatientPKHash = prep_patients.PatientPK
        and patient.SiteCode = prep_patients.SiteCode
    left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = prep_patients.SiteCode
    left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP 
    left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
    left join NDWH.dbo.DimFacility as facility on facility.MFLCode = prep_patients.SiteCode
    left join NDWH.dbo.DimDate as Discontinuation on Discontinuation.Date = PrepDiscontinuation.ExitDate;

    alter table NDWH.dbo.FactPrepDiscontinuation add primary key(FactKey);
END