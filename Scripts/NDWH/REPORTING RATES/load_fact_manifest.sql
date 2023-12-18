SQL
IF OBJECT_ID(N'NDWH.DBO.Fact_manifest ', N'U') IS NOT NULL 
    DROP TABLE NDWH.DBO.Fact_manifest ;

    with MFL_partner_agency_combination as (
    select 
        distinct MFL_Code,
        SDP ,
        SDP_Agency  as Agency
    from ODS.dbo.All_EMRSites 
    ),
    Fact_manifest  as(
        Select
            ID as  manifestId,
            Cast(max(m.DateRecieved) as date) timeId,
            max(m.SiteCode) facilityId,
            max(coalesce(h.emr,'Unkown')) emrId,
            'CT' docketId,
            1 upload,
            [Start],
            [End],
            cast(getdate() as date) as LoadDate
        from ODS.dbo.CT_FacilityManifest m 
            inner join ODS.dbo.ALL_EMRSites h
        on m.SiteCode=h.MFL_Code
                        GROUP BY ID,[start],[end],YEAR(m.DateRecieved), 
                    MONTH(m.DateRecieved), SiteCode 


        UNION ALL 


        SELECT  Id  AS manifestId, 
                CAST(MAX(m.DateArrived) AS DATE) AS timeId,
                MAX(m.SiteCode) AS facilityId, 
                MAX(COALESCE(h.emr, 'Unknown')) AS emrId, 
                'HTS' AS docketId, 
                1 AS upload,
                [Start],
                [End],
                cast(getdate() as date) as LoadDate
        FROM ODS.DBO.HTS_Manifests m 
            INNER JOIN ODS.DBO.ALL_EMRSites h ON m.SiteCode = h.MFL_Code 
        GROUP BY    ID,[start],[end],
        YEAR(DateArrived), 
                    MONTH(DateArrived), SiteCode 

            UNION ALL 


        SELECT Id AS manifestId, 
                CAST(MAX(m.DateArrived) AS DATE) AS timeId, 
                MAX(m.SiteCode) AS facilityId,
                MAX(COALESCE(h.emr, 'Unknown')) AS emrId,
                'PKV' AS docketId, 
                1 AS upload ,
                [Start],
                [End],
                 cast(getdate() as date) as LoadDate
        FROM ODS.dbo.CBS_Manifests m INNER JOIN ODS.dbo.all_emrsites h ON m.SiteCode = h.MFL_Code 
        GROUP BY ID,[start],[end],
        YEAR(DateArrived), 
                    MONTH(DateArrived), SiteCode
    )


	
	SELECT 
			FactKey= IDENTITY(INT,1,1),
	         manifestId,
			 timeId,
			 facilityId,
			 emrId,
			 docketId,
			 upload,
			 partner.PartnerKey,
             agency.AgencyKey,
             started.DateKey as StartDateKey,
             ended.DateKey as EndDateKey,
			 LoadDate
	INTO NDWH.DBO.Fact_manifest as manifest
	FROM Fact_manifest
	left join NDWH.dbo.DimFacility as facility on facility.MFLCode=manifest.facilityId
    left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code=manifest.SiteCode
    left join NDWH.dbo.DimPartner as partner on partner.PartnerName=MFL_partner_agency_combination.SDP collate Latin1_General_CI_AS
    left join NDWH.dbo.DimAgency as agency on Agency.AgencyName=MFL_partner_agency_combination.Agency collate Latin1_General_CI_AS
    left join NDWH.dbo.DimDate as UploadDates on UploadDates.Date = manifest.timeId
    left join NDWH.dbo.DimDate as started on started.Date = manifest.[Start]
    left join NDWH.dbo.DimDate as ended on ended.Date = manifest.[End]

    alter table NDWH.dbo.Fact_manifest add primary key(FactKey)
END


