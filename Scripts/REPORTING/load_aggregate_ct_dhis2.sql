IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateFACT_CT_DHIS2]', N'U') IS NOT NULL 
	DROP TABLE [REPORTING].[dbo].[AggregateFACT_CT_DHIS2];

SELECT 
	id
	,DHISOrgId
	,SiteCode
	,FacilityName
	,CT.County
	,CT.SubCounty
	,Ward
	,ReportMonth_Year
	,Enrolled_Total
	,StartedART_Total
	,CurrentOnART_Total
	,CTX_Total
	,OnART_12Months
	,NetCohort_12Months
	,VLSuppression_12Months
	,VLResultAvail_12Months
	,createdAt
	,updatedAt
	,Start_ART_Under_1
	,Start_ART_1_9
	,Start_ART_10_14_M
	,Start_ART_10_14_F
	,Start_ART_15_19_M
	,Start_ART_15_19_F
	,Start_ART_20_24_M
	,Start_ART_20_24_F
	,Start_ART_25_Plus_M
	,Start_ART_25_Plus_F
	,On_ART_Under_1
	,On_ART_1_9
	,On_ART_10_14_M
	,On_ART_10_14_F
	,On_ART_15_19_M
	,On_ART_15_19_F
	,On_ART_20_24_M
	,On_ART_20_24_F
	,On_ART_25_Plus_M
	,On_ART_25_Plus_F
	,Sites.SDP PartnerName
	,Sites.[SDP_Agency] AgencyName
	,cast(getdate() as date) as LoadDate
INTO REPORTING.dbo.AggregateFACT_CT_DHIS2
FROM NDWH.dbo.FACT_CT_DHIS2 CT
LEFT JOIN ODS.dbo.ALL_EMRSites Sites on CT.SiteCode COLLATE Latin1_General_CI_AS=Sites.MFL_Code;
-- WHERE Sites.SDP IS NOT NULL;
