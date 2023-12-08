IF OBJECT_ID(N'[REPORTING].[dbo].aggregate_concordance_txcurr', N'U') IS NOT NULL 		
	truncate table [REPORTING].[dbo].aggregate_concordance_txcurr
GO

WITH NDW_HTSPos AS (
                SELECT
                    MFLCode SiteCode,
                    FacilityName,
                    PartnerName SDP,
                    County  collate Latin1_General_CI_AS County,
                    SUM(positive) AS HTSPos_total
                FROM NDWH.dbo.FactHTSClientTests link
								LEFT JOIN NDWH.dbo.DimPatient AS pat ON link.PatientKey = pat.PatientKey
                LEFT JOIN NDWH.dbo.DimPartner AS part ON link.PartnerKey = part.PartnerKey
                LEFT JOIN NDWH.dbo.DimFacility AS fac ON link.FacilityKey = fac.FacilityKey
                LEFT JOIN NDWH.dbo.DimAgency AS agency ON link.AgencyKey = agency.AgencyKey
                where link.DateTestedKey  between  DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0) and DATEADD(MONTH, DATEDIFF(MONTH, -2, GETDATE())-1, -1) and FinalTestResult='Positive' and MFLCode is not null and TestType in ('Initial Test', 'Initial')
                GROUP BY MFLCode, FacilityName, PartnerName, County
            ),
           
                AllUpload as (
                SELECT
                   DateRecieved as DateUploaded,
                    [SiteCode],
                    ROW_NUMBER()OVER(Partition by Sitecode Order by DateRecieved Desc) as Num
                FROM ods.dbo.CT_FacilityManifest m
                ),
            Upload As (
				SELECT distinct
					SiteCode,
					DateUploaded
                from AllUpload
				WHERE Num = 1
            ),
            EMR As (SELECT
                Row_Number () over (partition by FacilityCode order by statusDate desc) as Num,
                    facilityCode
                    ,facilityName
                    ,[value]
                    ,statusDate
                    ,indicatorDate
                FROM ODS.dbo.livesync_Indicator
                where stage like '%EMR' and name like '%HTS_TESTED_POS' and indicatorDate=EOMONTH(DATEADD(mm,-2,GETDATE())) and facilityCode is not null
            ),
            Facilityinfo AS (
                Select
                    MFL_Code,
                    County,
                    SDP,
                    EMR
                from ODS.dbo.All_EMRSites
            ),
            DHIS2_HTSPos AS (
                SELECT
                    try_cast([SiteCode] as int) SiteCode,
                    [FacilityName] collate Latin1_General_CI_AS FacilityName,
                    [County],
                    Positive_Total,
                    ReportMonth_Year
                FROM [NDWH].[dbo].FACT_HTS_DHIS2
               WHERE ReportMonth_Year =CONVERT(VARCHAR(6), DATEADD(MONTH, -2, GETDATE()), 112) and ISNUMERIC(SiteCode) >0
            ),
            LatestEMR AS (
                Select
                    Emr.facilityCode 
                    ,Emr.facilityName
                    ,CONVERT (varchar,Emr.[value] ) As EMRValue
                    ,Emr.statusDate
                    ,Emr.indicatorDate
                from EMR
                where Num=1 and Emr.facilityCode is not null
            ),
            DWAPI AS (
                SELECT
                Sitecode,
                 DwapiVersion,
                 Docket
                        From ODS.dbo.CT_FacilityManifestCargo 
            ) 
            Select
                coalesce (DHIS2_HTSPos.SiteCode, NDW_HTSPos.sitecode,LatestEMR.facilityCode ) As MFLCode,
                Coalesce (NDW_HTSPos.FacilityName, DHIS2_HTSPos.FacilityName) As FacilityName,
                fac.SDP As SDP,
                fac.emr as EMR,
                Coalesce (NDW_HTSPos.County, DHIS2_HTSPos.County) As County,
                DHIS2_HTSPos.Positive_Total As KHIS_HTSPos,
                coalesce (NDW_HTSPos.HTSPos_total, 0 )AS DWH_HTSPos,
                LatestEMR.EMRValue As EMR_HTSPos,
                LatestEMR.EMRValue-HTSPos_total As Diff_EMR_DWH,
                DHIS2_HTSPos.Positive_Total-HTSPos_total As DiffKHISDWH,
                DHIS2_HTSPos.Positive_Total-LatestEMR.EMRValue As DiffKHISEMR,
				CAST(ROUND((CAST(LatestEMR.EMRValue AS DECIMAL(7,2)) - CAST(coalesce(NDW_HTSPos.HTSPos_total, null) AS DECIMAL(7,2)))
                /NULLIF(CAST(LatestEMR.EMRValue  AS DECIMAL(7,2)),0)* 100, 2) AS float) AS Percent_variance_EMR_DWH,
                CAST(ROUND((CAST(DHIS2_HTSPos.Positive_Total AS DECIMAL(7,2)) - CAST(NDW_HTSPos.HTSPos_total AS DECIMAL(7,2)))
                /CAST(DHIS2_HTSPos.Positive_Total  AS DECIMAL(7,2))* 100, 2) AS float) AS Percent_variance_KHIS_DWH,
                CAST(ROUND((CAST(DHIS2_HTSPos.Positive_Total AS DECIMAL(7,2)) - CAST(LatestEMR.EMRValue AS DECIMAL(7,2)))
                /CAST(DHIS2_HTSPos.Positive_Total  AS DECIMAL(7,2))* 100, 2) AS float) AS Percent_variance_KHIS_EMR,
                cast (Upload.DateUploaded as date) As DateUploaded,
                DWAPI.DwapiVersion
                into Reporting.dbo.aggregate_concordance_htspos
            from DHIS2_HTSPos
            left join LatestEMR on DHIS2_HTSPos.sitecode=LatestEMR.facilityCode
			LEFT JOIN DWAPI ON DWAPI.SiteCode= LatestEMR.facilityCode
            left join NDW_HTSPos on NDW_HTSPos.sitecode=DHIS2_HTSPos.SiteCode
            left join Upload on NDW_HTSPos.SiteCode=Upload.SiteCode
            left join Facilityinfo fac on DHIS2_HTSPos.SiteCode=fac.MFL_Code
            where DHIS2_HTSPos.Positive_Total is not null
            ORDER BY Percent_variance_EMR_DWH DESC